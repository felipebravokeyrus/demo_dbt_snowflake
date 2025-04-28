-- models/intermediate/int_product_performance_monthly.sql
{{ config(materialized='view', schema='intermediate') }}
WITH monthly_performance AS (
    SELECT
        product_id,
        DATE_TRUNC('month', date) AS month,
        AVG(daily_return) AS avg_daily_return,
        MAX(cumulative_return) AS end_month_return,
        AVG(volatility_30d) AS avg_volatility,
        AVG(sharpe_ratio) AS avg_sharpe_ratio,
        AVG(var_95) AS avg_var
    FROM {{ ref('stg_risk_product_performance') }}
    WHERE date >= DATEADD(month, -12, CURRENT_DATE())
    GROUP BY product_id, DATE_TRUNC('month', date)
)
SELECT
    mp.*,
    rp.product_name,
    rp.product_type,
    rp.risk_category,
    rp.management_fee_percentage,
    mp.end_month_return - (rp.management_fee_percentage/12) AS net_monthly_return,
    mp.end_month_return - COALESCE(bm.monthly_return, 0) AS benchmark_alpha
FROM monthly_performance mp
JOIN {{ ref('stg_product_retirement_products') }} rp ON mp.product_id = rp.product_id
LEFT JOIN {{ ref('int_benchmark_monthly_returns') }} bm ON mp.month = bm.month AND rp.risk_category = bm.risk_category;
