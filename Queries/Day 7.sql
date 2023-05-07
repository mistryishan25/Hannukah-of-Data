/*

CONTEXT:
- This query is designed to identify potential customers based on a previous order made by Emily (customerid = 8342).

RESULT EXPECTATION:
- The result of the query should provide the customer information for the person who have ordered items similar to the ones Emily purchased and were shipped within 10 minutes of her order.

ASSUMPTIONS:
- The relevant products are defined as products with a matching substring without the colour in the description.
- The relevant items are those which were ordered by customers within the same date as Emily's order.
- The suspicious orders would are the ones where the time difference between Emily's order and the other orders should be less than 10 minutes.

APPROACH:
- A temporary table named "emily_orders" is created to store all the details of Emily's orders.
- Another temporary table named "relevant_items" with products matching(without the colour) the ones from emily orders.
- A temporary table named "suspects_26" is created to store all the orders that have relevant items, are shipped within the same date as Emily's order.
- A final temporary table named "final_suspect" is created to narrow down the list of suspicious orders to those shipped within 10 minutes of Emily's order.

*/


create temp table emily_orders as (
		select
		o.orderid,
		p.sku,
		"desc",
		substring("desc", 1, position(' (' in "desc")-1) as without_colour,
		shipped
	from 
		orders o
		join order_items i 
		on o.orderid = i.orderid 
		join products p
		on p.sku = i.sku
	where
		customerid = 8342
		and position('(' in "desc")>0  
)

-- orders that contain the same kinds of items 
create temp table relevant_items as ( 
select 
	sku,
	"desc",
	substring("desc", 1, position(' (' in "desc")-1) as wo_colour
from products 
where 
	position('(' in "desc")>0
	and substring("desc", 1, position(' (' in "desc")-1) in
	(select without_colour from emily_orders)
except
select 
	sku, 
	"desc",
	without_colour
from emily_orders
order by "desc"
)

-- all the orders that have releavant items and are on the same date
create temp table suspects_26 as (
select
	o.orderid,
	oi.sku,
	o.customerid,
	o.shipped

from order_items oi
	join orders o 
	on oi.orderid = o.orderid
where 
	sku in (select sku from relevant_items)
	and shipped::date in (select distinct shipped::date from emily_orders)
)


-- Narrowing it down to a smaller number based on time
create temp table final_suspect as (
select 
	distinct s.orderid,
	s.sku,
	s.customerid,
	s.shipped::time - e.shipped::time as time_diff
from suspects_26 s
	left join emily_orders e
	on s.shipped::date = e.shipped::date
where 
	s.sku in (select sku from relevant_items)
	and abs(extract (epoch from (s.shipped::time - e.shipped::time))) < 600
)

-- Getting information about the suspect
select *
from customers 
where customerid in (select customerid from final_suspect)




