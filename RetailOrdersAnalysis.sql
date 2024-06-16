create database Orders 

use Orders

select * from [dbo].[orders_data]

-- Write a SQL query to list all distinct cities where orders have been shipped.

select distinct city from orders_data

-- Calculate the total selling price and profits for all orders.
select [Order Id], sum(quantity*Unit_Selling_Price) as 'Total Selling Price',
cast(sum(quantity*unit_profit) as decimal(10,2)) as 'Total Profit'
-- , [Total Profit] (as it was already present in the table, we could directly use that column
from orders_data
group by [Order ID]
order by [Total Profit] desc

-- Write a query to find all orders from the 'Technology' category 
-- that were shipped using 'Second Class' ship mode, ordered by order date.
select [Order Id], [Order Date]
from orders_data
where category = 'Technology' and [Ship Mode] = 'Second Class'
order by [order date]

-- Write a query to find the average order value
select cast(avg(quantity * unit_selling_price) as decimal(10, 2)) as AOV
from orders_data

-- find the city with the highest total quantity of products ordered.
select top 1 city, sum(quantity) as 'Total Quantity'
from orders_data
group by city order by [Total Quantity] desc

-- Use a window function to rank orders in each region by quantity in descending order.
select [order id], region, quantity as 'Total_Quantity',
dense_rank() over (partition by region order by quantity desc) as rnk
from orders_data 
order by region, rnk 


-- Write a SQL query to list all orders placed in the first quarter of any year (January to March), including the total cost for these orders.


select [order id], [order date], month([order date]) as month from orders_data

select [Order Id], sum(Quantity*unit_selling_price) as 'Total Value'
from orders_data
where month([order date]) in (1,2,3) 
group by [Order Id]
order by [Total Value] desc


 select * from orders_data

-- find top 10 highest profit generating products 
select top 10 [product id],sum([Total Profit]) as profit
from [orders_data]
group by [product id]
order by profit desc;

-- alternate -> using window function     
with cte as (
select [product id], sum([Total Profit]) as profit
, dense_rank() over (order by sum([Total Profit]) desc) as rn
from orders_data
group by [Product Id]
)
select [Product Id], Profit
from cte where rn<=10;


--find top 3 highest selling products in each region

with cte as (
select region, [product id], sum(quantity*Unit_selling_price) as sales
, row_number() over(partition by region order by sum(quantity*Unit_selling_price) desc) as rn
from [orders_data]
group by region, [product id]
) 
select * 
from cte
where rn<=3;


-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
select year([order date]) as order_year,month([order date]) as order_month,
sum(quantity*Unit_selling_price) as sales
from orders_data
group by year([order date]),month([order date])
--order by year(order_date),month(order_date)
)
select order_month
, round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
, round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
from cte 
group by order_month
order by order_month


-- for each category which month had highest sales 
with cte as (
select category, format([order date],'yyyy-MM') as order_year_month
, sum(quantity*Unit_selling_price) as sales,
row_number() over(partition by category order by sum(quantity*Unit_selling_price) desc) as rn
from orders_data
group by category,format([order date],'yyyy-MM')
--order by category,format(order_date,'yyyyMM')
)
select category as Category, order_year_month as 'Order Year-Month', sales as [Total Sales]
from cte
where rn=1



select * from order_data
-- which sub category had highest growth by sales in 2023 compare to 2022
;
with cte as (
select [sub category] as sub_category, year([order date]) as order_year,
sum(quantity*Unit_selling_price) as sales
from orders_data
group by [sub category],year([order date])
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
, round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023
from cte 
group by sub_category
)
-- select * from cte2
select top 1 sub_category as 'Sub Category', sales_2022 as 'Sales in 2022',
sales_2023 as 'Sales in 2023'
,(sales_2023-sales_2022) as 'Diff in Amount'
from  cte2
order by (sales_2023-sales_2022) desc