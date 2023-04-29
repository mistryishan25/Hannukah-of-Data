-- Hints : 
-- He owns an entire set of Noah’s collectibles! 

-- Just to get an idea of all the collectibles

select * 
from products
where sku like 'COL%'

-- Let's find the customer that ordered the most collectibles of them all.
with suspect as (
select 
	o.customerid,
	sum(qty) as total_col_items
	
from order_items oi
join orders o
on o.orderid = oi.orderid
where substring(sku, 1,3) = 'COL'
group by o.customerid
order by total_col_items desc
limit 1 
)
	
-- getting the phone number of the last guy
select * from customers
where customerid in (select customerid from suspect)