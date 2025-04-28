
SELECT
    product_id,
    product_name,
    risk_category,
    avg_volatility
FROM {{ ref('int_product_performance_monthly') }}
WHERE (risk_category = 'low' AND avg_volatility > 0.1)
   OR (risk_category = 'medium' AND (avg_volatility < 0.05
