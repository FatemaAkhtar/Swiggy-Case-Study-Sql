use swiggy;
select * from menu;
select * from users;
select * from orders;
select * from order_details;
select * from food;
select * from delivery_partner;
select * from restaurants;


-- 1. Find customers who have never ordered

select name from users
where user_id not in (select user_id from orders);




-- 2. Average Price/dish

SELECT f.f_name, AVG(price) AS 'Average Price'
FROM menu m
JOIN food f ON m.f_id = f.f_id
GROUP BY f.f_name;



-- 3. Find the top restaurant in terms of the number of orders for a given month

select   r.r_name as 'RES_name',count(order_id) as 'num_order'
from orders as o
join restaurants as r
on r.r_id = o.r_id 
where monthname(date) ='june' group by RES_name
ORDER BY num_order DESC
LIMIT 1;

select   r.r_name as 'RES_name',count(order_id) as 'num_order'
from orders as o
join restaurants as r
on r.r_id = o.r_id 
where monthname(date) ='may' group by RES_name
ORDER BY num_order DESC
LIMIT 1;

select   r.r_name as 'RES_name',count(order_id) as 'num_order'
from orders as o
join restaurants as r
on r.r_id = o.r_id 
where monthname(date) ='july' group by RES_name
ORDER BY num_order DESC
LIMIT 1;



-- 4. restaurants with monthly sales greater than x for 

select   r.r_name as 'RES_name',sum(amount) as 'Revenue'
from orders as o
join restaurants as r
on r.r_id = o.r_id 
where monthname(date) ='june' group by RES_name
having revenue > 500;




-- 5. Show all orders with order details for a particular customer in a particular date range

select o.order_id ,r.r_name as 'Res_name',f.f_name as 'food name'
from orders as o
join restaurants as r
on o.r_id = r.r_id  
join order_details as od 
on o.order_id = od.order_id 
join food as f
on od.f_id = f.f_id 
where user_id = (select user_id from users where name = 'ankit')
and date > '2022-06-10' and date < '2022-07-10';




-- 6. Find restaurants with max repeated customers 

select r.r_name ,count(*) as 'Regular_Customer'
from (
select r_id , user_id, count(*) as 'visits' from orders group by r_id ,user_id
having visits > 1
) as t 
join restaurants as r
on r.r_id = t.r_id
group by r.r_name
order by Regular_Customer desc limit 1;





-- 7. Month over month revenue growth of swiggy

select Months , 
((Total_Revenue-previous_revenue)/previous_revenue)*100
 as Revenue_by_month
from (with sales as(
SELECT MONTHNAME(date) AS `Months`,
 SUM(amount) AS `Total_Revenue`
FROM orders
GROUP BY Months
)
select Months , Total_Revenue,LAG(Total_Revenue,1) over (order by Total_Revenue) 
as 'previous_revenue' from sales
) as t ;



-- 8. Customer - favorite food
with fav as (
select o.user_id ,od.f_id,count(*) as 'frequency'
from orders o
join order_details as od 
on o.order_id = od.order_id 
group by o.user_id ,od.f_id
order by o.user_id
)
select u.name as 'customer' ,f.f_name as 'favourite_Food' ,t1.frequency from fav t1 
join food as f
on f.f_id = t1.f_id
join users as u on u.user_id = t1.user_id 
where t1.frequency = (select MAX(frequency) from fav t2 where t2.user_id = t1.user_id );




-- 9 - Most Paired Products

WITH temp AS (
    SELECT 
        order_id,
        GROUP_CONCAT(f_id ORDER BY f_id SEPARATOR ',') AS product_ids 
    FROM 
        order_details
    GROUP BY 
        order_id
    HAVING 
        COUNT(*) > 1
)
SELECT 
    f1.f_name AS product1, 
    f2.f_name AS product2, 
    COUNT(*) AS pair_count
FROM 
    temp a
JOIN 
    temp b ON a.order_id = b.order_id 
JOIN 
    order_details o1 ON a.order_id = o1.order_id
JOIN 
    order_details o2 ON b.order_id = o2.order_id
JOIN 
    food f1 ON o1.f_id = f1.f_id
JOIN 
    food f2 ON o2.f_id = f2.f_id
GROUP BY 
    product1, 
    product2
ORDER BY 
    pair_count DESC;




-- 10 - Find the most loyal customers for all restaurant

select r.r_name as 'RES_name',u.name as 'Loyal Customers', 
count(order_id) as 'number_orders' 
from orders as o
join users as u
on u.user_id = o.user_id
join restaurants as r
on r.r_id = o.r_id
 group by u.name,r.r_name
having number_orders > 1;