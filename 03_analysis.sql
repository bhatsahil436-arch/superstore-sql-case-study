-- 03_analysis.sql
-- Superstore sales case study (SQL Server / SSMS)
--
-- Business problem:
-- Superstore wants to know which products, regions and customer
-- segments make a profit, and where it is losing money.
--
-- All queries read the cleaned table: dbo.Superstore_clean

USE case_study;
GO

-- Q1: overall totals and profit margin

select count(distinct Order_ID) as total_orders,
round(sum(Sales),2) as total_sales,
round(sum(Profit),2) as total_profit,
ROUND(sum(profit) / sum(sales)*100,2) as profit_margin
from dbo.Superstore_clean

-- Q2:Superstore sells Furniture, Office Supplies and Technology. How much do they sell in each category,
--how much profit do they make, and what is their profit margin-pct

select category,
count(distinct order_id) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales)*100,2) as profit_margin_pct
from dbo.Superstore_clean
group by category
order by total_profit desc


-- Q3: How many orders does each region have,how much does it sell,how much profit does it make, and what is its profit margin?

SELECT region,
count(distinct Order_ID) as total_orders,
round(sum(Sales),2) as total_sales,
round(sum(Profit),2) as total_profit,
round(sum(Profit)/sum(sales)*100,2) as profit_margin_pct
from dbo.Superstore_clean
group by Region
order by total_profit desc


--Q4: Customers belong to the Consumer, Corporate or Home Office segment. How many orders and customers does each segment have,
--and what are its sales, profit and profit margin?

SELECT Segment,
COUNT(distinct Order_ID) as total_orders,
count(distinct Customer_ID) as total_customers,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales)*100,2) as profit_margin_pct 
FROM dbo.Superstore_clean
group by Segment
order by total_profit desc


--Q5:Superstore ships orders in four ways: Standard Class, Second Class, First Class and Same Day.
--How many orders does each ship mode have,
--how much does it sell, and what is the average sales value of an order?

select Ship_Mode,
count(distinct Order_ID) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(sales)/count(distinct order_id),2) as avg_sales_per_order
from dbo.Superstore_clean
group by Ship_Mode
order by total_orders desc


--Q6:in superstore How many orders, how much sales and how much profit did it make in each year,
--and what was the profit margin each year 

select YEAR(order_date) as order_year,
count(distinct Order_ID) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales)*100,2) as profit_margin_pct
from dbo.Superstore_clean
group by YEAR(order_date)
order by order_year

--Q7: Within the latest year (2017), which months sell the most? How many orders,
--how much sales and how much profit were made in each month?

select month(order_date) as order_month,
count(distinct Order_ID) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit
from dbo.Superstore_clean
where year(order_date)=2017
group by MONTH(order_date)
order by order_month


--Q8:Which 10 customers bring in the most sales? For each one,
--show how many orders they placed, their total sales and their total profit.

SELECT top 10 Customer_ID,Customer_Name,
count(distinct Order_ID) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit
from dbo.Superstore_clean
group by Customer_ID,Customer_Name
order by total_sales desc


--Q9: : Superstore sells many sub-categories, such as Chairs, Phones and Tables.
--Which of them have a negative total profit (they lose money), and how much do they lose?

select category,Sub_Category,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit) / sum(sales)*100,2) as profit_margin_pct
from dbo.Superstore_clean
group by Category,Sub_Category
having round(sum(profit),2)<0
order by total_profit

--Q10:Which 10 individual products make the most profit? For each one, show the quantity sold, total sales and total profit.

select top 10 Product_ID,Product_Name,
sum(quantity) as total_quantity,
ROUND(sum(sales),2) as total_sales,
ROUND(sum(profit),2) as total_profit
from dbo.Superstore_clean
group by Product_ID,Product_Name
order by total_profit desc

--or-we can find for last 10 products 

--Which last 10 individual products make the most profit? For each one, show the quantity sold, total sales and total profit.
select top 10 Product_ID,Product_Name,
sum(quantity) as total_quantity,
ROUND(sum(sales),2) as total_sales,
ROUND(sum(profit),2) as total_profit
from dbo.Superstore_clean
group by Product_ID,Product_Name
order by total_profit


--Q11:Group every order line into one of three discount bands: No discount (discount is 0), Up to 20% (above 0 and up to 0.20)
--and Above 20% (above 0.20). For each band, how many order lines are there, and 
--what are the sales, the profit, the profit margin and the average profit per line?

SELECT 
    CASE
        WHEN Discount = 0   THEN 'NO DISCOUNT'
        WHEN Discount <= 0.2 THEN 'UP TO 20%'
        ELSE 'ABOVE 20%'
    END AS discount_band,
Count(*) as order_lines,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit) /sum(sales)*100,2) as profit_margin_pct,
round(sum(profit)/count(order_id),2) as average_profit_per_line
from dbo.Superstore_clean
group by  case
    when Discount=0 then 'NO DISCOUNT'
    when Discount<=0.2 then 'UP TO 20%'
    else 'ABOVE 20%'
    end 
order by profit_margin_pct desc

--Q12:How many order lines are loss-making (profit below 0)? What is their total loss,
--what share of all order lines are they, and what is their average discount?

select
sum(case when profit<0 then 1 else 0 end) as loss_lines,
round(sum(case when profit<0 then profit else 0 end),2) as total_loss,
round(100.0*sum(case when  profit<0 then 1 else 0 end)/ count(*),2) as loss_lines_pct,
round(avg(case when profit<0 then discount end)*100.0,1) as avg_discount_pct
from dbo.Superstore_clean


--Q13:Which states have a negative total profit? For each one, show the number of orders,
--the sales, the profit and the profit margin.sort result by total profit ascending

select State,
count(distinct Order_ID) as total_orders,
round(sum(sales),2) as total_sales,
round(sum(profit),2) as total_profit,
round(sum(profit)/sum(sales)*100,2) as profit_margin_pct
from dbo.Superstore_clean
group by State
having round(sum(profit),2)<0
order by total_profit 


--Q14:For each year, show the total sales, the previous year’s sales and the growth percentage compared with the previous year.

with yearly_sales as(
select YEAR(order_date) as order_year,
round(sum(sales),2) as total_sales
from dbo.Superstore_clean
group by YEAR(order_date))

select order_year,
round(total_sales,2) as total_sales,
round(lag(total_sales) over(order by order_year),2) as previous_year_sales,
round(100.0 *( total_sales-lag(total_sales)over(order by order_year))
/lag(total_sales) over (order by order_year),2) as growth_pct
from yearly_sales
order by order_year



--Q15:In each category, which 3 products have the highest sales? Show the category,
--the product and its total sales, and its rank within the category.

with pro_sales as (
select Category,Product_ID,Product_Name,
round(sum(sales),2)  as total_sales
from dbo.Superstore_clean
group by Category,Product_ID,Product_Name
),

ranked as (
select *, 
rank() over(partition by category order by total_sales desc) as sales_rank
from pro_sales
)

select Category,Product_ID,Product_Name,total_sales,sales_rank
from ranked
where sales_rank<=3
order by category,sales_rank


--Q16:For each month of 2017, show the monthly sales and the running total (cumulative sales from January up to that month).

with monthly_sales as (
select month(order_date) as order_month,
sum(sales) as monthly_sales
from dbo.Superstore_clean
where year(order_date)=2017
group by month(Order_Date)
)
select order_month,
round(monthly_sales,2) as monthly_sales,
round(sum(monthly_sales) over(order by order_month),2) as running_total_sales
from monthly_sales
order by order_month


--Q17: For each ship mode, how many days pass on average between the order date and the ship date?
--Also show the fastest and the slowest delivery.

select Ship_Mode,
count(*) as total_lines,
round(avg(DATEDIFF(day,Order_Date,Ship_Date)*1.0),2) as avg_delivery_days,
min(DATEDIFF(day,Order_Date,Ship_Date)) as fastest_days,
max(datediff(day,order_date,ship_date)) as slowest_days
from dbo.Superstore_clean
group by Ship_Mode
order by avg_delivery_days



--Q18:Classify each customer by their total sales: High (5,000 or more), Medium (2,000 up to 5,000) and 
--Low (below 2,000). For each group, how many customers are there,
--what are their total sales and profit, and what share of all sales do they bring?

with Customer_sales as (
select customer_id,
sum(sales) as cust_sales,
sum(profit) as cust_profit
from dbo.Superstore_clean
group by Customer_ID
)

select 
case 
when cust_sales >=5000 then 'HIGH'
when cust_sales >=2000 then 'MEDIUM'
 else 'LOW'
 end as                 customer_group,
count(distinct customer_id) as   total_customers,
round(sum(cust_sales),2) as total_sales,
round(sum(cust_profit),2) as total_profit,
ROUND( 100.0* sum(cust_sales) /(select sum(sales) from dbo.superstore_clean),2) as sales_share_pct
from Customer_sales
group by  case 
 when cust_sales>=5000 then 'HIGH'
 when cust_sales>=2000 then 'MEDIUM'
 else 'LOW' end
order by total_sales desc


---Q19:How many customers placed only one order, and how many placed more than one (repeat customers)? For each type,
--show the number of customers, their share of all customers, their total sales and their share of all sales.

with customer_orders as (
select Customer_ID,
count(distinct Order_ID) as cust_orders,
sum(sales) as cust_sales
from dbo.Superstore_clean
group by Customer_ID)

select case 
when cust_orders=1 then 'ONE TIME'
else 'REPEAT'
end    as           customer_type,
count(distinct customer_id) as total_customers,
round(100.0 * count(*) /(select count(distinct customer_id) from dbo.superstore_clean),2) as customer_pct,
round(sum(cust_sales),2) as total_sales,
round(100.0*sum(cust_sales) / (select sum(sales) from dbo.superstore_clean),2) as sales_share_pct
from customer_orders
group by case
   when cust_orders=1 then 'ONE TIME'
   else 'REPEAT' end
order by total_customers desc






