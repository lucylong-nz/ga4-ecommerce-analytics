with source as (

    select *
    from {{ source('ga4_raw', 'ga4_events_raw') }}

),

event_params as (

    select

        -- Stable event key
        to_hex(md5(concat(
            coalesce(user_pseudo_id, ''),
            '|',
            cast(event_timestamp as string),
            '|',
            coalesce(event_name, ''),
            '|',
            cast(coalesce(event_bundle_sequence_id, 0) as string)
        ))) as event_key,

        parse_date('%Y%m%d', event_date) as event_date,
        timestamp_micros(event_timestamp) as event_timestamp,
        event_name,
        user_pseudo_id,

        ep.key as parameter_key,

        coalesce(
            ep.value.string_value,
            cast(ep.value.int_value as string),
            cast(ep.value.float_value as string),
            cast(ep.value.double_value as string)
        ) as parameter_value,

        case
            when ep.value.string_value is not null then 'STRING'
            when ep.value.int_value is not null then 'INT64'
            when ep.value.float_value is not null then 'FLOAT64'
            when ep.value.double_value is not null then 'FLOAT64'
            else 'NULL'
        end as parameter_type

    from source,
    unnest(event_params) as ep

)

select *
from event_params