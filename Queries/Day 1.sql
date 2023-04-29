-- Approach
-- Spell out the last name for number
-- Clean the data in the phone number
	
create temp table clean_info as (
	select
		name,
-- First name
	split_part(upper(name),' ' ,1) as firstname,
-- Middle name
		case 
			when length(name) - length( replace(name, ' ', '')) = 1 
			then null
			else split_part(upper(name),' ' ,2) 
		end	as middlename,
-- Last Name
		case 
--  		there are only 2 parts to the name 
			when length(name) - length( replace(name, ' ', '')) = 1 
			then split_part(upper(name),' ' ,2)
			else split_part(upper(name),' ' ,3)
		end as lastname,
-- Cleaned phone number
		replace(phone, '-', '') as phone_number,
-- customerid
		customerid 
	from customers
);



-- Only later I realized that we also have middle name!
select length(lastname), lastname 
from clean_info 
where length(lastname) <= (select max(length(lastname)) from clean_info) and 
		length(lastname) >9 ;


-- Create a mapping from numbers to alphabets
	-- A is 65 so we use row_numbers to generate a char seq
	-- PQRS - 7 AND WXYZ- 9 (Why tho?)
	-- Change YZ-9, V-8, S-7   

create temp table interim_seq as (
	select 
		case when letters = 'S' then 7
			 when letters = 'V' then 8
			 when letters = 'Y' then 9
			 when letters = 'Z' then 9
			 when letters = ' ' then 0 
			 else int_map 
		end as key_int,
		letters
	from (
	select 
		generate_series(0,25)/3 + 2 as int_map,
		chr(generate_series(0,25)+65) as letters) as sub	
);

create temp table final_map as (
	select 
	letters,
	key_int,
	repeat(cast(key_int as char),cast(print_times as int)) as code
from (
	select
		letters,
		key_int,
		row_number() over(partition by key_int) as print_times
	from interim_seq 	
	) as sub_seq
);

create temp table char_pos as (
	select generate_series(1,10) as n 
);

-- get the individual letters and the corresponding code

create temp table coded_letters as (
	select
	distinct
		customerid,
		lastname,
		phone_number,
		n,
		substring(lastname,n,1),
	-- 	concate(code) over(group by lastname order by n) as phone,
		key_int
	from char_pos
		cross join clean_info
		right join final_map
		-- the sep letters should match the code form mapping
			on letters = substring(lastname, n, 1)
	where n between 0 and length(lastname) and 
		length(lastname) = 10
	order by 1,2
);


select 
	customerid,
	phone_number,
-- array_agg gives output as text so we need to convert to string 
  	array_to_string(array_agg(key_int), '') as decoded_number
from coded_letters
group by customerid, phone_number
having array_to_string(array_agg(key_int), '') = phone_number
;
	
select * from customers where customerid = 3188

