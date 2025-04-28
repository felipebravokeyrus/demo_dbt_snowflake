-- tests/assert_product_returns_in_range.sql
SELECT
    product_id,
    product_name,
    month,
    end_month_return
FROM {{ ref('int_product_performance_monthly') }}
WHERE ABS(end_month_return) > 0.2;
