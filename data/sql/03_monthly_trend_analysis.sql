-- =====================================================
-- Sales & Financial Performance Reporting Dashboard
-- File: 03_monthly_trend_analysis.sql
-- Purpose: Analyze monthly revenue trends and growth
-- =====================================================

USE sales_reporting;


-- -----------------------------------------------------
-- 1. Monthly Revenue and Gross Profit
-- -----------------------------------------------------

SELECT
    DATE_FORMAT(OrderDate, '%Y-%m') AS sales_month,
    ROUND(SUM(NetRevenue), 2) AS monthly_revenue,
    ROUND(SUM(GrossProfit), 2) AS monthly_gross_profit
FROM orders
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY sales_month;


-- -----------------------------------------------------
-- 2. Month-over-Month Revenue Growth
-- -----------------------------------------------------

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(OrderDate, '%Y-%m') AS sales_month,
        SUM(NetRevenue) AS monthly_revenue
    FROM orders
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
)

SELECT
    sales_month,

    ROUND(monthly_revenue, 2) AS monthly_revenue,

    ROUND(
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ),
        2
    ) AS previous_month_revenue,

    ROUND(
        (
            monthly_revenue
            - LAG(monthly_revenue) OVER (
                ORDER BY sales_month
            )
        )
        /
        NULLIF(
            LAG(monthly_revenue) OVER (
                ORDER BY sales_month
            ),
            0
        ) * 100,
        2
    ) AS mom_growth_pct

FROM monthly_sales
ORDER BY sales_month;


-- -----------------------------------------------------
-- 3. Year-over-Year Revenue Growth
-- -----------------------------------------------------

WITH monthly_sales AS (
    SELECT
        YEAR(OrderDate) AS sales_year,
        MONTH(OrderDate) AS sales_month,
        SUM(NetRevenue) AS monthly_revenue
    FROM orders
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
)

SELECT
    sales_year,
    sales_month,

    ROUND(monthly_revenue, 2) AS monthly_revenue,

    ROUND(
        LAG(monthly_revenue, 12)
        OVER (
            ORDER BY sales_year, sales_month
        ),
        2
    ) AS previous_year_revenue,

    ROUND(
        (
            monthly_revenue
            - LAG(monthly_revenue, 12)
              OVER (
                  ORDER BY sales_year, sales_month
              )
        )
        /
        NULLIF(
            LAG(monthly_revenue, 12)
            OVER (
                ORDER BY sales_year, sales_month
            ),
            0
        ) * 100,
        2
    ) AS yoy_growth_pct

FROM monthly_sales
ORDER BY sales_year, sales_month;
