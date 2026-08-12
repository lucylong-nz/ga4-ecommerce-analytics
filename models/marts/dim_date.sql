with dates as (

    select distinct
        date(session_start) as date_day
    from {{ ref('int_sessions') }}

)

select
    date_day,
    extract(year from date_day) as year,
    extract(month from date_day) as month,
    format_date('%B', date_day) as month_name,
    extract(quarter from date_day) as quarter,
    extract(week from date_day) as week,
    extract(day from date_day) as day,
    format_date('%A', date_day) as day_name,

    case
        when extract(dayofweek from date_day) in (1, 7)
        then true
        else false
    end as is_weekend

from dates