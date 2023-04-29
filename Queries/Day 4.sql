-- Hints : 
-- Claims the first pastries that came out of the oven
-- Came over to help at 5AM

-- Group and count if there is at least on BKY item in the orders
-- order by the time desc
-- select the earliest ones

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


select c.customerid,
c.phone,
count(*) 
from ranked_bky_orders as rbo
inner join customers as c
on c.customerid = rbo.customerid 
where rank=1 and rbo.hour between 4 and 5
group by c.customerid, c.phone
order by count(*) desc
limit 1