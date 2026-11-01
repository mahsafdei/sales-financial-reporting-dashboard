-- =====================================================
-- Sales & Financial Performance Reporting Dashboard
-- File: 04_business_performance_analysis.sql
-- Purpose: Analyze performance by region, category,
--          product, and customer
-- =====================================================

USE sales_reporting;


-- -----------------------------------------------------
-- 1. Regional Performance
-- -----------------------------------------------------

SELECT
    c.Region,

    ROUND(SUM(o.NetRevenue), 2) AS total_revenue,

    ROUND(SUM(o.GrossProfit), 2) AS gross_profit,

    ROUND(
        SUM(o.GrossProfit) /
        NULLIF(SUM(o.NetRevenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(DISTINCT o.OrderID) AS total_transactions

FROM orders o

JOIN customers c
    ON o.CustomerID = c.CustomerID

GROUP BY c.Region

ORDER BY total_revenue DESC;


-- -----------------------------------------------------
-- 2. Product Category Performance
-- -----------------------------------------------------

SELECT
    p.Category,

    ROUND(SUM(o.NetRevenue), 2) AS total_revenue,

    ROUND(SUM(o.COGS), 2) AS total_cogs,

    ROUND(SUM(o.GrossProfit), 2) AS gross_profit,

    ROUND(
        SUM(o.GrossProfit) /
        NULLIF(SUM(o.NetRevenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    SUM(
        CASE
            WHEN o.TransactionType = 'Sale'
            THEN o.Quantity
            ELSE 0
        END
    ) AS units_sold

FROM orders o

JOIN products p
    ON o.ProductID = p.ProductID

GROUP BY p.Category

ORDER BY total_revenue DESC;


-- -----------------------------------------------------
-- 3. Top 10 Products by Revenue
-- -----------------------------------------------------

WITH product_performance AS (

    SELECT
        p.ProductID,
        p.ProductName,
        p.Category,

        SUM(o.NetRevenue) AS total_revenue,

        SUM(o.GrossProfit) AS gross_profit

    FROM orders o

    JOIN products p
        ON o.ProductID = p.ProductID

    GROUP BY
        p.ProductID,
        p.ProductName,
        p.Category
)

SELECT
    ProductID,
    ProductName,
    Category,

    ROUND(total_revenue, 2) AS total_revenue,

    ROUND(gross_profit, 2) AS gross_profit,

    ROUND(
        gross_profit /
        NULLIF(total_revenue, 0) * 100,
        2
    ) AS gross_margin_pct,

    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS revenue_rank

FROM product_performance

ORDER BY revenue_rank

LIMIT 10;


-- -----------------------------------------------------
-- 4. Top 10 Customers by Revenue
-- -----------------------------------------------------

WITH customer_performance AS (

    SELECT
        c.CustomerID,
        c.CustomerName,
        c.Segment,
        c.Region,

        SUM(o.NetRevenue) AS total_revenue,

        SUM(o.GrossProfit) AS gross_profit,

        COUNT(DISTINCT o.OrderID) AS total_transactions

    FROM orders o

    JOIN customers c
        ON o.CustomerID = c.CustomerID

    WHERE o.CustomerID <> 'UNKNOWN'

    GROUP BY
        c.CustomerID,
        c.CustomerName,
        c.Segment,
        c.Region
)

SELECT
    CustomerID,
    CustomerName,
    Segment,
    Region,

    ROUND(total_revenue, 2) AS total_revenue,

    ROUND(gross_profit, 2) AS gross_profit,

    ROUND(
        gross_profit /
        NULLIF(total_revenue, 0) * 100,
        2
    ) AS gross_margin_pct,

    total_transactions,

    DENSE_RANK() OVER (
        ORDER BY total_revenue DESC
    ) AS customer_rank

FROM customer_performance

ORDER BY customer_rank

LIMIT 10;
