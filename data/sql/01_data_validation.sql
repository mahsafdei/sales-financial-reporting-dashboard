-- =====================================================
-- Sales & Financial Performance Reporting Dashboard
-- File: 01_data_validation.sql
-- Purpose: Validate cleaned datasets before analysis
-- =====================================================

USE sales_reporting;

-- -----------------------------------------------------
-- 1. Validate table row counts
-- -----------------------------------------------------

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT COUNT(*) AS total_customers
FROM customers;

SELECT COUNT(*) AS total_products
FROM products;

SELECT COUNT(*) AS total_budget_rows
FROM monthly_budget;


-- -----------------------------------------------------
-- 2. Validate transaction types
-- -----------------------------------------------------

SELECT
    TransactionType,
    COUNT(*) AS transaction_count
FROM orders
GROUP BY TransactionType;


-- -----------------------------------------------------
-- 3. Validate missing or unknown customers
-- -----------------------------------------------------

SELECT COUNT(*) AS unknown_customer_transactions
FROM orders
WHERE CustomerID = 'UNKNOWN';


-- -----------------------------------------------------
-- 4. Check for blank Customer IDs
-- -----------------------------------------------------

SELECT COUNT(*) AS blank_customer_ids
FROM orders
WHERE TRIM(CustomerID) = '';


-- -----------------------------------------------------
-- 5. Check for missing Product IDs
-- -----------------------------------------------------

SELECT COUNT(*) AS missing_product_ids
FROM orders
WHERE ProductID IS NULL
   OR TRIM(ProductID) = '';


-- -----------------------------------------------------
-- 6. Check for duplicate Order IDs
-- -----------------------------------------------------

SELECT
    OrderID,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY OrderID
HAVING COUNT(*) > 1;


-- -----------------------------------------------------
-- 7. Validate quantity values
-- -----------------------------------------------------

SELECT COUNT(*) AS zero_quantity_records
FROM orders
WHERE Quantity = 0;

SELECT COUNT(*) AS return_transactions
FROM orders
WHERE Quantity < 0;


-- -----------------------------------------------------
-- 8. Validate pricing and discount fields
-- -----------------------------------------------------

SELECT COUNT(*) AS invalid_unit_prices
FROM orders
WHERE UnitPrice <= 0;

SELECT COUNT(*) AS invalid_discount_values
FROM orders
WHERE DiscountPct < 0
   OR DiscountPct > 1;


-- -----------------------------------------------------
-- 9. Validate customer referential integrity
-- -----------------------------------------------------

SELECT COUNT(*) AS unmatched_customers
FROM orders o
LEFT JOIN customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;


-- -----------------------------------------------------
-- 10. Validate product referential integrity
-- -----------------------------------------------------

SELECT COUNT(*) AS unmatched_products
FROM orders o
LEFT JOIN products p
    ON o.ProductID = p.ProductID
WHERE p.ProductID IS NULL;
