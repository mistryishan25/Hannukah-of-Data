/*

CONTEXT:
- This query is used to find the customer who ordered the most collectibles of all customers.

RESULT EXPECTATION:
- The query will return the customer information for the person with the most collectibles.

ASSUMPTIONS:
- The SKU for all collectibles starts with 'COL'.
- The customer information is stored in the 'customers' table.
- The order information is stored in the 'orders' table, with order ID as the primary key.
- The items associated with each order are stored in the 'order_items' table, with order ID and SKU as foreign keys.

APPROACH:
- Filter orders that have COL items 
- Group by customerid and count the qty of the

*/


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
