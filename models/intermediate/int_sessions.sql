with events as (

    select *
    from {{ ref('stg_events') }}

),

sessions as (

    select
        concat(
            user_pseudo_id,
            '-',
            cast(ga_session_id as string)
        ) as session_key,

        user_pseudo_id,
        ga_session_id,

        max(ga_session_number) as ga_session_number,

        min(event_timestamp) as session_start,
        max(event_timestamp) as session_end,

        timestamp_diff(
            max(event_timestamp),
            min(event_timestamp),
            second
        ) as session_duration_seconds,

        cast(sum(coalesce(engagement_time_msec, 0)) / 1000 as int64)
           as engagement_time_seconds,

        count(*) as total_events,
        countif(event_name = 'page_view') as page_views,
        countif(event_name = 'purchase') as purchases,

        -- Standardise revenue to USD
        sum(
            case
                when event_name = 'purchase'
                then coalesce(purchase_revenue_in_usd, 0)
                else 0
            end
        ) as revenue,

        max(
            case when session_engaged = '1' then 1 else 0 end
        ) as is_engaged_session,

        min(user_first_touch_timestamp) as user_first_touch_timestamp,

        max(case when event_name = 'view_item'
            then 1 else 0 end) as view_item,

        max(case when event_name = 'add_to_cart'
            then 1 else 0 end) as add_to_cart,

        max(case when event_name = 'begin_checkout'
            then 1 else 0 end) as begin_checkout,

        max(case when event_name = 'add_shipping_info'
            then 1 else 0 end) as add_shipping_info,

        max(case when event_name = 'add_payment_info'
            then 1 else 0 end) as add_payment_info,

        max(case when event_name = 'purchase'
            then 1 else 0 end) as purchase,

        any_value(device_category) as device_category,
        any_value(operating_system) as operating_system,
        any_value(browser) as browser,

        any_value(continent) as continent,
        any_value(country) as country,
        any_value(region) as region,
        any_value(city) as city,

        -- Prefer event/session source, fall back to GA4 traffic source
        coalesce(
            array_agg(
                event_source ignore nulls
                order by event_timestamp
                limit 1
            )[safe_offset(0)],
            any_value(traffic_source)
        ) as traffic_source,

        coalesce(
            array_agg(
                event_medium ignore nulls
                order by event_timestamp
                limit 1
            )[safe_offset(0)],
            any_value(traffic_medium)
        ) as traffic_medium

    from events

    group by
        user_pseudo_id,
        ga_session_id

)

select *
from sessions