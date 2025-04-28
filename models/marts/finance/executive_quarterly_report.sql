-- models/marts/finance/executive_quarterly_report.sql
{{ config(materialized='table', schema='analytics', tags=['executive', 'quarterly']) }}
WITH quarterly_metrics AS (
    SELECT
        p.product_id,
        p.product_name,
        p.product_type,
        p.risk_category,
        DATE_TRUNC('quarter', perf.month) AS quarter,
        AVG(perf.net_monthly_return) * 3 AS quarterly_return,
        AVG(perf.avg_volatility) AS avg_volatility,
        AVG(perf.avg_sharpe_ratio) AS avg_sharpe,
        AVG(perf.avg_var) AS avg_var,
        COUNT(DISTINCT cp.customer_id) AS customer_count,
        SUM(cp.current_value) AS total_aum,
        SUM(t.total_deposits) AS quarter_deposits,
        SUM(t.total_withdrawals) AS quarter_withdrawals
    FROM {{ ref('stg_product_retirement_products') }} p
    LEFT JOIN {{ ref('int_product_performance_monthly') }} perf ON p.product_id = perf.product_id
    LEFT JOIN {{ ref('stg_product_customer_products') }} cp ON p.product_id = cp.product_id
    LEFT JOIN {{ ref('int_product_transactions_monthly') }} t ON p.product_id = t.product_id AND DATE_TRUNC('quarter', t.month) = DATE_TRUNC('quarter', perf.month)
    WHERE perf.month >= DATEADD(quarter, -4, CURRENT_DATE())
    GROUP BY p.product_id, p.product_name, p.product_type, p.risk_category, DATE_TRUNC('quarter', perf.month)
)
SELECT
    product_id,
    product_name,
    product_type,
    risk_category,
    quarter,
    quarterly_return,
    avg_volatility,
    avg_sharpe,
    {{ calculate_risk_adjusted_return('quarterly_return', 'avg_volatility') }} AS risk_adjusted_return,
    customer_count,
    total_aum,
    quarter_deposits,
    quarter_withdrawals,
    quarter_deposits - quarter_withdrawals AS net_flow,
    {{ get_performance_rating('quarterly_return', 'avg_sharpe') }} AS performance_rating,
    {{ get_regulatory_status('risk_category', 'avg_volatility', 'quarterly_return', 'avg_var', 'customer_count') }} AS compliance_status
FROM quarterly_metrics
ORDER BY quarter DESC, total_aum DESC;
