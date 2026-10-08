{{ config(materialized='table') }}

-- ============================================================
-- GA4 Event Parameter Quality Profile
--
-- Purpose:
-- Profile parameter availability and completeness by event type.
--
-- Important distinction:
--   presence_pct     = how often the parameter exists
--   empty_value_pct  = when it exists, how often its value is empty
--   usable_value_pct = how often the event has a usable parameter value
-- ============================================================


WITH event_counts AS (

    SELECT
        event_name,
        COUNT(*) AS event_count

    FROM `linen-jet-504701-k8.analytics_raw.ga4_events_raw`

    GROUP BY event_name
),


params AS (

    SELECT
        e.event_name,
        p.key AS parameter,

        COALESCE(
            p.value.string_value,
            CAST(p.value.int_value AS STRING),
            CAST(p.value.float_value AS STRING),
            CAST(p.value.double_value AS STRING)
        ) AS parameter_value

    FROM `linen-jet-504701-k8.analytics_raw.ga4_events_raw` AS e
    CROSS JOIN UNNEST(e.event_params) AS p
),


parameter_profile AS (

    SELECT
        event_name,
        parameter,

        COUNT(*) AS occurrences,

        COUNTIF(parameter_value IS NULL) AS empty_value_count,

        COUNTIF(parameter_value IS NOT NULL) AS usable_value_count,

        COUNT(DISTINCT parameter_value) AS distinct_values

    FROM params

    GROUP BY
        event_name,
        parameter
)


SELECT
    p.event_name,

    p.parameter,

    e.event_count,

    p.occurrences AS parameter_occurrences,

    -- How many events contain this parameter?
    ROUND(
        SAFE_DIVIDE(
            p.occurrences,
            e.event_count
        ) * 100,
        2
    ) AS presence_pct,

    -- Parameter exists but its value is empty
    p.empty_value_count,

    ROUND(
        SAFE_DIVIDE(
            p.empty_value_count,
            p.occurrences
        ) * 100,
        2
    ) AS empty_value_pct,

    -- Parameter exists and contains a usable value
    p.usable_value_count,

    ROUND(
        SAFE_DIVIDE(
            p.usable_value_count,
            e.event_count
        ) * 100,
        2
    ) AS usable_value_pct,

    p.distinct_values

FROM parameter_profile AS p

LEFT JOIN event_counts AS e
    ON p.event_name = e.event_name

ORDER BY
    p.event_name,
    presence_pct DESC,
    p.parameter