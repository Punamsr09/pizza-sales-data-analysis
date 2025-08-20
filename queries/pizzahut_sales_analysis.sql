-- projects

-- Q,1. Retrieve the total number of orders placed.
SELECT COUNT(*) AS total_orders
FROM orders;

-- Q,2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
JOIN
    pizzas p ON od.pizza_id = p.pizza_id;

-- Q,3. Identify the highest-priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
JOIN
    pizzas ON pizza_types.pizza_types_id = pizzas.pizza_types_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Q,4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details_id) AS count_orders
FROM
    order_details
JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY count_orders DESC
LIMIT 1;

-- Q, 5. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_types_id = pizza_types.pizza_types_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;

-- Q,6. Find the total quantity of each pizza category ordered.
SELECT 
pizza_types.category,
SUM(order_details.quantity) AS total_quantity_ordered
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_types_id =pizzas.pizza_types_id
JOIN order_details 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity_ordered DESC;

-- Q, 7. Determine the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY total_orders DESC;
 
 
-- Q, 8. Find the category-wise distribution of pizzas.
SELECT category,
COUNT(pizza_types_id) AS pizza_types
FROM pizza_types
GROUP BY category
ORDER BY pizza_types DESC;


-- Q, 10. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT ROUND(AVG(pizza_ordered), 2) AS AVG_pizza_ordered
FROM
(SELECT orders.order_date,
SUM(order_details.quantity) AS pizza_ordered
FROM orders JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS daily_ordered;


-- Q,10. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    pizza_types.category,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    order_details
JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN
    pizza_types ON pizza_types.pizza_types_id = pizzas.pizza_types_id
GROUP BY pizza_types.name , pizza_types.category
ORDER BY revenue DESC
LIMIT 3;


-- Q,11. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price) ,2) AS revenue
FROM
	pizzas
JOIN
	order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,2) AS percentage_revenue
FROM
    pizzas
JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
JOIN
    pizza_types ON pizza_types.pizza_types_id = pizzas.pizza_types_id
GROUP BY pizza_types.category;


-- Alternate query using common table expression (CTE) to find the same result.
WITH total_revenue AS (
	SELECT 
		SUM(order_details.quantity*pizzas.price) as revenue
	FROM pizzas JOIN order_details
	ON pizzas.pizza_id = order_details.pizza_id
)

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / total_revenue.revenue * 100,2) AS percentage_revenue
FROM
    pizzas
JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
JOIN
    pizza_types ON pizza_types.pizza_types_id = pizzas.pizza_types_id
CROSS JOIN total_revenue 
GROUP BY pizza_types.category, total_revenue.revenue; 

-- Q, 12. Analyze the cumulative revenue generated over time.
SELECT 
	order_date,
	SUM(revenue) OVER(ORDER BY order_date) AS cumulative_rev
FROM (
	SELECT orders.order_date,
		SUM(order_details.quantity*pizzas.price) AS revenue
	FROM order_details
	JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
	JOIN orders ON orders.order_id = order_details.order_id
	GROUP BY orders.order_date
) AS sales_date_wise;


-- Q, 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT 
	category,
	name, 
	revenue, 
	top_orders
FROM (
	SELECT 
		category,
        name,
        revenue,
		RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS top_orders
	FROM (
		SELECT pizza_types.category, pizza_types.name, SUM(order_details.quantity*pizzas.price) AS revenue
		FROM order_details
		JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
		JOIN pizza_types ON pizza_types.pizza_types_id = pizzas.pizza_types_id
		GROUP BY pizza_types.category, pizza_types.name
		ORDER BY revenue
	) AS category_rev_table
) AS sub_query
WHERE top_orders < 4;
