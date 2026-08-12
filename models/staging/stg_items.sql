with source as (

    select *
    from {{ source('ga4_raw', 'ga4_events_raw') }}

),

items as (

    select

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

        item.item_id,
        item.item_name,
        nullif(item.item_brand, '(not set)') as item_brand,

        nullif(
            trim(regexp_replace(item.item_category, r'/+$', '')),
            '(not set)'
        ) as item_category,

        split(
            trim(regexp_replace(item.item_category, r'/+$', '')),
            '/'
        )[safe_offset(0)] as category_level_1,

        split(
            trim(regexp_replace(item.item_category, r'/+$', '')),
            '/'
        )[safe_offset(1)] as category_level_2,

        split(
            trim(regexp_replace(item.item_category, r'/+$', '')),
            '/'
        )[safe_offset(2)] as category_level_3,

        item.price,
        item.quantity,
        item.item_revenue,

        nullif(item.item_list_name, '(not set)') as item_list_name,
        nullif(item.promotion_name, '(not set)') as promotion_name,
        nullif(item.creative_name, '(not set)') as creative_name

    from source,
    unnest(items) as item

)

select *
from items