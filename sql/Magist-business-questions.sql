USE magist;

#In relation to the products:
#####################################################

#. What categories of tech products does Magist have?
#--------------------------------------------------
SELECT 
    p.product_category_name, 
    pcnt.product_category_name_english AS eng_name,
    COUNT(DISTINCT p.product_id) AS num_of_prod
FROM
    products p
LEFT JOIN 
	product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name    
GROUP BY p.product_category_name
ORDER BY num_of_prod DESC
;

#. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
#--------------------------------------------------
SELECT 
    pcnt.product_category_name_english AS eng_cat_name,
    COUNT(oi.product_id) AS n_products
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english IN (
		'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
#comment GROUP BY and ORDER BY to get total number of products in all these categories        
GROUP BY pcnt.product_category_name_english
ORDER BY n_products DESC
;

# What percentage does that represent from the overall number of products sold?
SELECT 
    COUNT(product_id) AS n_products
FROM
    order_items
;

SELECT 
    pcnt.product_category_name_english AS eng_cat_name,
    ROUND(COUNT(oi.product_id)*100/(SELECT COUNT(product_id) from order_items),2) AS percent_products
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english IN (
		'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
#comment GROUP BY and ORDER BY to get total percentage of products in all these categories
GROUP BY pcnt.product_category_name_english
ORDER BY percent_products DESC
;

#.What’s the average price of the products being sold?
#---------------------------------------------------------
SELECT ROUND(AVG(price),2)
FROM order_items
;

#.Are expensive tech products popular? 
#---------------------------------------------------------

SELECT 
    pcnt.product_category_name_english AS eng_cat_name,
    COUNT(oi.product_id)*100/(SELECT COUNT(product_id) from order_items)    
    AS percent_products
FROM
    order_items oi
        LEFT JOIN
    products p ON oi.product_id = p.product_id
        LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE
    pcnt.product_category_name_english IN (
		'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
AND
     oi.price > 121   
#comment GROUP BY and ORDER BY to get total number of products in all these categories        
GROUP BY pcnt.product_category_name_english
ORDER BY percent_products DESC
;
#From Marcus
SELECT CASE
    WHEN price <= 100 THEN '0-100'
    WHEN 100 < price AND price <= 500 THEN '100-500'
    WHEN 500 < price AND price <= 1000 THEN '500-1000'
    WHEN 1000 < price AND price <= 1500 THEN '1000-1500'
    WHEN 1500 < price AND price <= 2000 THEN '1500-2000'
    WHEN 2000 < price AND price <= 2500 THEN '2000-2500'
    WHEN 2500 < price AND price <= 3000 THEN '2500-3000'
    ELSE 'expensive' END AS price_category, COUNT(*)
    FROM order_items
    JOIN products USING(product_id)
    JOIN product_category_name_translation USING(product_category_name)
    WHERE product_category_name_translation.product_category_name_english 
        IN ('computers',
'computers_accessories',
'consoles_games',
'electronics',
'fixed_telephony',
'pc_gamer',
'tablets_printing_image',
'telephony')
    GROUP BY price_category
    ORDER BY COUNT(*) DESC
;

#In relation to the sellers:
#########################################

#. How many sellers are there?
#-----------------------------------------
SELECT 
    COUNT(DISTINCT seller_id)
FROM
    sellers
;

#.What’s the average monthly revenue of Magist’s sellers?
#-------------------------------------------------------

#.corrected by Ben
#one average number fover all sellers
SELECT 
    AVG(month_reveue) AS avg_month_rev
FROM
    (SELECT 
        seller_id,
        YEAR(shipping_limit_date),
		MONTH(shipping_limit_date),
   		SUM(price) AS month_reveue
    FROM
        order_items
    GROUP BY seller_id , YEAR(shipping_limit_date), MONTH(shipping_limit_date)
    ORDER BY seller_id , YEAR(shipping_limit_date), MONTH(shipping_limit_date)
	) monthly_order_items
;

# 10 most successfull sellers
SELECT 
    seller_id, ROUND(AVG(month_reveue),2) AS avg_month_rev
FROM
    (SELECT 
        seller_id,
		MONTH(shipping_limit_date),
		SUM(price) AS month_reveue
    FROM
        order_items
    GROUP BY seller_id , MONTH(shipping_limit_date)
    ORDER BY seller_id , MONTH(shipping_limit_date)
	) monthly_order_items
GROUP BY  seller_id   
ORDER BY  avg_month_rev DESC
LIMIT 10
;

#.What’s the average revenue of sellers that sell tech products?
#-------------------------------------------------------

# one number over all sellers
SELECT 
    AVG(month_reveue) AS avg_month_rev
FROM
    (SELECT 
        seller_id,
        YEAR(shipping_limit_date),
		MONTH(shipping_limit_date),
		SUM(price) AS month_reveue
    FROM
        order_items oi
    LEFT JOIN
    products p ON oi.product_id = p.product_id
	LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
	WHERE
    pcnt.product_category_name_english IN (
		'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
    GROUP BY seller_id , YEAR(shipping_limit_date), MONTH(shipping_limit_date)
    ORDER BY seller_id , YEAR(shipping_limit_date), MONTH(shipping_limit_date)
	) monthly_order_items
;

# 10 most successful thec sellers
SELECT 
    seller_id, ROUND(AVG(month_reveue),2) AS avg_month_rev
FROM
    (SELECT 
        seller_id,
        YEAR(shipping_limit_date),
		MONTH(shipping_limit_date),
		SUM(price) AS month_reveue
    FROM
        order_items oi
    LEFT JOIN
    products p ON oi.product_id = p.product_id
	LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
	WHERE
    pcnt.product_category_name_english IN (
		'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
    GROUP BY seller_id , YEAR(shipping_limit_date), MONTH(shipping_limit_date)
    ORDER BY seller_id , YEAR(shipping_limit_date), MONTH(shipping_limit_date)
	) monthly_order_items
GROUP BY  seller_id   
ORDER BY  avg_month_rev DESC
LIMIT 10
;


#.Total average revenue of sellers that sell tech products over all time?
#-------------------------------------------------------
SELECT 
        #seller_id,
        SUM(price)/COUNT(DISTINCT oi.seller_id) AS total_reveue
    FROM
        order_items oi
    LEFT JOIN
    products p ON oi.product_id = p.product_id
	LEFT JOIN
    product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
	WHERE
    pcnt.product_category_name_english IN (
		'computers',
		'computers_accessories',
		'consoles_games',
		'electronics',
		'fixed_telephony',
		'pc_gamer',
		'tablets_printing_image',
		'telephony')
    #GROUP BY seller_id 
    #ORDER BY seller_id 

;


#In relation to the delivery time:
#########################################

#.What’s the average time between the order being placed and the product being delivered?alter
#---------------------------------------------------------------------------------------------
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp))
FROM
    orders
;

#. How many orders are delivered on time vs orders delivered with a delay?
#---------------------------------------------------------------------------------------------
SELECT 
    count(order_id) AS delivered_on_time, 
    (SELECT count(order_id) FROM orders) AS total_orders,
    count(order_id)*100/(SELECT count(order_id) FROM orders) AS percent_on_time
FROM
    orders
WHERE DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) >= 0
;
SELECT DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date)
from orders
;

SELECT DATEDIFF("2017-01-21", "2017-01-11");

#.Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT 
    #DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date),
    AVG(p.product_weight_g),
    AVG(product_length_cm),
    AVG(product_height_cm),
    AVG(product_width_cm)
    #p.product_category_name
FROM
    orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
WHERE DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 0
;

SELECT 
    AVG(DATEDIFF(o.order_estimated_delivery_date, o.order_delivered_customer_date)) as avg_delay,
    #AVG(p.product_weight_g),
    #AVG(product_length_cm),
    #AVG(product_height_cm),
    #AVG(product_width_cm)
    pcnt.product_category_name_english
FROM
    orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN products p ON p.product_id = oi.product_id
LEFT JOIN product_category_name_translation pcnt ON p.product_category_name = pcnt.product_category_name
WHERE DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) < 0
group by pcnt.product_category_name_english
order by avg_delay
;