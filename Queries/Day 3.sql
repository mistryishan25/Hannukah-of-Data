/*

CONTEXT:
- Finding the next guy who is an Aeries and was born in the year of the dogs.  

RESULT EXPECTATION:
Retrieve customer information for a customer who lives in a specific neighborhood and has a birth month and year that fall within a certain range.

ASSUMPTION:
- The 'customers' table contains all the relevant customer information.
- The birthdate field in the 'customers' table is in date format.
- The birth month and year range is calculated using the Chinese zodiac system, meaning year of the dog include 2030, 2018, 2006, 1994, 1982, 1970, 1958...
- Aries is zodiac sign for a person born between March 21 to about April 19

APPROACH:
- Look where the contractor guy from previous puzzle lived
- Filter based on the hints given

*/


-- The contractor guy from previous puzzle
select 
	customerid, 
	address,
	citystatezip
from customers
where customerid = 4164 


-- guy who lived in his neighborhood, the suspect
select *  
from customers 
where 
	citystatezip = 'South Ozone Park, NY 11420' and 
	(extract(year from birthdate)%12 = 2 and extract(month from birthdate) in (3,4)) 








