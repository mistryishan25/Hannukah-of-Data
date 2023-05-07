/*

CONTEXT:
- This SQL code is written to find the customer from Queens Village wearing ‘Noah’s Market’ sweatshirt who has purchased products that include cat food and jersey.

RESULT EXPECTATION:
- The expected result is to get the customer info for this person based on the hints given in the puzzle.

ASSUMPTION:
- The table 'customers' has the customer information, including the city, state, and zip code.
- The table 'products' contains the product information, including the SKU code and description.
- The table 'order_items' has the order item information, including the SKU and quantity.
- The table 'orders' has the order information, including the customer ID and order ID.

APPROACH:
- Create a temporary table 'queens_customers' to store customers from Queens Village.
- Select 10 products from each category using the 'products' table to get some idea.
- Create a temporary table 'valid_sku' to store the SKUs that contain cat food and jersey.
- Join the 'order_items,' 'orders,' and 'queens_customers' tables to get the customer information and the sum of their purchases, where the SKUs are in the 'valid_sku' table and the customer IDs are in the 'queens_customers' table.
- Order the result by the sum of the purchases and select the highest one.

*/



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



