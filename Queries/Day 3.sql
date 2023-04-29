-- Hints 
-- He was a Aries born in the year of the Dog
-- Years of the Dog include 2030, 2018, 2006, 1994, 1982, 1970, 1958...
-- Aries -  March 21 to about April 19


-- The contractor guy 
select 
	customerid, 
	address,
	citystatezip
from customers
where customerid = 4164 


-- guy who lived in my neighborhood
select *  
from customers 
where 
	citystatezip = 'South Ozone Park, NY 11420' and 
	(extract(year from birthdate)%12 = 2 and extract(month from birthdate) in (3,4)) 








