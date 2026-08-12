with source as (

    select *
    from {{ source('ga4_raw', 'ga4_events_raw') }}

),

staged as (

    select

        -- Event key
        to_hex(md5(concat(
            coalesce(user_pseudo_id, ''),
            '|',
            cast(event_timestamp as string),
            '|',
            coalesce(event_name, ''),
            '|',
            cast(coalesce(event_bundle_sequence_id, 0) as string)
        ))) as event_key,

        -- Event
        parse_date('%Y%m%d', event_date) as event_date,
        timestamp_micros(event_timestamp) as event_timestamp,
        event_name,
        event_value_in_usd,

        -- User
        user_pseudo_id,
        timestamp_micros(user_first_touch_timestamp) as user_first_touch_timestamp,

        -- Common event parameters
        (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_id'
        ) as ga_session_id,

        (
            select value.int_value
            from unnest(event_params)
            where key = 'ga_session_number'
        ) as ga_session_number,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'page_location'
        ) as page_location,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'page_title'
        ) as page_title,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'page_referrer'
        ) as page_referrer,

        (
            select value.int_value
            from unnest(event_params)
            where key = 'engagement_time_msec'
        ) as engagement_time_msec,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'session_engaged'
        ) as session_engaged,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'source'
        ) as event_source,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'medium'
        ) as event_medium,

        (
            select value.string_value
            from unnest(event_params)
            where key = 'campaign'
        ) as event_campaign,

        -- User LTV
        user_ltv.revenue as user_ltv_revenue,
        user_ltv.currency as user_ltv_currency,

        -- Device
        device.category as device_category,
        device.mobile_brand_name,
        device.operating_system,
        device.operating_system_version,
        device.language,
        device.web_info.browser,
        device.web_info.browser_version,

        -- Geography
        geo.continent,
        geo.sub_continent,
        geo.country,
        geo.region,
        geo.city,

        -- Acquisition
        traffic_source.source as traffic_source,
        traffic_source.medium as traffic_medium,

        -- Platform
        platform,
        event_dimensions.hostname,

        -- Ecommerce
        ecommerce.total_item_quantity,
        ecommerce.purchase_revenue_in_usd,
        ecommerce.purchase_revenue,
        ecommerce.tax_value_in_usd,
        ecommerce.tax_value,
        ecommerce.unique_items,
        ecommerce.transaction_id

    from source

)

select *
from staged