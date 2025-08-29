-- 🍕 Pizza Sales Analysis Queries

-- 1. Total number of orders placed
SELECT COUNT(order_id) AS total_orders
FROM orders;

-- 2. Total revenue generated
SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- 3. Highest priced pizza
SELECT pizza_types.name, pizzas.price
FROM pizzas
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Most commonly ordered pizza size
SELECT pizzas.pizza_size, COUNT(order_details.order_detail_id) AS order_count
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_size
ORDER BY order_count DESC
LIMIT 1;

-- 5. Top 5 most ordered pizzas
SELECT pizza_types.name, SUM(order_details.quantity) AS total_quantity
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

-- 6. Quantity ordered per pizza category
SELECT pizza_types.category, SUM(order_details.quantity) AS total_quantity
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- 7. Distribution of orders by hour
SELECT HOUR(order_time) AS order_hour, COUNT(order_id) AS total_orders
FROM orders
GROUP BY order_hour
ORDER BY order_hour;

-- 8. Number of pizzas in each category
SELECT category, COUNT(DISTINCT pizza_type_id) AS pizza_count
FROM pizza_types
GROUP BY category;

-- 9. Average number of pizzas ordered per day
SELECT ROUND(AVG(daily_orders), 0) AS avg_orders_per_day
FROM (
    SELECT order_date, COUNT(order_id) AS daily_orders
    FROM orders
    GROUP BY order_date
) daily;

-- 10. Top 3 most ordered pizzas by revenue
SELECT pizza_types.name, ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Contribution of each category to total revenue
SELECT pizza_types.category, ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue,
       ROUND(SUM(order_details.quantity * pizzas.price) / 
       (SELECT SUM(order_details.quantity * pizzas.price) 
        FROM order_details JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100, 2) AS revenue_percentage
FROM order_details
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category;

-- 12. Cumulative revenue over time
SELECT order_date, 
       SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT orders.order_date, SUM(order_details.quantity * pizzas.price) AS daily_revenue
    FROM orders
    JOIN order_details ON orders.order_id = order_details.order_id
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY orders.order_date
) AS revenue_by_day;

-- 13. Top 3 most ordered pizzas by revenue in each category
SELECT category, name, revenue
FROM (
    SELECT pizza_types.category, pizza_types.name,
           ROUND(SUM(order_details.quantity * pizzas.price), 2) AS revenue,
           RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity * pizzas.price) DESC) AS rnk
    FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
    JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    GROUP BY pizza_types.category, pizza_types.name
) ranked
WHERE rnk <= 3;
