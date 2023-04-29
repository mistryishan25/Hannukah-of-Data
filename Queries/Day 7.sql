-- She moved in with him
-- bought something that comes in different colours
-- at the same date and around the same time.


create temp table emily_orders as (
		select
		o.orderid,
		p.sku,
		"desc",
		substring("desc", 1, position(' (' in "desc")-1) as without_colour,
		shipped
-- 		,shipped::date as e_date,
-- 		extract(hour from shipped) as e_hour
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
where position('(' in "desc")>0
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

-- all the orders that have releavant items
-- same date
create temp table suspects_26 as (
select
	o.orderid,
	oi.sku,
	o.customerid,
	o.shipped

from order_items oi
join orders o 
on oi.orderid = o.orderid
where sku in (select sku from relevant_items)
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
where s.sku in (select sku from relevant_items)
	and abs(extract (epoch from (s.shipped::time - e.shipped::time))) < 600
)

select * from customers where customerid in (select customerid from final_suspect)


-- let's see how many of these were on the same date?

--  possible_customers as (
-- 	select 
-- 	orders.orderid,
-- 	customerid,
-- 	orders.shipped::date,
-- 	extract(hour from orders.shipped) 
	
-- 	from orders 
-- 	inner join relevant_orders ro 
-- 	on orders.orderid = ro.orderid
-- 	where 
-- 		orders.shipped::date in (select distinct date from emily_orders)
-- 		and extract(hour from orders.shipped) in (select distinct extract(hour from shipped) from emily_orders) 
-- )

-- select * from possible_customers

-- select * from emily_orders


-- select * from relevant_orders


-- select *
-- from customers 
-- where customerid in (select customerid from possible_customers)

-- the only boy here is micheal




