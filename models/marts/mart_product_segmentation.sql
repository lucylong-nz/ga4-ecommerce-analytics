with products as (

    select *
    from {{ ref('int_products') }}

),

dataset_end as (

    select
        max(date(event_timestamp)) as analysis_date
    from {{ ref('stg_events') }}

),

thresholds as (

    select

        (
            select approx_quantiles(purchases_last_30d, 10)[offset(8)]
            from products
            where purchases_last_30d > 0
        ) as high_purchase_threshold,

        (
            select approx_quantiles(revenue_last_30d, 10)[offset(8)]
            from products
            where revenue_last_30d > 0
        ) as high_revenue_threshold

),

scored as (

    select
        p.*,

        to_hex(md5(concat(
            coalesce(item_id, ''),
            '|',
            coalesce(item_name, '')
        ))) as product_key,

        d.analysis_date,

        date_diff(
            d.analysis_date,
            p.first_activity_date,
            day
        ) as product_age_days,

        case
            when p.purchases_last_30d >= t.high_purchase_threshold
             and p.revenue_last_30d >= t.high_revenue_threshold
            then 1 else 0
        end as is_high_performer,

        case
            when p.revenue_last_30d >= t.high_revenue_threshold
            and p.revenue_last_30d > 0
            then 1 else 0
        end as is_high_revenue,

        case
            when p.days_since_last_activity >= 30
            then 1 else 0
        end as is_at_risk



    from products p
    cross join dataset_end d
    cross join thresholds t

),

segmented as (

    select
        *,

        case
            when purchase_events > 0
             and days_since_last_activity >= 30
                then 'At Risk'

            when is_high_performer = 1
                then 'High Performer'

            when is_high_revenue = 1
                then 'Revenue Driver'

            else 'Standard Product'
        end as product_segment,

        case
            when days_since_last_activity is null then 'No Activity'
            when days_since_last_activity <= 7 then '≤7d'
            when days_since_last_activity <= 14 then '8–14d'
            when days_since_last_activity < 30 then '15–29d'
            else '≥30d'
        end as activity_status

    from scored

)


select *
from segmented