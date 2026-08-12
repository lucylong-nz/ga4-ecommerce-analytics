with items as (

    select *
    from {{ ref('stg_items') }}

    where item_id is not null
      and item_id != '(not set)'
      and item_name is not null
      and item_name != '(not set)'
      and event_name not in ('view_promotion', 'select_promotion')

),

analysis_date as (

    select
        max(event_date) as max_date
    from items

),

products as (

    select
        item_id,
        item_name,

        array_agg(item_brand ignore nulls limit 1)[safe_offset(0)] as item_brand,
        array_agg(item_category ignore nulls limit 1)[safe_offset(0)] as item_category,
        array_agg(category_level_1 ignore nulls limit 1)[safe_offset(0)] as category_level_1,
        array_agg(category_level_2 ignore nulls limit 1)[safe_offset(0)] as category_level_2,
        array_agg(category_level_3 ignore nulls limit 1)[safe_offset(0)] as category_level_3,

        -- Activity dates
        min(event_date) as first_activity_date,
        max(event_date) as last_activity_date,

        min(case when event_name = 'view_item'
            then event_date end) as first_view_date,

        max(case when event_name = 'view_item'
            then event_date end) as last_view_date,

        min(case when event_name = 'purchase'
            then event_date end) as first_purchase_date,

        max(case when event_name = 'purchase'
            then event_date end) as last_purchase_date,

        max(case when event_name in ('add_to_cart', 'purchase')
            then event_date end) as last_commercial_activity_date,

        date_diff(
            (select max_date from analysis_date),
            max(case when event_name in ('add_to_cart', 'purchase')
                then event_date end),
            day
        ) as days_since_last_activity,

        -- Lifetime
        countif(event_name = 'view_item') as product_views,
        countif(event_name = 'add_to_cart') as add_to_cart_events,
        countif(event_name = 'begin_checkout') as checkout_events,
        countif(event_name = 'purchase') as purchase_events,

        sum(case when event_name = 'purchase'
            then coalesce(quantity, 0) else 0 end) as units_purchased,

        sum(case when event_name = 'purchase'
            then coalesce(item_revenue, 0) else 0 end) as product_revenue,

        -- Last 30 days
        countif(
            event_name = 'view_item'
            and event_date > date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
        ) as views_last_30d,

        countif(
            event_name = 'add_to_cart'
            and event_date > date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
        ) as add_to_cart_last_30d,

        countif(
            event_name = 'purchase'
            and event_date > date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
        ) as purchases_last_30d,

        sum(case
            when event_name = 'purchase'
             and event_date > date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
            then coalesce(item_revenue, 0)
            else 0
        end) as revenue_last_30d,

        -- Previous 30 days
        countif(
            event_name = 'view_item'
            and event_date > date_sub(
                (select max_date from analysis_date),
                interval 60 day
            )
            and event_date <= date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
        ) as views_previous_30d,

        countif(
            event_name = 'add_to_cart'
            and event_date > date_sub(
                (select max_date from analysis_date),
                interval 60 day
            )
            and event_date <= date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
        ) as add_to_cart_previous_30d,

        countif(
            event_name = 'purchase'
            and event_date > date_sub(
                (select max_date from analysis_date),
                interval 60 day
            )
            and event_date <= date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
        ) as purchases_previous_30d,

        sum(case
            when event_name = 'purchase'
             and event_date > date_sub(
                (select max_date from analysis_date),
                interval 60 day
            )
             and event_date <= date_sub(
                (select max_date from analysis_date),
                interval 30 day
            )
            then coalesce(item_revenue, 0)
            else 0
        end) as revenue_previous_30d,

        -- Keep view-based ratios for reference only
        safe_divide(
            countif(event_name = 'add_to_cart'),
            countif(event_name = 'view_item')
        ) as view_to_cart_rate,

        safe_divide(
            countif(event_name = 'begin_checkout'),
            countif(event_name = 'add_to_cart')
        ) as cart_to_checkout_rate,

        safe_divide(
            countif(event_name = 'purchase'),
            countif(event_name = 'begin_checkout')
        ) as checkout_to_purchase_rate,

        safe_divide(
            countif(event_name = 'purchase'),
            countif(event_name = 'view_item')
        ) as view_to_purchase_rate

    from items

    group by
        item_id,
        item_name

)

select *
from products