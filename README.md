# Superstore Sales Analysis (SQL Server)

## Overview
This project analyses the Superstore sales dataset (9,994 order lines from 2014 to 2017) using SQL Server. I loaded the raw data, checked and cleaned it, and then wrote 19 queries to find where the business makes money and where it loses money.

## Business problem
Superstore wants to know which products, regions and customer segments make a profit, and where it is losing money.

## Tools
- SQL Server Express and SSMS
- Git and GitHub

## Dataset
- Source: Kaggle "Superstore Dataset" (Sample - Superstore.csv)
- 9,994 order lines and 21 columns (orders, customers, products, region, sales, quantity, discount, profit)
- Loaded into SQL Server with the Import Flat File wizard as `dbo.Superstore_raw`

## Data cleaning
The raw table was never changed. All cleaning was done on a copy, `dbo.Superstore_clean`.

**Checks on the raw table (no problems found):**
- No NULL or blank values in the key columns
- No zero or negative Sales or Quantity, and no Discount outside 0 to 1
- All dates are valid (month/day/year), and no order ships before it was placed
- No duplicate Row_IDs

**Problems found and fixed:**
- 16 `Product_Name` values had an extra space at the end, which I trimmed
- 1 duplicate row (Row_ID 3407, identical to Row_ID 3406 apart from the ID) was removed, so the clean table has 9,993 rows

**Conversions:** `Order_Date` and `Ship_Date` from text to `date`, `Sales` and `Profit` to `decimal(10,4)`, `Discount` to `decimal(4,2)`.

Rows with negative profit were kept on purpose, because they are real losses and the focus of the analysis.

**Verification:** after cleaning, the row count, the totals of sales, profit and quantity, the trimmed names, the data types and the dates were all checked against the raw table.
