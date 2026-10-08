{{ config(materialized='table') }}

SELECT
    event_name,

    COUNT(*) AS event_count,

    ROUND(
        SAFE_DIVIDE(COUNT(*), SUM(COUNT(*)) OVER()) * 100,
        2
    ) AS event_pct,

    COUNT(DISTINCT user_pseudo_id) AS users,

    COUNTIF(ARRAY_LENGTH(items) > 0) AS events_with_items,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(ARRAY_LENGTH(items) > 0),
            COUNT(*)
        ) * 100,
        2
    ) AS pct_with_items

FROM `linen-jet-504701-k8.analytics_raw.ga4_events_raw`

GROUP BY event_name
ORDER BY event_count DESC