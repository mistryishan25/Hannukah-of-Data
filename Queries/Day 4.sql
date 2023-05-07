/* 

CONTEXT:
- This SQL code is intended to find the customer who made the most orders between 4:00 am and 5:00 am and purchased at least one bakery product.

RESULT EXPECTATION:
- The result should display the customer ID, phone number, and the number of orders made between 4:00 am and 5:00 am.

ASSUMPTION:
- It is assumed that the substring 'BKY' is used to identify bakery products.
- It is given that the customer always picked up the first batch of pastries straight from the oven

APPROACH:
- A CTE is used to filter out orders that have at least one bakery product.
- Another CTE is used to rank the orders by the time they were shipped.
- Finally, the ranked orders are joined with the customers table to retrieve the phone number of each customer, and then grouped by customer ID and phone number to count the number of orders made between 4:00 am and 5:00 am. 
- The result is then sorted by the number of orders in descending order and limited to the customer with the most orders. 

*/

with bky_orders as (
	select
		orderid,
		count(case when substring(sku ,1,3) = 'BKY' then 1 end) as count_bky
	from order_items
	group by orderid
	having count(case when substring(sku ,1,3) = 'BKY' then 1 end)>0
) 

, ranked_bky_orders as (
select 
	bo.orderid,
	o.customerid,
	o.shipped,
	extract( hour from o.shipped) as hour,
	rank() over(partition by shipped::date order by shipped::time asc)
from bky_orders as bo
	inner join orders as o
	on o.orderid = bo.orderid
)


select 
	c.customerid,
	c.phone,
	count(*) 
from ranked_bky_orders as rbo
	inner join customers as c
	on c.customerid = rbo.customerid 
where rank=1 and rbo.hour between 4 and 5
group by c.customerid, c.phone
order by count(*) desc
limit 1
