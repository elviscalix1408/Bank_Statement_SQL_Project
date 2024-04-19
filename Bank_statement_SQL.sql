select
	*
from
	transaction_history

-- Adding up the net amount
-- This is where the discrepancy began, it should add up to Zero
	
Select
	sum(net_amount) as net_amount
from
	transaction_history

-- Further investigating, separated negative and positive numbers with CASE function
-- added all negative numbers and all positive numbers in their own columns

select
	sum(case when net_amount > 0 then net_amount else 0 end) as amount_received
	, sum (case when net_amount < 0 then net_amount else 0 end) as amount_paid
from
	transaction_history
	
	
-- split of negative and positive as individual transactions
select
	case when net_amount > 0 then net_amount else 0 end as "amount received"
	, case when net_amount < 0 then net_amount else 0 end as "amount paid"
	
from
	transaction_history
	


---- join transaction_details table, to add account card number
select
	d.account_card
	, case when t.net_amount > 0 then net_amount else 0 end as "amount received"
	, case when t.net_amount < 0 then net_amount else 0 end as "amount paid"
	
from
	transaction_history t
		join 
			transaction_details d
			on t.transaction_id = d.transaction_id


--specifying specific card
Select
	*
from
	transaction_details
where
	account_card = 'MasterCard Debit 9945'
			
--- sum of total amount spent/ credited based off account card
select
	d.account_card
	, sum(case when t.net_amount > 0 then net_amount else 0 end) as "amount received"
	, sum(case when t.net_amount < 0 then net_amount else 0 end)as "amount paid"
	
from
	transaction_history t
		left join 
			transaction_details d
			on t.transaction_id = d.transaction_id
			group by
				d.account_card
				
	
	
				
--- partition by add_details (location) and get count of location instances
--- include transactoin type, net amount, transaction date by joiing transaction details and transaction
--- type tables
--- linking each table by unique/ primary key

select
	
	 count(ty.transaction_type) over(partition by p.add_details)
	, t.trans_dt
	, t.net_amount
	, ty.transaction_type
	, p.add_details
	
from
	transaction_history t
		left join 
			transaction_details p			
			on t.transaction_id = p.transaction_id
			left join
				transaction_type ty
					on p.trans_type_id = ty.trans_type_id
	
				
			
			
Select
	*
from
	transaction_history

	


	
---- CTE requesting a distinct count of the net_amount where the count appears 1 time
---- I also used the case function to separate the positive and negative numbers into separate columns
---- ABS function to convert the negative numbers to positive, so the distinct number
---- from each column is pulled when requested to match
---- Grouped by net amount

with distinct_net_amount as (select
	distinct count(net_amount) as record_count
	, (case when net_amount > 0 
		  then net_amount else 0 end) as amount_received
	, ABS(case when net_amount < 0 
		   then net_amount else 0 end) as amount_paid
from
	transaction_history
group by
	net_amount
having
	count(net_amount) = 1)
	
--- Utilized this statment below with the CTE
--- This statement sums up each category in the CTE: amount_received and amount_paid
--- I am joining the CTE to itself by creating two separate aliases: distinct_net_amount a 
--and distinct_net_amount b
--- This will pull the distinct matched amount_paid and amount_received values 
---- I have used the 'on' statement to match each column to one another:
-- a.amount_received = b.amount_paid
	
select
	 sum(a.amount_received) as amount_received
	,sum(b.amount_paid) as amount_paid
from distinct_net_amount a
join
distinct_net_amount b

on a.amount_received = b.amount_paid
group by
	a.amount_received
	, b.amount_paid


	
	
--- Experimenting with different functions: Advanced window functions, row, between, preceeding

select
	d.trans_dt
	, d.net_amount
	, sum(d.net_amount) over(order by d.trans_dt) as running_total
from
	transaction_history d
	group by
	d.trans_dt
	, d.net_amount
	
	

---- Code to narrow down specific transaction_type : 'Cash out' where I sent money to people or other 
--accounts
--- Joined tables: transaction_details and transaction_type to add more infomation to the result set

select
	h.trans_dt
	, sum(h.net_amount)
	, d.add_details
	, t.transaction_type
from
	transaction_history h
	join
		transaction_details d
	on h.transaction_id = d.transaction_id
	left join
		transaction_type t
			on t.trans_type_id = d.trans_type_id
	group by
		h.trans_dt
		, d.add_details
		, t.transaction_type
	having
			t.transaction_type ilike '%cash out%'