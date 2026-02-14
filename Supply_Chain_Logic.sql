--- STEP 1 SCHEMA DEFINITION 
Project: Olist E-commerce Portfolio
*/

-- Create the Orders Table
CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Create the Payments Table
CREATE TABLE IF NOT EXISTS order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10, 2)
);

-- Create the Reviews Table
CREATE TABLE IF NOT EXISTS order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


SELECT 
    (SELECT COUNT(*) FROM orders) AS total_orders,
    (SELECT COUNT(*) FROM order_payments) AS total_payment_records,
    (SELECT COUNT(DISTINCT order_id) FROM order_payments) AS unique_orders_paid;


/* STEP 2: DIMENSION & LOGISTICS TABLES */

-- Table 4: Product Details
CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);

-- Table 5: Order Items (The Bridge)
CREATE TABLE IF NOT EXISTS order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2)
);

-- Table 6: Sellers
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);

-- Table 7: Customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);

-- Table 8: Category Translation 
CREATE TABLE IF NOT EXISTS category_translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);


----
/* STEP 3: FINAL RELATIONAL AUDIT 
Objective: TO Ensure all dimension tables are loaded correctly
*/

SELECT 
    (SELECT COUNT(*) FROM orders) as orders_row_count,
    (SELECT COUNT(*) FROM customers) as customers_row_count,
    (SELECT COUNT(*) FROM products) as products_row_count,
    (SELECT COUNT(*) FROM order_items) as items_row_count,
    (SELECT COUNT(*) FROM sellers) as sellers_row_count,
    (SELECT COUNT(*) FROM category_translation) as translation_row_count;


/* STEP 4: EXECUTIVE MASTER VIEW
Objective: Create a 'One-Stop' table for Executive Reporting
*/

WITH order_summary AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        -- SLA Calculation: How many days late? (Negative = Late)
        EXTRACT(DAY FROM (o.order_estimated_delivery_date - o.order_delivered_customer_date)) AS delivery_lead_time_days
    FROM orders o
    WHERE o.order_status = 'delivered'
),

payment_summary AS (
    SELECT 
        order_id, 
        SUM(payment_value) as total_revenue
    FROM order_payments
    GROUP BY 1
),

product_details AS (
    SELECT 
        oi.order_id,
        oi.product_id,
        oi.price,
        oi.freight_value,
        t.product_category_name_english as category
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
)

-- FINAL EXECUTIVE VIEW
SELECT 
    os.*,
    ps.total_revenue,
    pd.category,
    pd.price,
    pd.freight_value,
    CASE 
        WHEN os.delivery_lead_time_days < 0 THEN 'SLA Breach (Late)'
        ELSE 'On-Time'
    END as fulfillment_status
FROM order_summary os
JOIN payment_summary ps ON os.order_id = ps.order_id
JOIN product_details pd ON os.order_id = pd.order_id;

--
/* STEP 5: ANALYTICAL MASTER VIEW
Objective: Combine Logistics, Finance, and Sentiment for Executive Reporting
*/

CREATE OR REPLACE VIEW executive_order_view AS
WITH order_base AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        -- Calculate Delivery Delta (Positive = Early, Negative = Late)
        EXTRACT(DAY FROM (o.order_estimated_delivery_date - o.order_delivered_customer_date)) AS delivery_delta_days
    FROM orders o
    WHERE o.order_status = 'delivered'
),
financial_summary AS (
    SELECT 
        order_id, 
        SUM(payment_value) as total_order_value
    FROM order_payments
    GROUP BY 1
),
sentiment_summary AS (
    SELECT 
        order_id, 
        AVG(review_score) as avg_review_score
    FROM order_reviews
    GROUP BY 1
)
SELECT 
    ob.*,
    fs.total_order_value,
    ss.avg_review_score,
    -- Executive Logic: Flagging SLA Breaches
    CASE 
        WHEN ob.delivery_delta_days < 0 THEN 'LATE'
        ELSE 'ON-TIME'
    END as fulfillment_status
FROM order_base ob
JOIN financial_summary fs ON ob.order_id = fs.order_id
LEFT JOIN sentiment_summary ss ON ob.order_id = ss.order_id;
--
SELECT * FROM executive_order_view LIMIT 5;

---

SELECT * FROM executive_order_view;

--
-- STEP 6: Final Executive View Aligned 
DROP VIEW IF EXISTS executive_order_view;

CREATE VIEW executive_order_view AS
WITH product_mapping AS (
    -- Step 1: Mapping Portuguese categories to English using your 'category_translation' table
    SELECT 
        p.product_id,
        COALESCE(t.product_category_name_english, p.product_category_name) AS category_name_english
    FROM products p
    LEFT JOIN category_translation t 
        ON p.product_category_name = t.product_category_name
),
order_details AS (
    -- Step 2: Aggregating financials, geography, and logistics status
    SELECT 
        o.order_id,
        o.customer_id,
        c.customer_state, 
        pm.category_name_english,
        SUM(oi.price + oi.freight_value) as total_order_value,
        -- Logistic Logic: Determining SLA Compliance
        CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'LATE'
            ELSE 'ON-TIME'
        END as fulfillment_status,
        -- Metric: Days ahead (+) or behind (-) schedule
        (EXTRACT(DAY FROM (o.order_estimated_delivery_date - o.order_delivered_customer_date))) as delivery_delta_days
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN product_mapping pm ON oi.product_id = pm.product_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1, 2, 3, 4, 6, 7
),
final_executive_layer AS (
    -- Step 3: Bringing in Customer Sentiment from 'order_reviews' table
    SELECT 
        od.*,
        r.review_score as avg_review_score
    FROM order_details od
    LEFT JOIN order_reviews r ON od.order_id = r.order_id
)
SELECT * FROM final_executive_layer;

SELECT * FROM executive_order_view;