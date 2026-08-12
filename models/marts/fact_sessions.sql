with sessions as (

    select *
    from {{ ref('int_sessions') }}

)

select
    session_key,
    user_pseudo_id,
    ga_session_id,

    -- dimension keys
    date(session_start) as date_key,

    to_hex(md5(concat(
        coalesce(traffic_source, ''),
        '|',
        coalesce(traffic_medium, '')
    ))) as channel_key,

    -- timestamps
    session_start,
    session_end,

    -- session metrics
    session_duration_seconds,
    engagement_time_seconds,
    total_events,
    page_views,
    purchases,
    revenue,
    is_engaged_session,

    -- funnel metrics
    view_item,
    add_to_cart,
    begin_checkout,
    add_shipping_info,
    add_payment_info,
    purchase,

    -- device
    device_category,
    operating_system,
    browser,

    -- geography
    continent,
    country,
    region,
    city

from sessions