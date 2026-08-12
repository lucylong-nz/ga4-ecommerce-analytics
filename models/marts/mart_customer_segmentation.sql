with users as (

    select *
    from {{ ref('int_users') }}

),

dataset_end as (

    select
        max(date(event_timestamp)) as dataset_end_date
    from {{ ref('stg_events') }}

),

segmented as (

    select
        u.*,

        -- Basic flags
        case
            when total_purchases > 0 then 1
            else 0
        end as is_purchaser,

        case
            when total_purchases >= 2 then 1
            else 0
        end as is_repeat_customer,

        case
            when total_revenue >= 176 then 1
            else 0
        end as is_high_value,

        case
            when days_since_last_visit >= 30
                 and total_sessions >= 2
            then 1
            else 0
        end as is_at_risk,

        # null in user_first_touch_timestamp: 4,433 of 270,154 users (1.64%)
        case
            when user_first_touch_timestamp is null then null

            when date_diff(
                (select dataset_end_date from dataset_end),
                date(user_first_touch_timestamp),
                day
            ) <= 7 then 1

            else 0
        end as is_new_user,

        case
            when sessions_previous_30d > 0
            and sessions_last_30d < sessions_previous_30d * 0.5
            then 1 else 0
        end as is_declining

    from users u
),

final as (

    select
        *,

        case
            when is_high_value = 1
                 and is_at_risk = 1
                then 'High Value - At Risk'

            when is_high_value = 1
                then 'High Value'

            when is_repeat_customer = 1
                then 'Repeat Customer'

            when is_at_risk = 1
                 and is_purchaser = 1
                then 'At Risk Customer'

            when is_declining = 1 and is_purchaser = 1
                then 'Declining Customer'

            when is_new_user = 1
                then 'New User'

            when is_purchaser = 1
                then 'Customer'

            when days_since_last_visit < 30
                then 'Active Prospect'

            else 'Inactive Prospect'
        end as customer_segment

    from segmented

)

select *
from final