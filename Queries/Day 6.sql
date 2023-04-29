-- she clips every coupon and shops every sale 

-- Find amount spent per customer per month
-- also average cost spent per product.
-- also average cost per order



select * from orders
order by total desc
select * from order_items where orderid = 13420


with profits_per_product as (
	select
	orderid,
	qty,
	(unit_price - wholesale_cost)::decimal as per_unit_profit,
	(unit_price - wholesale_cost)::decimal*qty as total_profit
	from 
		products p 
		right join order_items i
		on p.sku = i.sku
)

select
	max(c.customerid) as customerid,
	max(c.name),
	max(c.phone),
	max(o.total) total,
	sum(total_profit)::decimal as profit
from orders o
join profits_per_product ppp 
	on ppp.orderid = o.orderid
join customers c
	on o.customerid = c.customerid
group by c.customerid
order by profit