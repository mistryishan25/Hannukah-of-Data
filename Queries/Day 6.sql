/*

CONTEXT:
- This query aims to highlight adn quantify the customer who has made been the most frugal with their shopping habits.

RESULT EXPECTATION:
- The SQL code returns the customer ID, name, phone number, total amount spent by the customer, and the profit earned by the customer.

ASSUMPTIONS:
- The customers, orders, order_items, and products tables exist and contain the relevant columns.
- Profit = (unit price - wholesale) * quantity
- There are no NULL values in the relevant columns.

APPROACH:
- Create a CTE profits_per_product that calculates the profit earned per unit and total profit for each order.
- Join the orders table with the profits_per_product CTE and the customers table to get customer information for each order.
- Group the results by customer ID and sum the total profit for each customer.
- Order the results by profit in ascending order, and limit the output to the customer with the highest profit.
*/



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
limit 1
