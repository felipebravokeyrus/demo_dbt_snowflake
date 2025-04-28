-- macros/get_regulatory_status.sql
{% macro get_regulatory_status(risk_category, volatility, return_value, var_value, customer_count) %}
CASE
    WHEN {{ risk_category }} = 'low' AND {{ volatility }} > 0.08 THEN 'Non-compliant - High volatility'
    WHEN {{ risk_category }} = 'high' AND {{ var_value }} > 0.2 THEN 'Review required - High VaR'
    WHEN {{ return_value }} < -0.05 AND {{ customer_count }} > 100 THEN 'Risk alert - Significant losses'
    ELSE 'Compliant'
END
{% endmacro %}
