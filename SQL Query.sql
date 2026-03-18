/*1. Identity theft - One customer places many orders at many locations */

SELECT 
	c.customer_unique_id, 
	COUNT(DISTINCT c.customer_zip_code_prefix) as distinct_locations, 
	COUNT(o.order_id) as total_orders 
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id 
GROUP BY c.customer_unique_id 
HAVING COUNT(DISTINCT c.customer_zip_code_prefix)>1 
ORDER BY distinct_locations DESC; 

/*2. Ghost Deliveries - order delivered but unapproved by the financial gateway */

SELECT *
FROM orders
WHERE order_status='delivered'
AND order_approved_at IS NULL; 

/*Addressing the Cash on delivery issue */

SELECT 
o.order_id,
o.order_status, 
p.payment_type, 
p.payment_value,
o.order_approved_at
FROM orders o
JOIN order_payments p
ON o.order_id = p.order_id 
WHERE o.order_status ='delivered'
AND o.order_approved_at IS NULL; 

/*3. Value leakage analysis */

SELECT 
	o.order_id, 
	i.price AS original_product_price, 
	p.payment_value AS amount_actually_paid,
	p.payment_type,
	(i.price - p.payment_value) AS revenue_loss
FROM orders o
JOIN order_items i ON o.order_id =i.order_id
JOIN order_payments p ON o.order_id =p.order_id 
WHERE p.payment_value < (i.price * 0.8)
AND p.payment_value > 0
ORDER BY revenue_loss DESC; 

/*4. Master Query - connecting everything */

SELECT 
	c.customer_unique_id,
	COUNT(DISTINCT c.customer_zip_code_prefix) AS zip_count, 
	SUM(i.price - p.payment_value) AS suspected_revenue_loss,
	COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id 
JOIN order_items i ON o.order_id = i.order_id 
JOIN order_payments p ON o.order_id = p.order_id 
GROUP BY c.customer_unique_id 
HAVING COUNT(DISTINCT c.customer_zip_code_prefix)>1
   AND SUM(i.price - p.payment_value)>100
ORDER BY suspected_revenue_loss DESC; 

