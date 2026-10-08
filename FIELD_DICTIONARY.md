# GA4 Ecommerce Data Dictionary

This document describes the event data used in the Google Merchandise Store analytics project. It explains the raw BigQuery fields, nested records, event parameters and missing-value conventions used for analysis.

## Dataset context

The project uses Google's obfuscated GA4 ecommerce sample dataset, modelled in BigQuery with dbt. The analysed extract contains **4,295,584 events**. Placeholder values and obfuscation limit the interpretation of some attributes.

The dictionary covers the event parameters identified in the project's availability assessment and standard GA4 export fields relevant to this historical dataset. Field availability varies by event type, platform and schema version. Definitions for optional fields apply where those fields exist in the raw table; the dbt schema inventory provides the physical column list.

## Data structure and analytical grain

Each raw-table row represents one recorded event. A `STRUCT` groups related fields, while an `ARRAY` contains zero or more records. The main repeated fields are:

| Field | Contents | Grain after expansion |
|---|---|---|
| `event_params` | Event parameter names and typed values | One parameter record per event |
| `user_properties` | User attribute names and typed values | One property record per event |
| `items` | Products associated with shopping or promotion activity | One item record per event |

Expanding repeated fields can increase the row count. Event, session and transaction counts should therefore be calculated at their intended grain. Numeric values and timestamps may appear as quoted strings in JSON exports even when their BigQuery types are numeric.

## Event and identity columns

| Column | Meaning / interpretation |
|---|---|
| event_date | Recorded event date, YYYYMMDD, in the property's timezone. |
| event_timestamp | Event receipt time, UTC microseconds since Unix epoch; use TIMESTAMP_MICROS for conversion. |
| event_previous_timestamp | Previous event time, microseconds, when supplied. |
| event_name | Recorded action/type, such as page_view or purchase. |
| event_value_in_usd | Event value converted to USD. Not populated for every event. |
| event_bundle_sequence_id | Identifier/sequence of the uploaded event bundle; not a unique event key. |
| event_server_timestamp_offset | Collection-to-upload offset in microseconds. |
| user_id | Site/app-assigned user identity; optional, typically available after identification/login. |
| user_pseudo_id | Pseudonymous browser/device/app-instance identity; not a guaranteed unique human. |
| user_first_touch_timestamp | First recorded visit/open time, UTC microseconds. |
| stream_id | Identifier of the data stream. |
| platform | Collection platform, e.g. WEB, ANDROID or IOS. |
| event_params | Repeated event key/value records; keys depend on event and implementation. |
| user_properties | Repeated user attributes set by the implementation. |
| items | Repeated product records attached to shopping/promotion events. |

These definitions follow the GA4 export schema. Newer export fields may be absent from this historical dataset. See the [GA4 BigQuery export schema](https://support.google.com/analytics/answer/7029846).

## Typed key/value structure

| Field | Meaning |
|---|---|
| event_params.key | Parameter name, e.g. ga_session_id. |
| event_params.value | Container for the value's type alternatives. |
| event_params.value.string_value / int_value / double_value / float_value | Alternative slots for one parameter's value: text, integer, double-precision or floating-point. |
| user_properties.key | User-attribute name. |
| user_properties.value.string_value / int_value / double_value / float_value | Alternative slots for one property's value: text, integer, double-precision or floating-point. |
| user_properties.value.set_timestamp_micros | Time the property was last set, in microseconds. |

The `float_value` slot is normally unused in GA4 exports. One populated slot is usually enough. For example, `{int_value: 1}` is complete even though its text and other numeric slots are null. `{value:{}}` has no usable value. An absent key is a separate case.

## Event parameters

These are logical fields in `event_params`, not separate physical raw-table columns.

| Parameter | Definition | Missing interpretation |
|---|---|---|
| ga_session_id | Session identifier; combine with user_pseudo_id for session counting. | Missing values prevent reliable session assignment. |
| ga_session_number | Visit/session sequence number associated with that recognised browser/device. | Not a substitute for a session key. |
| page_location | Page URL where the event was recorded. | Important for page/path analysis. |
| page_title | Page title. | URL can still identify the page. |
| page_referrer | Referring page URL supplied with the event. | Can be empty on direct entry or when referrer information is unavailable. |
| session_engaged | Exported session-engagement flag; commonly text 0/1. | Assessed across the session; missing values are not automatically 0. |
| engaged_session_event | Collection-side engagement-related flag in this dataset. | Its relationship to session_engaged requires validation for this historical implementation. |
| engagement_time_msec | Additional foreground/focus engagement time recorded with an event, in milliseconds. | Not total session duration; missing is not proof of no engagement. |
| entrances | Entry-page marker, commonly 1 on an entrance page_view. | Not required on every page view or every event. |
| percent_scrolled | Scroll threshold recorded with a scroll event; often 90. | A threshold marker, not a continuous record of maximum scroll depth. |
| source | Traffic-origin value collected with the event, e.g. google or a referring domain. | Not guaranteed to be available on each event or equal to first-user source. |
| medium | Traffic method, e.g. organic, cpc, referral or (none). | (none) is meaningful, especially for direct traffic. |
| campaign | Campaign value collected with the event. | Values like (direct)/(organic)/(referral) remain non-missing. |
| term | Acquisition/campaign keyword or term. | Different from the visitor's on-site search_term; obfuscation limits interpretation. |
| gclid | Google advertising click ID. | Mainly applicable to relevant ad clicks; absent does not prove a tracking defect. |
| gclsrc | Metadata about the origin of a Google click identifier. | Only relevant when such advertising tagging is present. |
| dclid | Display advertising click identifier. | Mainly relevant to applicable display advertising clicks. |
| search_term | Visitor's on-site search query. | Coverage is assessed on view_search_results events. |
| unique_search_term | Marker that the query is unique within the session, generally 1 when emitted. | Absence can be expected for repeat searches within a session. |
| currency | Currency code for monetary values, e.g. USD. | Monetary comparisons require a common currency or conversion. |
| transaction_id | Transaction identifier supplied in event parameters. | Coverage is assessed on purchases, separately from ecommerce.transaction_id. |
| value | Monetary value attached to the event. For purchase, normally item totals excluding shipping/tax. | Interpretation depends on event; zero remains a valid recorded value. |
| tax | Tax amount supplied with an order/event. | Optional field; missing is not automatically zero. |
| payment_type | Payment method label supplied by implementation. | Normally associated with payment information; also recorded on purchase events in this dataset. |
| shipping_tier | Shipping service/category label. | Normally associated with shipping-information events; placement depends on the implementation. |
| coupon | Coupon code recorded at event level. | Missing values may indicate that no coupon was used. |
| promotion_name | Recorded promotion name. | Coverage may span event-level parameters and item-level fields. |
| outbound | Flag indicating an external-link click. | Relevant to applicable click events; false is not missing. |
| link_domain | Clicked link's domain. | Coverage is assessed on relevant link-click events. |
| link_url | Clicked link's destination URL. | Coverage is assessed on relevant link-click events. |
| link_classes | CSS class names of the clicked element. | Optional DOM metadata; little business meaning without implementation context. |
| debug_mode | Debug collection indicator. | The flag alone does not establish that a record should be excluded from this obfuscated dataset. |
| clean_event | Implementation-specific parameter; observed value includes gtm.js. | Observed value resembles a GTM lifecycle label; intended meaning is not confirmed. |
| all_data | Implementation-specific parameter with no usable values in the availability assessment. | Its intended business meaning is undocumented. |

## User lifetime value and consent

| Column | Meaning / interpretation |
|---|---|
| user_ltv.revenue | Cumulative revenue recorded for the recognised user; repeated event-level values are not additive. |
| user_ltv.currency | Currency of the lifetime value. |
| privacy_info.ads_storage | Advertising-storage consent status. |
| privacy_info.analytics_storage | Analytics-storage consent status. |
| privacy_info.uses_transient_token | Whether collection used transient tokens in the applicable consent setup. |

Consent statuses `Yes`, `No` and `Unset` are retained as recorded categories rather than classified as missing.

## Device fields

| Column | Meaning |
|---|---|
| device.category | Device class: desktop, mobile or tablet. |
| device.mobile_brand_name | Manufacturer/brand. |
| device.mobile_model_name | Device model. |
| device.mobile_marketing_name | Consumer-facing device name. |
| device.mobile_os_hardware_model | Hardware model supplied by the operating system. |
| device.operating_system | Recorded OS/platform label; values include Web in this dataset. |
| device.operating_system_version | OS version. |
| device.vendor_id | Vendor device identifier, principally app/iOS context. |
| device.advertising_id | Advertising device identifier, where available. |
| device.language | Recorded device/OS language. |
| device.time_zone_offset_seconds | Device offset from GMT in seconds. |
| device.is_limited_ad_tracking | Recorded limit-ad-tracking setting; represented as Yes/No text in the inspected export. |
| device.web_info.browser | Browser family. |
| device.web_info.browser_version | Browser version. |
| device.web_info.hostname | Page hostname, if this column exists. |

Mobile/app identifiers may legitimately be null in web data. `<Other>` is a coarse category and does not recover a specific brand/model/version.

## Geography and first-user acquisition

| Column | Meaning |
|---|---|
| geo.continent | IP-derived continent. |
| geo.sub_continent | IP-derived subcontinent. |
| geo.country | IP-derived country. |
| geo.region | IP-derived region/state. |
| geo.city | IP-derived city. |
| geo.metro | IP-derived metropolitan area. |
| traffic_source.source | Source associated with first-user acquisition. |
| traffic_source.medium | Medium associated with first-user acquisition. |
| traffic_source.name | Campaign associated with first-user acquisition. |

`traffic_source.*` is user acquisition context, while source/medium/campaign in event_params reflect collected event context. They need not agree. Geography is approximate, not a verified residential address.

## Ecommerce STRUCT

| Column | Meaning |
|---|---|
| ecommerce.total_item_quantity | Total recorded units across items for the ecommerce event. |
| ecommerce.purchase_revenue_in_usd | Purchase revenue in USD. |
| ecommerce.purchase_revenue | Purchase revenue in local/reported currency. |
| ecommerce.refund_value_in_usd | Refund amount in USD. |
| ecommerce.refund_value | Refund amount in local/reported currency. |
| ecommerce.shipping_value_in_usd | Shipping amount in USD. |
| ecommerce.shipping_value | Shipping amount in local/reported currency. |
| ecommerce.tax_value_in_usd | Tax amount in USD. |
| ecommerce.tax_value | Tax amount in local/reported currency. |
| ecommerce.unique_items | Number of distinct items recorded for the event. |
| ecommerce.transaction_id | Transaction ID in the ecommerce STRUCT. |

Purchase revenue coverage is assessed on purchase events, and refund coverage on refund events. Empty ecommerce records can be expected on unrelated events. The event parameter transaction_id and ecommerce.transaction_id are separate fields; their completeness and formatting require independent validation before reconciliation.

## Product/item records

Each element of the items array represents a product associated with an event. The following standard item definitions apply where the corresponding fields exist in the raw table.

| Item column | Meaning |
|---|---|
| items.item_id | Product identifier/SKU. |
| items.item_name | Product name. |
| items.item_brand | Product brand. |
| items.item_variant | Product variant, e.g. size/colour. |
| items.item_category | First-level category. |
| items.item_category2 | Second-level category. |
| items.item_category3 | Third-level category. |
| items.item_category4 | Fourth-level category. |
| items.item_category5 | Fifth-level category. |
| items.price_in_usd | Recorded per-unit price in USD. |
| items.price | Recorded per-unit price in reported currency. |
| items.quantity | Recorded item units. |
| items.item_revenue_in_usd | Item purchase revenue in USD. |
| items.item_revenue | Item purchase revenue in reported currency. |
| items.item_refund_in_usd | Item refund amount in USD. |
| items.item_refund | Item refund amount in reported currency. |
| items.coupon | Item-level coupon. |
| items.affiliation | Store/affiliation label attached to the item. |
| items.location_id | Location identifier attached to the item. |
| items.item_list_id | Identifier of the list containing the item. |
| items.item_list_name | Name of the list containing the item. |
| items.item_list_index | Item's position in that list. |
| items.promotion_id | Promotion identifier. |
| items.promotion_name | Promotion label. |
| items.creative_name | Associated promotional creative name. |
| items.creative_slot | Placement of the promotional creative. |

Additional fields in newer schemas may include `items.discount` (per-unit discount) and `items.item_params` (custom item key/value attributes). Their presence is schema-dependent.

## App fields, if physically present

| Column | Meaning |
|---|---|
| app_info.id | App package/bundle identifier. |
| app_info.version | App version. |
| app_info.install_store | Store associated with the install. |
| app_info.firebase_app_id | Firebase app identifier. |
| app_info.install_source | Source of the app installation. |

These can legitimately be empty in a WEB dataset.

## Missing-value conventions

The project's missing-data audit applies the following rules consistently across fields.

| Value or condition | Classification | Interpretation |
|---|---|---|
| SQL `NULL` | Missing | No value is recorded. |
| `deleted`, `<deleted>` or `(deleted)` | Missing | Deletion placeholder; the original value is unavailable. |
| `(not set)` | Missing | No specific attribute value is available. |
| Empty or whitespace-only string | Missing | The field contains no substantive value. |
| Literal text `null` | Missing | Text placeholder for an unavailable value. |
| Absent parameter key | Missing: absent key | The event does not contain the parameter. |
| Parameter key with all typed values null | Missing: empty value | The parameter exists but has no recorded value. |
| Empty repeated array | Empty-array coverage gap | No records exist in the array; this may be expected for the event. |
| `<Other>` or `Other` | Non-missing, limited detail | A broad category without the original specific attribute. |
| `<obfuscated>` or `obfuscated` | Non-missing, obscured detail | A recorded placeholder with limited analytical meaning. |
| `0` or `false` | Non-missing | Valid recorded values. |
| `(direct)`, `(none)`, `(organic)` or `(referral)` | Non-missing | Meaningful acquisition labels. |

Text comparisons are case insensitive and ignore leading/trailing whitespace. Blank-string and literal-null checks supplement the project's core null, deleted and `(not set)` rule.

### Interpreting completeness

- **Event applicability:** A field can be missing because it is irrelevant to the event. Purchase revenue is assessed on purchases, search terms on search events and link attributes on link clicks.
- **Typed values:** The string, integer, double and float slots are alternatives. A parameter is complete when an appropriate slot contains a value; nulls in its unused slots are expected.
- **Item coverage:** Empty items arrays are measured at event level. Completeness of item attributes is measured among existing item records. Both measures are needed to assess product-data availability.
- **Optional attributes:** Missing coupons, campaign terms and app-specific fields do not automatically indicate tracking failures.
- **Obfuscation:** Placeholder values can preserve broad categories while preventing detailed attribution or product/device interpretation.

The parameter availability assessment identified zero usable values for `gclid`, `gclsrc`, `dclid` and `all_data`. This finding describes value availability; the audit separately distinguishes absent keys from present keys with empty values. The assessment counted 5,242 usable purchase transaction-ID and value parameters against 5,692 purchase events (approximately 92.1% coverage), subject to the assessment's value-classification rules.

## References

- [GA4 BigQuery export schema](https://support.google.com/analytics/answer/7029846)
- [Google Analytics ecommerce sample dataset](https://developers.google.com/analytics/bigquery/web-ecommerce-demo-dataset)
- [User engagement](https://support.google.com/analytics/answer/11109416)
- [Automatically collected events](https://support.google.com/analytics/answer/9234069)
- [Recommended events and ecommerce parameters](https://developers.google.com/analytics/devguides/collection/ga4/reference/events)
- [GA4 configuration fields](https://developers.google.com/analytics/devguides/collection/ga4/reference/config)
