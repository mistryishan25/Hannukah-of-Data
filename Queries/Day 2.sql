-- Filter names with initials as JD

-- Does initials mean that only first name and last names are to be considered(i.e no middle names?)?
-- 	Assumption : I've considered middle names as not the part of an initial.


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

-- shopping list should have "cleaner" and bagel and coffee
select 
	distinct substring(sku,1,3) as categories 
from products
-- "KIT" - Kitchen
-- "HOM" = Home
-- "CMP" = Computer
-- "PET" = Pet accessories
-- "TOY" = Toys 
-- "DLI" - Daily
-- "COL" - Noah's collection
-- "BKY" - Bakery

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


