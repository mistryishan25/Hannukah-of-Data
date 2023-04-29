-- A women from Queens Village wearing ‘Noah’s Market’ sweatshirt

create temp table queens_customers as (
	select * from customers 
	where lower(citystatezip) like '%queens village%'  
)

-- List 10 products from each category to get some idea
select code, "desc"
from(
	select
	substring(sku,1,3) as code,
	"desc",
	row_number() over(partition by substring(sku,1,3) 
					  order by random()) as rn
	from products
) as sub
where rn<10


-- just to be sure about our selection of COL item - Jersey 
select 
	distinct
	split_part("desc", ' ', 2 ) 
from products where substring(sku,1,3) in ('COL')

-- find the products that have cat food and jersey  
create temp table valid_sku as (
	select
		sku, "desc"
	from products 
	where
		substring(sku,1,3) in ('COL', 'PET') and
		lower("desc") like '%jersey%' or lower("desc") like '%cat%'
)


select 
	q.customerid,
	q.name,
	q.phone,
	sum(qty) as purchases
from order_items 
	inner join orders 
	on orders.orderid = order_items.orderid
	inner join queens_customers q 
		on q.customerid = orders.customerid 
where
	order_items.sku in (select sku from valid_sku) and 
orders.customerid in (select customerid from queens_customers)
group by q.customerid, q.name, q.phone
order by purchases



