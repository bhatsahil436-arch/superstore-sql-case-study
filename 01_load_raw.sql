-- 01_load_raw.sql
-- Superstore sales case study (SQL Server / SSMS)
--
-- Source: Kaggle "Superstore Dataset" (Sample - Superstore.csv), 9,994 rows
-- Database: case_study
-- Table: dbo.Superstore_raw (kept untouched; cleaning is done on a copy)

IF DB_ID('case_study') IS NULL CREATE DATABASE case_study;
GO

use case_study

-- Check: row count of the raw table 

select count(*) as total_rows
from dbo.superstore_raw


-- Check: column names and data types of the raw table
SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Superstore_raw'
ORDER BY ORDINAL_POSITION;


