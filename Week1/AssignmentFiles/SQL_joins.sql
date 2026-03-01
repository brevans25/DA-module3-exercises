USE coffeeshop_db;

-- =========================================================
-- JOINS & RELATIONSHIPS PRACTICE
-- =========================================================

-- Q1) Join products to categories: list product_name, category_name, price.
select p.name,
c.name,
p.price
from products p
left join categories c
on p.category_id = c.category_id;

-- Q2) For each order item, show: order_id, order_datetime, store_name,
--     product_name, quantity, line_total (= quantity * products.price).
--     Sort by order_datetime, then order_id.

select o.order_id,
date_format(o.order_datetime, '%m/%d/%Y') as order_date,
s.name,
p.name,
oi.quantity,
concat("$",(oi.quantity * p.price)) as line_total
from orders o
inner join stores s on o.store_id = s.store_id
inner join order_items oi on o.order_id = oi.order_id
inner join products p on oi.product_id = p.product_id

order by o.order_datetime,
o.order_id;

-- Q3) Customer order history (PAID only):
--     For each order, show customer_name, store_name, order_datetime,
--     order_total (= SUM(quantity * products.price) per order).
select o.order_id,
concat(c.first_name, " ",c.last_name) as customer_name,
s.name,
date_format(o.order_datetime, '%m/%d/%Y') as order_date,
concat("$",sum(oi.quantity * p.price)) as order_total
from orders o
inner join customers c on o.customer_id = c.customer_id
inner join stores s on o.store_id = s.store_id
inner join order_items oi on o.order_id = oi.order_id
inner join products p on oi.product_id = p.product_id
where o.status = 'paid'

group by o.order_id,
    c.first_name,
    c.last_name,
    s.name,
    o.order_datetime;


-- Q4) Left join to find customers who have never placed an order.
--     Return first_name, last_name, city, state.
select c.first_name,
c.last_name,
c.city,
c.state
from customers c
left join orders o on o.customer_id = c.customer_id
where o.order_id is null;

-- SPOT CHECK
select count(*) from customers;

select count(distinct customer_id) from orders;

-- every customer placed at least one order...

-- Q5) For each store, list the top-selling product by units (PAID only).
--     Return store_name, product_name, total_units.
--     Hint: Use a window function (ROW_NUMBER PARTITION BY store) or a correlated subquery.
select s.name as store_name,
p.name as product_name,
sum(oi.quantity) as total_units
from orders o
inner join stores s on o.store_id = s.store_id
inner join order_items oi on o.order_id = oi.order_id
inner join products p on oi.product_id = p.product_id
where o.status = 'paid'

group by s.store_id,
    s.name,
    p.product_id,
    p.name;
 -- did we go over this window function anywhere in the content?

-- Q6) Inventory check: show rows where on_hand < 12 in any store.
--     Return store_name, product_name, on_hand.

select s.name as store_name,
p.name as product_name,
i.on_hand
from inventory i
join stores s on i.store_id = s.store_id
join products p on i.product_id = p.product_id
where i.on_hand < 12

order by s.name, 
p.name;

-- Q7) Manager roster: list each store's manager_name and hire_date.
--     (Assume title = 'Manager').
select s.name as store_name,
concat(e.first_name, ' ', e.last_name) as manager_name,
date_format(e.hire_date, '%m/%d/%Y') as hire_date
from employees e
join stores s on e.store_id = s.store_id
where e.title = 'manager'

order by s.name;

-- Q8) Using a subquery/CTE: list products whose total PAID revenue is above
--     the average PAID product revenue. Return product_name, total_revenue.
with rev as (
select p.name as product_name,
sum(oi.quantity * p.price) as total_revenue
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on oi.product_id = p.product_id
where o.status = 'paid'

group by p.name
)

select product_name,
concat("$",total_revenue) as total_revenue
from rev
where total_revenue > (select avg(total_revenue) from rev)

order by total_revenue desc;

-- Q9) Churn-ish check: list customers with their last PAID order date.
--     If they have no PAID orders, show NULL.
--     Hint: Put the status filter in the LEFT JOIN's ON clause to preserve non-buyer rows.
select concat(c.first_name, ' ', c.last_name) as customer_name,
max(date_format(o.order_datetime, '%m/%d/%Y')) as last_order_date
from customers c
left join orders o on c.customer_id = o.customer_id and o.status = 'paid'

group by c.customer_id,
c.first_name,
c.last_name

order by last_order_date desc;


-- Q10) Product mix report (PAID only):
--     For each store and category, show total units and total revenue (= SUM(quantity * products.price)).
select s.name as store_name,
c.name,
sum(oi.quantity) as total_units,
concat("$",sum(oi.quantity * p.price)) as total_revenue
from order_items oi
join orders o on oi.order_id = o.order_id
join stores s on o.store_id = s.store_id
join products p on oi.product_id = p.product_id
join categories c on c.category_id = p.category_id


where o.status = 'paid'

group by s.name,
c.name

order by s.name,
c.name;