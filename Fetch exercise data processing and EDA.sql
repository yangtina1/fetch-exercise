-- EDA & Data pre-processing
SELECT COUNT(*), COUNT(DISTINCT ID) FROM `fetch-exercise-437700.fetch.user`;  -- 100K Users, no duplicates
SELECT COUNT(*), COUNT(DISTINCT BARCODE) FROM `fetch-exercise-437700.fetch.product`; 
SELECT COUNT(*) FROM `fetch-exercise-437700.fetch.product` WHERE BARCODE IS NULL; -- 845,552 records, with missing barcodes and duplicates
SELECT COUNT(*), COUNT(DISTINCT RECEIPT_ID) FROM `fetch-exercise-437700.fetch.transaction`; -- 50K records, only 24,440 unique ID
SELECT MIN(SCAN_DATE), MAX(SCAN_DATE) FROM `fetch-exercise-437700.fetch.transaction` -- Transaction period:　06/12/2024 to 09/08/2024
SELECT COUNT(DISTINCT ID) FROM `fetch-exercise-437700.fetch.user` 
WHERE ID in (SELECT USER_ID FROM `fetch-exercise-437700.fetch.transaction`)  -- only 91 users from the transaction table have a user profile

-- Investigate transaction table structure, especially records with multiple duplicates
SELECT RECEIPT_ID, COUNT(*) FROM `fetch-exercise-437700.fetch.transaction` 
GROUP BY 1 ORDER BY 2 DESC;
SELECT * FROM `fetch-exercise-437700.fetch.transaction` WHERE RECEIPT_ID = 'bedac253-2256-461b-96af-267748e6cecf'; -- Barcodes are also duplicated. Receipt ID + Barcode pairs should be unique

-- "Zeor" in quantity
SELECT * FROM `fetch-exercise-437700.fetch.transaction`
WHERE FINAL_QUANTITY = 'zero'
AND concat(RECEIPT_ID, BARCODE) not in (SELECT concat(RECEIPT_ID, BARCODE) FROM `fetch-exercise-437700.fetch.transaction` 
                                        WHERE FINAL_QUANTITY != 'zero'); -- No data, indicating all receipt ID and barcode pairs with 'zero' quantity are duplicated. It's safe to drop these invalid entries. 

-- Cleaned transaction table: drop duplicates, keep numeric values for quantity and sales
SELECT RECEIPT_ID, PURCHASE_DATE, SCAN_DATE, STORE_NAME, USER_ID, BARCODE 
,CAST(CAST(MAX(FINAL_QUANTITY) as FLOAT64) as INT64) as FINAL_QUANTITY 
,CAST(MAX(FINAL_SALE) as FLOAT64) as FINAL_SALE
FROM `fetch-exercise-437700.fetch.transaction`
WHERE FINAL_QUANTITY != 'zero'
GROUP BY 1,2,3,4,5,6;

-- User age analysis
SELECT COUNT(DISTINCT ID)
FROM `fetch-exercise-437700.fetch.user`
WHERE DATE_DIFF(CURRENT_DATE(), DATE(BIRTH_DATE), YEAR) >= 21; -- 89663 >= 21 years old (90%)

-- User birthday 
SELECT BIRTH_DATE, count(ID), count(distinct ID)
FROM `fetch-exercise-437700.fetch.user`
GROUP BY 1 ORDER BY 2 DESC;  -- 3,675 null, 1,272 "1970-01-01"

-- User age distribution
WITH u as (SELECT *
  ,DATE_DIFF(CURRENT_DATE(), DATE(BIRTH_DATE), YEAR) AS age
  ,CONCAT(FLOOR(DATE_DIFF(CURRENT_DATE(), DATE(BIRTH_DATE), YEAR) / 10) * 10, '-', 
         (FLOOR(DATE_DIFF(CURRENT_DATE(), DATE(BIRTH_DATE), YEAR) / 10) * 10) + 9) AS age_bucket
  ,FLOOR(DATE_DIFF(CURRENT_DATE(), DATE(BIRTH_DATE), YEAR) / 10) * 10 as age_order
  FROM `fetch-exercise-437700.fetch.user`
)

SELECT age_bucket
,COUNT(DISTINCT ID) as member
,COUNT(DISTINCT ID) *100 / SUM(COUNT(DISTINCT ID)) OVER () as percentage
FROM u GROUP BY 1, age_order ORDER BY age_order;

-- Create a merged transaction table with product and user information
CREATE OR REPLACE TABLE `fetch-exercise-437700.fetch.master` AS 
WITH t as (
  SELECT RECEIPT_ID, PURCHASE_DATE, SCAN_DATE, STORE_NAME, USER_ID, BARCODE 
  ,CAST(CAST(MAX(FINAL_QUANTITY) as FLOAT64) as INT64) as FINAL_QUANTITY 
  ,CAST(MAX(FINAL_SALE) as FLOAT64) as FINAL_SALE
  FROM `fetch-exercise-437700.fetch.transaction`
  WHERE FINAL_QUANTITY != 'zero'
  GROUP BY 1,2,3,4,5,6
  )

,u AS (
  SELECT *
  ,DATE_DIFF(CURRENT_DATE(), DATE(BIRTH_DATE), YEAR) AS age
  FROM `fetch-exercise-437700.fetch.user`
)

,p AS (
  SELECT * FROM `fetch-exercise-437700.fetch.product` where BARCODE is not null 
)

SELECT t.*, u.* EXCEPT(ID), p.* EXCEPT(BARCODE) FROM t 
LEFT JOIN u on t.USER_ID = u.ID
LEFT JOIN p USING(BARCODE);

-- Number of purchases (receipts scanned) with user age >=21
SELECT  
BRAND, MANUFACTURER
,COUNT(DISTINCT RECEIPT_ID) as purchases -- receipts scanned
FROM `fetch-exercise-437700.fetch.master`
-- WHERE age >= 21 -- skip this as most users are at least 21
GROUP BY 1,2
ORDER BY 3 desc;

-- What are the top 5 brands by sales among users that have had their account for at least six months?
SELECT  
BRAND
,COUNT(DISTINCT RECEIPT_ID) as purchases -- receipts scanned
,SUM(FINAL_SALE) as sales  -- sales
FROM `fetch-exercise-437700.fetch.master`
WHERE DATE(CREATED_DATE) <= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH) 
GROUP BY 1
ORDER BY 3 desc;

-- What is the percentage of sales in the Health & Wellness category by generation?
WITH gen AS (
  SELECT *
  ,CASE WHEN age < 12 then 'Gen Alpha'
  WHEN age between 12 and 27 then 'Gen Z'
  WHEN age between 28 and 43 then 'Millennials'
  WHEN age between 44 and 59 then 'Gen X'
  WHEN age >= 60 then 'Baby Boomers'
  ELSE 'unknown' END as generation
  FROM `fetch-exercise-437700.fetch.master`
)

,total_sales AS (
  SELECT generation
  ,CAST(SUM(FINAL_SALE) as FLOAT64) as total_sales
  FROM gen
  GROUP BY 1
)

,wellness AS (
  SELECT generation
  ,SUM(FINAL_SALE) as wellness_sales
  FROM gen
  WHERE CATEGORY_1 = 'Health & Wellness'
  GROUP BY 1
)

SELECT a.generation
,b.wellness_sales
,a.total_sales
,ifnull(b.wellness_sales,0)*100/a.total_sales as wellness_sales_percentage
FROM total_sales a
LEFT JOIN wellness b USING(generation);

-- Who are Fetch’s power users?
SELECT USER_ID, age, STATE, GENDER
,COUNT(DISTINCT RECEIPT_ID) as receipts_scanned
,SUM(FINAL_SALE) as sales
FROM `fetch-exercise-437700.fetch.master`
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Which is the leading brand in the Dips & Salsa category?
SELECT  
BRAND
,COUNT(DISTINCT RECEIPT_ID) as receipts_scanned -- receipts scanned/purchases
,SUM(FINAL_SALE) as sales  -- sales
FROM `fetch-exercise-437700.fetch.master`
where CATEGORY_2 = 'Dips & Salsa'
GROUP BY 1
ORDER BY 3 desc

-- At what percent has Fetch grown year over year?
-- (user only, assuming all users stay active)
WITH stg AS (
  SELECT EXTRACT(YEAR FROM CREATED_DATE) as createad_year
  ,COUNT(distinct ID) as user_cnt
  FROM `fetch-exercise-437700.fetch.user`
  GROUP BY 1
)

-- (growth of the total user base)
,stg2 AS (
  SELECT *
  ,SUM(user_cnt) OVER(ORDER BY createad_year) as cumulative_users
  FROM stg
)
-- (Total users YoY growth)
SELECT *
,ROUND((cumulative_users - LAG(cumulative_users) OVER(ORDER BY createad_year)) * 100 / LAG(cumulative_users) OVER(ORDER BY createad_year),2) as growth_rate
FROM stg2
ORDER BY 1;
