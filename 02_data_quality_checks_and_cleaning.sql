--02_data_quality_checks_and_cleaning.sql
-- Superstore sales case study (SQL Server / SSMS)
--
-- Database: case_study
-- Input table:  dbo.Superstore_raw   (never modified)
-- Output table: dbo.Superstore_clean (created in Part B)
--
-- Process: Check -> Fix -> Verify
--   Part A: check the raw table for problems
--           (NULLs, bad numbers, bad dates, extra spaces)
--   Part B: build the clean table
--           (real dates, trimmed text, typed numbers)
--   Part C: verify the clean table
--           (row count, totals and dates match the raw table)

USE case_study;
GO

-- Check 1: NULL or blank values in key columns..

SELECT
    SUM(CASE WHEN Order_ID IS NULL OR LTRIM(RTRIM(Order_ID)) = '' THEN 1 ELSE 0 END)       AS missing_order_id,
    SUM(CASE WHEN Customer_ID IS NULL OR LTRIM(RTRIM(Customer_ID)) = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN Product_ID IS NULL OR LTRIM(RTRIM(Product_ID)) = '' THEN 1 ELSE 0 END)   AS missing_product_id,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END)    AS null_sales,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS null_discount,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END)   AS null_profit
FROM dbo.Superstore_raw;



-- Check 2: impossible numbers

SELECT
    SUM(CASE WHEN TRY_CAST(Sales AS float) <= 0 THEN 1 ELSE 0 END)     AS bad_sales,
    SUM(CASE WHEN TRY_CAST(Quantity AS int) <= 0 THEN 1 ELSE 0 END)    AS bad_quantity,
    SUM(CASE WHEN TRY_CAST(Discount AS float) < 0
              OR TRY_CAST(Discount AS float) > 1 THEN 1 ELSE 0 END)    AS bad_discount
FROM dbo.Superstore_raw;


-- Check 3: dates that cannot be converted 
SELECT COUNT(*) AS bad_dates
FROM dbo.Superstore_raw
WHERE TRY_CONVERT(date, Order_Date, 101) IS NULL
   OR TRY_CONVERT(date, Ship_Date, 101) IS NULL;


-- Check 4: shipped before ordered

select count(*) as ship_before_order
from dbo.Superstore_raw
where TRY_CONVERT(date,Ship_Date,101)< TRY_CONVERT(date,Order_Date,101);

-- Check 5: duplicate Row_IDs 

SELECT Row_ID, COUNT(*) AS times_found
FROM dbo.Superstore_raw
GROUP BY Row_ID
HAVING COUNT(*) > 1;


-- Check 6: same Order_ID + Product_ID on more than one row

select Order_ID,Product_ID,count(*) as times_found
from dbo.Superstore_raw
group by Order_ID,Product_ID
having count(*) >1;

-- Check 7: rows identical in every key column except Row_ID

select Order_ID,Order_Date,Customer_ID,Product_ID,
Sales,Quantity,Discount,Profit,count(*) as times_found
from dbo.Superstore_raw
group by Order_ID,Order_Date,Customer_ID,Product_ID,
sales,Quantity,Discount,Profit
having count(*)>1

-- Check 8: inspect the two suspected duplicate rows in full

select * from dbo.Superstore_raw
where Order_ID='US-2014-150119'
and Product_ID='FUR-ch-10002965'


-- Decision: rows 3406 and 3407 (Order US-2014-150119, Product FUR-CH-10002965)
-- are identical in every column except Row_ID. One copy is removed in
-- the clean table (9,994 -> 9,993 rows). The raw table is unchanged.


-- Check 9a: Product_Name with extra spaces

SELECT COUNT(*) AS product_name_spaces
FROM dbo.Superstore_raw
WHERE DATALENGTH(Product_Name) <> DATALENGTH(LTRIM(RTRIM(Product_Name)));

-- Check 9b: extra spaces in the other text columns
SELECT
    SUM(CASE WHEN DATALENGTH(Order_ID) <> DATALENGTH(LTRIM(RTRIM(Order_ID))) THEN 1 ELSE 0 END) AS order_id_spaces,
    SUM(CASE WHEN DATALENGTH(Order_Date) <> DATALENGTH(LTRIM(RTRIM(Order_Date))) THEN 1 ELSE 0 END) AS order_date_spaces,
    SUM(CASE WHEN DATALENGTH(Ship_Date) <> DATALENGTH(LTRIM(RTRIM(Ship_Date))) THEN 1 ELSE 0 END) AS ship_date_spaces,
    SUM(CASE WHEN DATALENGTH(Ship_Mode) <> DATALENGTH(LTRIM(RTRIM(Ship_Mode))) THEN 1 ELSE 0 END) AS ship_mode_spaces,
    SUM(CASE WHEN DATALENGTH(Customer_ID) <> DATALENGTH(LTRIM(RTRIM(Customer_ID))) THEN 1 ELSE 0 END) AS customer_id_spaces,
    SUM(CASE WHEN DATALENGTH(Customer_Name) <> DATALENGTH(LTRIM(RTRIM(Customer_Name))) THEN 1 ELSE 0 END) AS customer_name_spaces,
    SUM(CASE WHEN DATALENGTH(Segment) <> DATALENGTH(LTRIM(RTRIM(Segment))) THEN 1 ELSE 0 END) AS segment_spaces,
    SUM(CASE WHEN DATALENGTH(Country) <> DATALENGTH(LTRIM(RTRIM(Country))) THEN 1 ELSE 0 END) AS country_spaces,
    SUM(CASE WHEN DATALENGTH(City) <> DATALENGTH(LTRIM(RTRIM(City))) THEN 1 ELSE 0 END) AS city_spaces,
    SUM(CASE WHEN DATALENGTH(State) <> DATALENGTH(LTRIM(RTRIM(State))) THEN 1 ELSE 0 END) AS state_spaces,
    SUM(CASE WHEN DATALENGTH(Postal_Code) <> DATALENGTH(LTRIM(RTRIM(Postal_Code))) THEN 1 ELSE 0 END) AS postal_code_spaces,
    SUM(CASE WHEN DATALENGTH(Region) <> DATALENGTH(LTRIM(RTRIM(Region))) THEN 1 ELSE 0 END) AS region_spaces,
    SUM(CASE WHEN DATALENGTH(Product_ID) <> DATALENGTH(LTRIM(RTRIM(Product_ID))) THEN 1 ELSE 0 END) AS product_id_spaces,
    SUM(CASE WHEN DATALENGTH(Category) <> DATALENGTH(LTRIM(RTRIM(Category))) THEN 1 ELSE 0 END) AS category_spaces,
    SUM(CASE WHEN DATALENGTH(Sub_Category) <> DATALENGTH(LTRIM(RTRIM(Sub_Category))) THEN 1 ELSE 0 END) AS sub_category_spaces
      FROM dbo.Superstore_raw


-- Part B, Step 1: preview the duplicate row that will be removed

with numbered as (
select Row_ID,Order_ID,Product_ID,
ROW_NUMBER() over (partition by Order_ID,Order_Date,Customer_ID,Product_ID,Sales,Quantity,
Discount,Profit order by Row_ID)
as copy_number from dbo.Superstore_raw)

select * from numbered
where copy_number>1


-- Part B: build the clean table (dates converted, text trimmed,
-- numbers typed, one duplicate row removed)

WITH numbered AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY Order_ID, Order_Date, Customer_ID, Product_ID,
                            Sales, Quantity, Discount, Profit
               ORDER BY Row_ID
           ) AS copy_number
    FROM dbo.Superstore_raw
)
SELECT
    Row_ID,
    LTRIM(RTRIM(Order_ID))              AS Order_ID,
    TRY_CONVERT(date, Order_Date, 101)  AS Order_Date,
    TRY_CONVERT(date, Ship_Date, 101)   AS Ship_Date,
    LTRIM(RTRIM(Ship_Mode))             AS Ship_Mode,
    LTRIM(RTRIM(Customer_ID))           AS Customer_ID,
    LTRIM(RTRIM(Customer_Name))         AS Customer_Name,
    LTRIM(RTRIM(Segment))               AS Segment,
    LTRIM(RTRIM(Country))               AS Country,
    LTRIM(RTRIM(City))                  AS City,
    LTRIM(RTRIM(State))                 AS State,
    LTRIM(RTRIM(Postal_Code))           AS Postal_Code,
    LTRIM(RTRIM(Region))                AS Region,
    LTRIM(RTRIM(Product_ID))            AS Product_ID,
    LTRIM(RTRIM(Category))              AS Category,
    LTRIM(RTRIM(Sub_Category))          AS Sub_Category,
    LTRIM(RTRIM(Product_Name))          AS Product_Name,
    TRY_CAST(Sales AS decimal(10,4))    AS Sales,
    TRY_CAST(Quantity AS int)           AS Quantity,
    TRY_CAST(Discount AS decimal(4,2))  AS Discount,
    TRY_CAST(Profit AS decimal(10,4))   AS Profit
INTO dbo.Superstore_clean
FROM numbered
WHERE copy_number = 1;


----- Part C, Check 10: compare raw and clean totals
-- (clean should differ from raw only by the one removed duplicate row)

select 'raw' as source,
 count(*) as total_rows,
 sum(sales) as total_sales,
 sum(profit) as total_profit,
 sum(quantity) as total_quantity
from dbo.Superstore_raw
union all
select 'clean',
count(*),
sum(sales),
sum(profit),
sum(quantity)
from dbo.Superstore_clean


-- Part C, Check 11: Product_Name with extra spaces in the clean table

select count(*) as product_name_space
from dbo.Superstore_clean
where DATALENGTH(Product_Name)<> DATALENGTH(ltrim(rtrim(Product_Name)))


-- Part C, Check 12: data types of the clean table

select ordinal_position,column_name,data_type,character_maximum_length,numeric_precision,
numeric_scale from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='superstore_clean'
order by ORDINAL_POSITION


-- Part C, Check 13: NULL dates and ship-before-order in the clean table
SELECT
    SUM(CASE WHEN Order_Date IS NULL OR Ship_Date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN Ship_Date < Order_Date THEN 1 ELSE 0 END) AS ship_before_order
FROM dbo.Superstore_clean;

-- Part C, Check 14: duplicate rows in the clean table

SELECT Order_ID, Order_Date, Customer_ID, Product_ID,
       Sales, Quantity, Discount, Profit,
       COUNT(*) AS times_found
FROM dbo.Superstore_clean
GROUP BY Order_ID, Order_Date, Customer_ID, Product_ID,
         Sales, Quantity, Discount, Profit
HAVING COUNT(*) > 1; 

-- ============================================================
-- CLEANING SUMMARY
-- Raw table:   9,994 rows (dbo.Superstore_raw, unchanged)
-- Clean table: 9,993 rows (dbo.Superstore_clean)
--
-- Issues found and fixed:
--   1. 16 Product_Name values had a trailing space   -> trimmed
--   2. 1 duplicate row (Row_ID 3407, identical to 3406) -> removed
--
-- Conversions:
--   Order_Date, Ship_Date : text -> date
--   Sales, Profit         : decimal(10,4)
--   Discount              : decimal(4,2)
--
-- No NULLs, impossible numbers or invalid dates were found.
-- Negative Profit rows (losses) were kept on purpose.
-- ============================================================
