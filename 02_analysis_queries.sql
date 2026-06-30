-- ============================================================
-- SUPERSTORE SALES ANALYSIS — BUSINESS QUERIES
-- Author: Marvis Obanor
-- Business Question: Which regions, categories and customers
-- are driving revenue — and where are we losing money?
-- ============================================================


-- ============================================================
-- SECTION 1: REVENUE OVERVIEW
-- ============================================================

-- Q1. Total sales, profit and orders across the full dataset
SELECT
    COUNT(DISTINCT o.order_id)          AS total_orders,
    SUM(oi.sales)                       AS total_sales,
    SUM(oi.profit)                      AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;


-- Q2. Annual revenue and profit trend (2014–2017)
SELECT
    strftime('%Y', o.order_date)        AS year,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY year
ORDER BY year;


-- ============================================================
-- SECTION 2: REGIONAL PERFORMANCE
-- ============================================================

-- Q3. Sales and profit by region
SELECT
    c.region,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
GROUP BY c.region
ORDER BY total_sales DESC;


-- Q4. Best performing state by total sales
SELECT
    c.state,
    c.region,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
GROUP BY c.state, c.region
ORDER BY total_sales DESC
LIMIT 15;


-- ============================================================
-- SECTION 3: CATEGORY & PRODUCT ANALYSIS
-- ============================================================

-- Q5. Sales and profit by category
SELECT
    p.category,
    COUNT(DISTINCT oi.order_id)         AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;


-- Q6. Sales and profit by sub-category
SELECT
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category
ORDER BY total_profit DESC;


-- Q7. Top 10 products by revenue
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
ORDER BY total_sales DESC
LIMIT 10;


-- Q8. Loss-making products (products where total profit is negative)
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(AVG(oi.discount) * 100, 1)    AS avg_discount_pct
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
HAVING total_profit < 0
ORDER BY total_profit ASC;


-- ============================================================
-- SECTION 4: CUSTOMER ANALYSIS
-- ============================================================

-- Q9. Top 10 customers by total revenue
SELECT
    c.customer_name,
    c.segment,
    c.region,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment, c.region
ORDER BY total_sales DESC
LIMIT 10;


-- Q10. Revenue and profit by customer segment
SELECT
    c.segment,
    COUNT(DISTINCT c.customer_id)       AS total_customers,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.sales) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN customers c    ON o.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY total_sales DESC;


-- ============================================================
-- SECTION 5: SHIPPING ANALYSIS
-- ============================================================

-- Q11. Order volume and revenue by shipping mode
SELECT
    o.ship_mode,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.ship_mode
ORDER BY total_orders DESC;


-- Q12. Average days to ship by shipping mode
SELECT
    ship_mode,
    ROUND(AVG(
        JULIANDAY(ship_date) - JULIANDAY(order_date)
    ), 1)                               AS avg_days_to_ship,
    COUNT(*)                            AS total_orders
FROM orders
GROUP BY ship_mode
ORDER BY avg_days_to_ship;


-- ============================================================
-- SECTION 6: DISCOUNT IMPACT
-- ============================================================

-- Q13. How discount levels affect profit margin
SELECT
    CASE
        WHEN oi.discount = 0          THEN 'No Discount'
        WHEN oi.discount <= 0.1       THEN 'Low (1-10%)'
        WHEN oi.discount <= 0.2       THEN 'Medium (11-20%)'
        ELSE                               'High (20%+)'
    END                                 AS discount_band,
    COUNT(*)                            AS line_items,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    ROUND(SUM(oi.profit) / SUM(oi.sales) * 100, 2) AS profit_margin_pct
FROM order_items oi
GROUP BY discount_band
ORDER BY total_profit DESC;


-- ============================================================
-- SECTION 7: WINDOW FUNCTIONS (Advanced)
-- ============================================================

-- Q14. Rank products by sales within each category
--      (this is the window function that stands out on a portfolio)
SELECT
    p.category,
    p.product_name,
    ROUND(SUM(oi.sales), 2)             AS total_sales,
    ROUND(SUM(oi.profit), 2)            AS total_profit,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(oi.sales) DESC
    )                                   AS rank_in_category
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category, p.product_id, p.product_name
ORDER BY p.category, rank_in_category;


-- Q15. Running total of annual sales (year-over-year growth view)
SELECT
    year,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY year
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                   AS cumulative_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (ORDER BY year))
        / LAG(total_sales) OVER (ORDER BY year) * 100
    , 1)                                AS yoy_growth_pct
FROM (
    SELECT
        strftime('%Y', o.order_date)    AS year,
        ROUND(SUM(oi.sales), 2)         AS total_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY year
)
ORDER BY year;
