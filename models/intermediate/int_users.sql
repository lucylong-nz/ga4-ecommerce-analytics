with sessions as (

    select *
    from {{ ref('int_sessions') }}

),

dataset_end as (

    select
        max(date(event_timestamp)) as dataset_end_date
    from {{ ref('stg_events') }}

),

users as (

    select
        user_pseudo_id,

        min(user_first_touch_timestamp) as user_first_touch_timestamp,
        max(session_end) as last_session_end,

        -- Recency / lifetime
        date_diff(
            (select dataset_end_date from dataset_end),
            date(max(session_end)),
            day
        ) as days_since_last_visit,

        date_diff(
            date(max(session_end)),
            date(min(user_first_touch_timestamp)),
            day
        ) as customer_age_days,

        -- Lifetime metrics
        count(*) as total_sessions,
        sum(total_events) as total_events,
        sum(page_views) as total_page_views,
        sum(purchases) as total_purchases,
        sum(revenue) as total_revenue,
        sum(is_engaged_session) as engaged_sessions,

        safe_divide(
            sum(is_engaged_session),
            count(*)
        ) as engagement_rate,

        safe_divide(
            sum(revenue),
            count(*)
        ) as revenue_per_session,

        avg(session_duration_seconds) as avg_session_duration_seconds,
        avg(engagement_time_seconds) as avg_engagement_time_seconds,

        case
            when sum(purchases) > 0 then 1
            else 0
        end as has_purchased,

        -- Last 30 days
        countif(
            date(session_end) >
            date_sub(
                (select dataset_end_date from dataset_end),
                interval 30 day
            )
        ) as sessions_last_30d,

        sum(
            case
                when date(session_end) >
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 30 day
                    )
                then purchases
                else 0
            end
        ) as purchases_last_30d,

        sum(
            case
                when date(session_end) >
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 30 day
                    )
                then revenue
                else 0
            end
        ) as revenue_last_30d,

        sum(
            case
                when date(session_end) >
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 30 day
                    )
                then is_engaged_session
                else 0
            end
        ) as engaged_sessions_last_30d,

        -- Previous 30 days
        countif(
            date(session_end) >
                date_sub(
                    (select dataset_end_date from dataset_end),
                    interval 60 day
                )
            and date(session_end) <=
                date_sub(
                    (select dataset_end_date from dataset_end),
                    interval 30 day
                )
        ) as sessions_previous_30d,

        sum(
            case
                when date(session_end) >
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 60 day
                    )
                and date(session_end) <=
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 30 day
                    )
                then purchases
                else 0
            end
        ) as purchases_previous_30d,

        sum(
            case
                when date(session_end) >
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 60 day
                    )
                and date(session_end) <=
                    date_sub(
                        (select dataset_end_date from dataset_end),
                        interval 30 day
                    )
                then revenue
                else 0
            end
        ) as revenue_previous_30d

    from sessions

    group by user_pseudo_id

)

select *
from users