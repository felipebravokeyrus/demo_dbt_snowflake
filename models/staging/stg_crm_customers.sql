
-- models/staging/stg_crm_customers.sql
{{ config(materialized='view', schema='staging') }}
WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_crm.customers') }}
)
SELECT
    customer_id,
    first_name,
    last_name,
    birth_date,
    postal_code,
    city,
    email,
    registration_date,
    CASE
        WHEN risk_profile = 'securise' THEN 'conservative'
        WHEN risk_profile = 'equilibre' THEN 'moderate'
        WHEN risk_profile = 'dynamique' THEN 'aggressive'
        ELSE 'unknown'
    END AS risk_profile,
    occupation,
    monthly_income,
    DATEDIFF('year', birth_date, CURRENT_DATE()) AS age,
    CURRENT_TIMESTAMP() AS _loaded_at
FROM source;
