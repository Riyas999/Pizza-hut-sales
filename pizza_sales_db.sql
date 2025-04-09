create database pizzahut;
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id) );

-- Retrieve the total number of orders placed
select count(order_id) from orders;

-- calculate the total revenue generated  from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id; 

-- Identify highest priced pizzas
SELECT 
    name, price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most commmon pizza size ordered
SELECT 
    size, COUNT(quantity)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY COUNT(quantity) DESC; 

-- list the top 5 most ordered pizza types along with their quantities.
SELECT 
    name, SUM(quantity)
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY name
ORDER BY COUNT(quantity) DESC
LIMIT 5;

 -- find the total quantity of each pizza category ordered
 
SELECT 
    category, SUM(quantity)
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY SUM(quantity) DESC;

-- determine the distribution of orders by hour of the day find peak hours

SELECT 
    HOUR(order_time), COUNT(order_id)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(order_id) DESC
LIMIT 10;

-- find the category-wise distribution of pizzas
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- calculate the average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) as avg_quantity
FROM
    (SELECT 
        order_date, SUM(quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_date) AS order_quantity_pd;
    
    -- Determine the top most ordered pizza types based on revenue
SELECT 
    name, SUM(quantity * price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;

-- calculate the percentage contribution of each pizza type to total revenue
SELECT 
    category,
    ROUND((SUM(quantity * price) / (SELECT 
                    ROUND(SUM(quantity * price), 2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY category
ORDER BY revenue DESC;

-- analyze the cumulative revenue generated over time.
select order_date,sum(revenue) over (order by order_date) as cum_revenue from
(SELECT 
    order_date, SUM(quantity * price) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    orders ON orders.order_id = order_details.order_id
GROUP BY order_date)as sales;

-- determine the top 3 most ordered pizza types based on revenue for each pizza cateogory.
select category,name,revenue from
(select category, name,revenue,rank()over(partition by category order by revenue desc)as rn
from
(select category,name,sum(quantity*price) as revenue from 
pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by category,name)as a)as b
where rn <= 3;