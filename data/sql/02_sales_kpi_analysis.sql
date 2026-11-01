-- =====================================================
-- Sales & Financial Performance Reporting Dashboard
-- File: 02_sales_kpi_analysis.sql
-- Purpose: Calculate core sales and financial KPIs
-- =====================================================

USE sales_reporting;


-- -----------------------------------------------------
-- 1. Core financial KPIs
-- -----------------------------------------------------

SELECT
    ROUND(SUM(NetRevenue), 2) AS total_net_revenue,
    ROUND(SUM(COGS), 2) AS total_cogs,
    ROUND(SUM(GrossProfit), 2) AS total_gross_profit,
    ROUND(
        SUM(GrossProfit) / NULLIF(SUM(NetRevenue), 0) * 100,
        2
    ) AS gross_margin_pct
FROM orders;


-- -----------------------------------------------------
-- 2. Transaction and unit metrics
-- -----------------------------------------------------

SELECT
    COUNT(DISTINCT OrderID) AS total_transactions,

    SUM(
        CASE
            WHEN TransactionType = 'Sale'
            THEN Quantity
            ELSE 0
        END
    ) AS units_sold,

    ABS(
        SUM(
            CASE
                WHEN TransactionType = 'Return'
                THEN Quantity
                ELSE 0
            END
        )
    ) AS units_returned

FROM orders;


-- -----------------------------------------------------
-- 3. Average Order Value (sales only)
-- -----------------------------------------------------

SELECT
    ROUND(
        SUM(NetRevenue) / COUNT(DISTINCT OrderID),
        2
    ) AS average_order_value
FROM orders
WHERE TransactionType = 'Sale';


-- -----------------------------------------------------
-- 4. Return transaction rate
-- -----------------------------------------------------

SELECT
    ROUND(
        SUM(
            CASE
                WHEN TransactionType = 'Return'
                THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS return_transaction_rate_pct
FROM orders;


-- -----------------------------------------------------
-- 5. Executive KPI Summary
-- -----------------------------------------------------

SELECT
    ROUND(SUM(NetRevenue), 2) AS total_net_revenue,

    ROUND(SUM(COGS), 2) AS total_cogs,

    ROUND(SUM(GrossProfit), 2) AS total_gross_profit,

    ROUND(
        SUM(GrossProfit) / NULLIF(SUM(NetRevenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    COUNT(DISTINCT OrderID) AS total_transactions,

    SUM(
        CASE
            WHEN TransactionType = 'Sale'
            THEN Quantity
            ELSE 0
        END
    ) AS units_sold,

    ABS(
        SUM(
            CASE
                WHEN TransactionType = 'Return'
                THEN Quantity
                ELSE 0
            END
        )
    ) AS units_returned,

    ROUND(
        SUM(
            CASE
                WHEN TransactionType = 'Sale'
                THEN NetRevenue
                ELSE 0
            END
        )
        /
        NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN TransactionType = 'Sale'
                    THEN OrderID
                END
            ),
            0
        ),
        2
    ) AS average_order_value

FROM orders;
