{{ config(materialized='table') }}

WITH base AS (

    SELECT *
    FROM `linen-jet-504701-k8.analytics_raw.ga4_events_raw`

),

total AS (
    SELECT COUNT(*) AS total_rows
    FROM base
),

profile AS (

    -- ============================================================
    -- EVENT
    -- ============================================================

    SELECT
        'Event' AS variable_group,
        'event_date' AS variable,
        'SCALAR' AS field_type,
        COUNT(*) AS total_rows,
        COUNTIF(event_date IS NOT NULL) AS valid_rows,
        COUNTIF(event_date IS NULL) AS missing_rows,
        0 AS not_set_rows,
        0 AS other_rows,
        COUNT(DISTINCT event_date) AS distinct_values
    FROM base

    UNION ALL

    SELECT
        'Event', 'event_timestamp', 'SCALAR',
        COUNT(*),
        COUNTIF(event_timestamp IS NOT NULL),
        COUNTIF(event_timestamp IS NULL),
        0, 0,
        COUNT(DISTINCT event_timestamp)
    FROM base

    UNION ALL

    SELECT
        'Event', 'event_name', 'SCALAR',
        COUNT(*),
        COUNTIF(event_name IS NOT NULL),
        COUNTIF(event_name IS NULL),
        COUNTIF(event_name = '(not set)'),
        COUNTIF(event_name = '<Other>'),
        COUNT(DISTINCT event_name)
    FROM base

    UNION ALL

    SELECT
        'Event', 'event_bundle_sequence_id', 'SCALAR',
        COUNT(*),
        COUNTIF(event_bundle_sequence_id IS NOT NULL),
        COUNTIF(event_bundle_sequence_id IS NULL),
        0, 0,
        COUNT(DISTINCT event_bundle_sequence_id)
    FROM base


    -- ============================================================
    -- USER
    -- ============================================================

    UNION ALL

    SELECT
        'User', 'user_pseudo_id', 'SCALAR',
        COUNT(*),
        COUNTIF(user_pseudo_id IS NOT NULL),
        COUNTIF(user_pseudo_id IS NULL),
        0, 0,
        COUNT(DISTINCT user_pseudo_id)
    FROM base

    UNION ALL

    SELECT
        'User', 'user_id', 'SCALAR',
        COUNT(*),
        COUNTIF(user_id IS NOT NULL),
        COUNTIF(user_id IS NULL),
        0, 0,
        COUNT(DISTINCT user_id)
    FROM base

    UNION ALL

    SELECT
        'User', 'user_first_touch_timestamp', 'SCALAR',
        COUNT(*),
        COUNTIF(user_first_touch_timestamp IS NOT NULL),
        COUNTIF(user_first_touch_timestamp IS NULL),
        0, 0,
        COUNT(DISTINCT user_first_touch_timestamp)
    FROM base


    -- ============================================================
    -- USER PROPERTIES
    -- ============================================================

    UNION ALL

    SELECT
        'User Properties', 'user_properties', 'ARRAY<STRUCT>',
        COUNT(*),
        COUNTIF(ARRAY_LENGTH(user_properties) > 0),
        COUNTIF(
            user_properties IS NULL
            OR ARRAY_LENGTH(user_properties) = 0
        ),
        0, 0,
        NULL
    FROM base


    -- ============================================================
    -- USER LTV
    -- ============================================================

    UNION ALL

    SELECT
        'User LTV', 'user_ltv.revenue', 'STRUCT',
        COUNT(*),
        COUNTIF(user_ltv.revenue IS NOT NULL),
        COUNTIF(user_ltv.revenue IS NULL),
        0, 0,
        COUNT(DISTINCT user_ltv.revenue)
    FROM base

    UNION ALL

    SELECT
        'User LTV', 'user_ltv.currency', 'STRUCT',
        COUNT(*),
        COUNTIF(user_ltv.currency IS NOT NULL),
        COUNTIF(user_ltv.currency IS NULL),
        COUNTIF(user_ltv.currency = '(not set)'),
        COUNTIF(user_ltv.currency = '<Other>'),
        COUNT(DISTINCT user_ltv.currency)
    FROM base


    -- ============================================================
    -- PRIVACY
    -- ============================================================

    UNION ALL

    SELECT
        'Privacy', 'privacy_info.analytics_storage', 'STRUCT',
        COUNT(*),
        COUNTIF(privacy_info.analytics_storage IS NOT NULL),
        COUNTIF(privacy_info.analytics_storage IS NULL),
        COUNTIF(CAST(privacy_info.analytics_storage AS STRING) = '(not set)'),
        COUNTIF(CAST(privacy_info.analytics_storage AS STRING) = '<Other>'),
        COUNT(DISTINCT privacy_info.analytics_storage)
    FROM base

    UNION ALL

    SELECT
        'Privacy', 'privacy_info.ads_storage', 'STRUCT',
        COUNT(*),
        COUNTIF(privacy_info.ads_storage IS NOT NULL),
        COUNTIF(privacy_info.ads_storage IS NULL),
        COUNTIF(CAST(privacy_info.ads_storage AS STRING) = '(not set)'),
        COUNTIF(CAST(privacy_info.ads_storage AS STRING) = '<Other>'),
        COUNT(DISTINCT privacy_info.ads_storage)
    FROM base

    UNION ALL

    SELECT
        'Privacy', 'privacy_info.uses_transient_token', 'STRUCT',
        COUNT(*),
        COUNTIF(privacy_info.uses_transient_token IS NOT NULL),
        COUNTIF(privacy_info.uses_transient_token IS NULL),
        COUNTIF(CAST(privacy_info.uses_transient_token AS STRING) = '(not set)'),
        COUNTIF(CAST(privacy_info.uses_transient_token AS STRING) = '<Other>'),
        COUNT(DISTINCT privacy_info.uses_transient_token)
    FROM base
    
    -- ============================================================
    -- DEVICE
    -- ============================================================

    UNION ALL

    SELECT
        'Device', 'device.category', 'STRUCT',
        COUNT(*),
        COUNTIF(device.category IS NOT NULL),
        COUNTIF(device.category IS NULL),
        COUNTIF(device.category = '(not set)'),
        COUNTIF(device.category = '<Other>'),
        COUNT(DISTINCT device.category)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.mobile_brand_name', 'STRUCT',
        COUNT(*),
        COUNTIF(device.mobile_brand_name IS NOT NULL),
        COUNTIF(device.mobile_brand_name IS NULL),
        COUNTIF(device.mobile_brand_name = '(not set)'),
        COUNTIF(device.mobile_brand_name = '<Other>'),
        COUNT(DISTINCT device.mobile_brand_name)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.mobile_model_name', 'STRUCT',
        COUNT(*),
        COUNTIF(device.mobile_model_name IS NOT NULL),
        COUNTIF(device.mobile_model_name IS NULL),
        COUNTIF(device.mobile_model_name = '(not set)'),
        COUNTIF(device.mobile_model_name = '<Other>'),
        COUNT(DISTINCT device.mobile_model_name)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.operating_system', 'STRUCT',
        COUNT(*),
        COUNTIF(device.operating_system IS NOT NULL),
        COUNTIF(device.operating_system IS NULL),
        COUNTIF(device.operating_system = '(not set)'),
        COUNTIF(device.operating_system = '<Other>'),
        COUNT(DISTINCT device.operating_system)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.operating_system_version', 'STRUCT',
        COUNT(*),
        COUNTIF(device.operating_system_version IS NOT NULL),
        COUNTIF(device.operating_system_version IS NULL),
        COUNTIF(device.operating_system_version = '(not set)'),
        COUNTIF(device.operating_system_version = '<Other>'),
        COUNT(DISTINCT device.operating_system_version)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.language', 'STRUCT',
        COUNT(*),
        COUNTIF(device.language IS NOT NULL),
        COUNTIF(device.language IS NULL),
        COUNTIF(device.language = '(not set)'),
        COUNTIF(device.language = '<Other>'),
        COUNT(DISTINCT device.language)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.web_info.browser', 'STRUCT',
        COUNT(*),
        COUNTIF(device.web_info.browser IS NOT NULL),
        COUNTIF(device.web_info.browser IS NULL),
        COUNTIF(device.web_info.browser = '(not set)'),
        COUNTIF(device.web_info.browser = '<Other>'),
        COUNT(DISTINCT device.web_info.browser)
    FROM base

    UNION ALL

    SELECT
        'Device', 'device.web_info.browser_version', 'STRUCT',
        COUNT(*),
        COUNTIF(device.web_info.browser_version IS NOT NULL),
        COUNTIF(device.web_info.browser_version IS NULL),
        COUNTIF(device.web_info.browser_version = '(not set)'),
        COUNTIF(device.web_info.browser_version = '<Other>'),
        COUNT(DISTINCT device.web_info.browser_version)
    FROM base


    -- ============================================================
    -- GEO
    -- ============================================================

    UNION ALL

    SELECT
        'Geography', 'geo.continent', 'STRUCT',
        COUNT(*),
        COUNTIF(geo.continent IS NOT NULL),
        COUNTIF(geo.continent IS NULL),
        COUNTIF(geo.continent = '(not set)'),
        COUNTIF(geo.continent = '<Other>'),
        COUNT(DISTINCT geo.continent)
    FROM base

    UNION ALL

    SELECT
        'Geography', 'geo.sub_continent', 'STRUCT',
        COUNT(*),
        COUNTIF(geo.sub_continent IS NOT NULL),
        COUNTIF(geo.sub_continent IS NULL),
        COUNTIF(geo.sub_continent = '(not set)'),
        COUNTIF(geo.sub_continent = '<Other>'),
        COUNT(DISTINCT geo.sub_continent)
    FROM base

    UNION ALL

    SELECT
        'Geography', 'geo.country', 'STRUCT',
        COUNT(*),
        COUNTIF(geo.country IS NOT NULL),
        COUNTIF(geo.country IS NULL),
        COUNTIF(geo.country = '(not set)'),
        COUNTIF(geo.country = '<Other>'),
        COUNT(DISTINCT geo.country)
    FROM base

    UNION ALL

    SELECT
        'Geography', 'geo.region', 'STRUCT',
        COUNT(*),
        COUNTIF(geo.region IS NOT NULL),
        COUNTIF(geo.region IS NULL),
        COUNTIF(geo.region = '(not set)'),
        COUNTIF(geo.region = '<Other>'),
        COUNT(DISTINCT geo.region)
    FROM base

    UNION ALL

    SELECT
        'Geography', 'geo.city', 'STRUCT',
        COUNT(*),
        COUNTIF(geo.city IS NOT NULL),
        COUNTIF(geo.city IS NULL),
        COUNTIF(geo.city = '(not set)'),
        COUNTIF(geo.city = '<Other>'),
        COUNT(DISTINCT geo.city)
    FROM base

    UNION ALL

    SELECT
        'Geography', 'geo.metro', 'STRUCT',
        COUNT(*),
        COUNTIF(geo.metro IS NOT NULL),
        COUNTIF(geo.metro IS NULL),
        COUNTIF(geo.metro = '(not set)'),
        COUNTIF(geo.metro = '<Other>'),
        COUNT(DISTINCT geo.metro)
    FROM base


    -- ============================================================
    -- TRAFFIC SOURCE
    -- ============================================================

    UNION ALL

    SELECT
        'Traffic Source', 'traffic_source.source', 'STRUCT',
        COUNT(*),
        COUNTIF(traffic_source.source IS NOT NULL),
        COUNTIF(traffic_source.source IS NULL),
        COUNTIF(traffic_source.source = '(not set)'),
        COUNTIF(traffic_source.source = '<Other>'),
        COUNT(DISTINCT traffic_source.source)
    FROM base

    UNION ALL

    SELECT
        'Traffic Source', 'traffic_source.medium', 'STRUCT',
        COUNT(*),
        COUNTIF(traffic_source.medium IS NOT NULL),
        COUNTIF(traffic_source.medium IS NULL),
        COUNTIF(traffic_source.medium = '(not set)'),
        COUNTIF(traffic_source.medium = '<Other>'),
        COUNT(DISTINCT traffic_source.medium)
    FROM base

    UNION ALL

    SELECT
        'Traffic Source', 'traffic_source.name', 'STRUCT',
        COUNT(*),
        COUNTIF(traffic_source.name IS NOT NULL),
        COUNTIF(traffic_source.name IS NULL),
        COUNTIF(traffic_source.name = '(not set)'),
        COUNTIF(traffic_source.name = '<Other>'),
        COUNT(DISTINCT traffic_source.name)
    FROM base


    -- ============================================================
    -- PLATFORM
    -- ============================================================

    UNION ALL

    SELECT
        'Platform', 'platform', 'SCALAR',
        COUNT(*),
        COUNTIF(platform IS NOT NULL),
        COUNTIF(platform IS NULL),
        COUNTIF(platform = '(not set)'),
        COUNTIF(platform = '<Other>'),
        COUNT(DISTINCT platform)
    FROM base

    UNION ALL

    SELECT
        'Platform', 'stream_id', 'SCALAR',
        COUNT(*),
        COUNTIF(stream_id IS NOT NULL),
        COUNTIF(stream_id IS NULL),
        0, 0,
        COUNT(DISTINCT stream_id)
    FROM base


    -- ============================================================
    -- ECOMMERCE
    -- ============================================================

    UNION ALL

    SELECT
        'Ecommerce', 'ecommerce.transaction_id', 'STRUCT',
        COUNT(*),
        COUNTIF(ecommerce.transaction_id IS NOT NULL),
        COUNTIF(ecommerce.transaction_id IS NULL),
        0, 0,
        COUNT(DISTINCT ecommerce.transaction_id)
    FROM base

    UNION ALL

    SELECT
        'Ecommerce', 'ecommerce.purchase_revenue', 'STRUCT',
        COUNT(*),
        COUNTIF(ecommerce.purchase_revenue IS NOT NULL),
        COUNTIF(ecommerce.purchase_revenue IS NULL),
        0, 0,
        COUNT(DISTINCT ecommerce.purchase_revenue)
    FROM base

    UNION ALL

    SELECT
        'Ecommerce', 'ecommerce.total_item_quantity', 'STRUCT',
        COUNT(*),
        COUNTIF(ecommerce.total_item_quantity IS NOT NULL),
        COUNTIF(ecommerce.total_item_quantity IS NULL),
        0, 0,
        COUNT(DISTINCT ecommerce.total_item_quantity)
    FROM base


    -- ============================================================
    -- REPEATED ARRAYS
    -- ============================================================

    UNION ALL

    SELECT
        'Event Parameters', 'event_params', 'ARRAY<STRUCT>',
        COUNT(*),
        COUNTIF(ARRAY_LENGTH(event_params) > 0),
        COUNTIF(event_params IS NULL OR ARRAY_LENGTH(event_params) = 0),
        0, 0,
        NULL
    FROM base

    UNION ALL

    SELECT
        'Items', 'items', 'ARRAY<STRUCT>',
        COUNT(*),
        COUNTIF(ARRAY_LENGTH(items) > 0),
        COUNTIF(items IS NULL OR ARRAY_LENGTH(items) = 0),
        0, 0,
        NULL
    FROM base
)

SELECT
    variable_group,
    variable,
    field_type,

    total_rows,
    valid_rows,
    missing_rows,

    ROUND(
        SAFE_DIVIDE(valid_rows, total_rows) * 100,
        2
    ) AS valid_pct,

    ROUND(
        SAFE_DIVIDE(missing_rows, total_rows) * 100,
        2
    ) AS missing_pct,

    not_set_rows,

    ROUND(
        SAFE_DIVIDE(not_set_rows, total_rows) * 100,
        2
    ) AS not_set_pct,

    other_rows,

    ROUND(
        SAFE_DIVIDE(other_rows, total_rows) * 100,
        2
    ) AS other_pct,

    distinct_values

FROM profile
ORDER BY
    variable_group,
    missing_pct DESC