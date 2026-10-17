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


## Key findings

| Metric | Value |
|---|---|
| Orders | 5,009 |
| Total sales | 2,296,919.49 |
| Total profit | 286,409.08 |
| Profit margin | 12.47% |

**1. Sales grow, but the margin is slipping (Q6, Q7).**
Yearly sales rose from 483,966 in 2014 to 733,215 in 2017. The biggest jump was in 2016 (+29.47%), after a small dip in 2015 (-2.78%). The margin fell from 13.43% in 2016 to 12.74% in 2017. September to December bring about half of the yearly sales, and November is the best month (118,447.83 in 2017).

**2. Furniture earns almost nothing (Q2, Q9, Q10).**
Furniture has a profit margin of only 2.49%, against 17.40% for Technology and 17.04% for Office Supplies. Two sub-categories lose money: Tables (-17,725.48) and Bookcases (-3,472.56). Tables and Machines each appear four times in the 10 worst products by profit.

**3. Discounts above 20% turn sales into losses (Q11, Q12).**
Order lines with no discount have a margin of 29.51%. With a discount up to 20% it falls to 11.91%, and above 20% it is -37.34% (an average loss of 97.24 per line). 1,870 order lines (18.71%) lose money, a total of 156,119.23, and their average discount is 48.1%.

**4. Two states pull down the Central region (Q3, Q13).**
Central has the lowest margin of the four regions (7.92%). Texas (-25,729.36) and Illinois (-12,607.89) lose money, while the other 11 Central states are profitable. Texas and Illinois give average discounts of about 37% to 39%, and the profitable Central states give almost none.

**5. A few customers carry the profit (Q8, Q18, Q19).**
The 117 High-value customers (15% of 793) bring about 40% of the sales and 49% of the profit. The biggest customer by sales, Sean Miller (25,043.05), lost 1,980.74. Almost all customers (98.49%) ordered more than once, but this is a sample dataset, so it is not a real retention rate.

**6. Shipping (Q5, Q17).**
Standard Class carries about 60% of the orders and takes 5.01 days on average. Same Day takes 0.04 days on average.


## Recommendations

1. **Limit discounts to 20%, and review every discount above that.**
   Order lines with a discount above 20% lose 97.24 on average, and 1,870 lines lose money in total. Start with Texas, Illinois and the Central region, where the average discounts are highest.

2. **Fix the pricing of Tables and Bookcases.**
   Together they lose about 21,200 and keep Furniture at a 2.49% margin. Raise prices, cut discounts, or drop the worst products.

3. **Review the biggest loss-making products.**
   The Cubify CubeX 3D printers (-8,879.97 and -3,839.99) and the Lexmark MX611dhe printer (-4,589.97) lose far more than any other product. Check their costs and discounts.

4. **Prepare for the September to December peak.**
   These months bring about half of the yearly sales, so stock and staffing should be planned for them. Also investigate April 2017, when the margin fell to about 2.6%.

5. **Look at profit and not only sales when ranking customers.**
   The top customer by sales, Sean Miller, lost 1,980.74. Keep the 117 High-value customers, who bring 49% of the profit, and check profitability before giving large discounts to any customer.

