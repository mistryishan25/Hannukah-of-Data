/*

CONTEXT: 
- This SQL code is used to identify orders of a specific customer with initials JD who have purchased at least two items from a shopping list that includes cleaner, bagel, and coffee.

RESULT EXPECTATION:
- The expected result is to retrieve the customer information of a specific customer.

ASSUMPTION:
- The assumption is that the names table already exists with the necessary columns.
- The shopping list only includes the products that have the corresponding category codes in their SKU.
- The initials are just from the first name and the last name i.e. middle name is omitted.

APPROACH:
- First, a temporary table "names" is created to split the customer name into first, middle, and last names.
- Then, a temporary table "suspects" is created to identify the customers with initials JD.
- A temporary table "sus_order_items" is created to retrieve the relevant shopping list items.
- Another temporary table "sus_orders" is created to identify the orders containing items from the above temp table.
- Finally, the customer information of the identified customer is retrieved by joining the "suspects" and "orders" tables with the "customers" table. 

*/


create temp table names as (
	select customerid,
	split_part(name, ' ', 1) as firstname,
	-- Check for the middle name
	case 
		when length(name) - length(replace(name, ' ', ''))= 1
		then null 
		else split_part(name, ' ', 2)
	end	as middlename,
	case 
		when length(name) - length(replace(name, ' ', ''))= 1
		then split_part(name, ' ', 2) 
		else split_part(name, ' ', 3) 
	end as lastname
	from customers 
);

create temp table suspects as (
	select * 
	from (
		select
		customerid,
		substring(firstname, 1,1) || substring(lastname,1,1) as initials	
		from names
	) as sub
where initials = 'JD'
);


create temp table sus_order_items as (
	select *
	from products
	where 
		upper("desc") like '%CLEAN%' OR
		upper("desc") like '%BAGEL%' OR 
		( upper("desc") like '%COFFEE%' AND substring(sku,1,3) <> 'KIT')
)


-- search for orders that contain order_items from above
-- filter orders that contain at least two of the above items
create temp table sus_orders as (
	select 
		orderid,
		count(sku) 
	from order_items
	where sku in (select sku from sus_order_items)
	group by orderid
	having count(sku) >1
	)


-- getting info about the suspect
select * from  customers where customerid = (select 
	orders.customerid
	from suspects 
	join orders on orders.customerid = suspects.customerid
where orderid in (select orderid from sus_orders) ) 


