USE magist;

#1. How many orders are there in the dataset?
#--------------------------------------------------
SELECT COUNT(*)
FROM orders
;

#2. Are orders actually delivered?
#--------------------------------------------------
SELECT order_status, COUNT(*) AS num_of_orders
FROM  orders
GROUP by order_status
;

#3.Is Magist having user growth?
#--------------------------------------------------
SELECT 
    YEAR(order_purchase_timestamp) AS year_,
    MONTH(order_purchase_timestamp) AS month_,
    COUNT(customer_id) AS num_of_orders
FROM
    orders
GROUP BY year_, month_
ORDER BY year_, month_
;

#4.How many products are there in the products table? 
#--------------------------------------------------
SELECT 
    COUNT(DISTINCT product_id) AS num_of_products
FROM
    products;
    
#5.Which are the categories with most products?
#--------------------------------------------------
SELECT 
    p.product_category_name, 
    pcnt.product_category_name_english,
    COUNT(DISTINCT p.product_id) AS num_of_prod
FROM
    products p
LEFT JOIN 
	product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name    
GROUP BY p.product_category_name
ORDER BY num_of_prod DESC
;
SELECT 
    COUNT(DISTINCT product_category_name)
FROM
    products
;
#from answers
SELECT 
    product_category_name, 
    COUNT(DISTINCT product_id) AS n_products
FROM
    products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;

#6.How many of those products were present in actual transactions?
#------------------------------------------------------------------
SELECT 
	count(DISTINCT product_id) AS n_products
FROM
	order_items;
    
#7.What’s the price for the most expensive and cheapest products?
#------------------------------------------------------------------
SELECT 
    MAX(price),
    MIN(price)
FROM
    order_items
;

#8. What are the highest and lowest payment values?
#------------------------------------------------------------------
SELECT 
    MAX(payment_value), 
    MIN(payment_value)
FROM
    order_payments
;