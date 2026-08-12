with channels as (

    select distinct
        traffic_source,
        traffic_medium
    from {{ ref('int_sessions') }}

)

select

    to_hex(md5(concat(
        coalesce(traffic_source, ''),
        '|',
        coalesce(traffic_medium, '')
    ))) as channel_key,

    traffic_source,  

    case
        when lower(traffic_source) like '%.safeframe.googlesyndication.com'
            then 'Google Ads'

        when lower(traffic_source) like '%.search.yahoo.com'
            then 'Yahoo'

        when lower(traffic_source) in (
            'qwiklabs.com',
            'run.qwiklabs.com',
            'jumpstart.qwiklabs.com',
            'google-run.qwiklabs.com'
        )
            then 'Qwiklabs'

        when lower(traffic_source) in (
            'm.youtube.com',
            'creatoracademy.youtube.com'
        )
            then 'YouTube'

        when lower(traffic_source) in (
            'facebook.com',
            'l.messenger.com'
        )
            then 'Facebook'

        when lower(traffic_source) = 't.co'
            then 'Twitter / X'

        else traffic_source
    end as traffic_source_clean,
    traffic_medium,

    case
        when traffic_source = '(direct)'
         and traffic_medium = '(none)'
            then 'Direct'

        when lower(traffic_medium) = 'organic'
            then 'Organic Search'

        when lower(traffic_medium) = 'cpc'
            then 'Paid Search'

        when lower(traffic_medium) = 'referral'
            then 'Referral'

        when lower(traffic_medium) = 'affiliate'
            then 'Affiliate'

        when lower(traffic_medium) = 'email'
            then 'Email'

        when traffic_medium = '(data deleted)'
            then 'Data Deleted'

        when traffic_medium = '<Other>'
            then 'Other'

        else 'Other'
    end as channel_group

from channels