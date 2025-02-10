-- Create a new database called world_layoffs
DROP DATABASE IF EXISTS world_layoffs;
SHOW DATABASES;

-- Create the world_layoffs database
CREATE DATABASE world_layoffs;
-- Show all databases
SHOW DATABASES;

-- Use the newly created database
USE world_layoffs;

--------------------------------------------------------
-- DATA was imported from CSV file using MySQL Workbench
--------------------------------------------------------
SELECT *
FROM layoffs
LIMIT 10;

/*RENAME TABLE world_layoffs TO  layoffs;*/
SHOW COLUMNS
FROM layoffs;
--------------------------------------------------------
-- DATA CLEANING
--------------------------------------------------------

-- CREATE A COPY OF THE RAW DATA TABLE TO WORK ON
CREATE TABLE layoffs_clean LIKE layoffs;
INSERT INTO layoffs_clean
SELECT *
FROM layoffs;
SELECT *
FROM layoffs_clean
LIMIT 100;

-- Remove duplicates
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY company,industry, total_laid_off, percentage_laid_off,`date`) AS row_num
FROM layoffs_clean;

-- SELECTING ONLY THE VALUES WITH DUPLICATES
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
    FROM layoffs_clean
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- DELETING DUPLICATES
DROP TABLE IF EXISTS layoffs_clean_v2;
CREATE TABLE layoffs_clean_v2 LIKE layoffs_clean;
ALTER TABLE layoffs_clean_v2
ADD COLUMN row_num INT;
SHOW COLUMNS
FROM layoffs_clean_v2;
INSERT INTO layoffs_clean_v2
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company,
        industry,
        total_laid_off,
        percentage_laid_off,
        `date`,
        stage,
        country,
        funds_raised_millions
    ) AS row_num
FROM layoffs_clean;
SELECT *
FROM layoffs_clean_v2
LIMIT 100;
SELECT *
FROM layoffs_clean_v2
WHERE row_num > 1;
DELETE FROM layoffs_clean_v2
WHERE row_num > 1;


-- Standardize Data
UPDATE layoffs_clean_v2
SET company = TRIM(company);
SELECT DISTINCT industry
FROM layoffs_clean_v2
ORDER BY industry;

-- Crypto, CryptoCurrency and Crypto Curency can be the same industry

UPDATE layoffs_clean_v2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT *
FROM layoffs_clean_v2
WHERE industry = 'Retail'
    OR industry = 'Sales';
/*SELECT  industry, COUNT(industry)
 FROM layoffs_clean_v2
 GROUP BY industry
 ORDER BY COUNT(industry) DESC;*/

UPDATE layoffs_clean_v2
SET COUNTRY = 'United States'
WHERE COUNTRY LIKE 'United States%';


-- FORMAT DATE
SELECT `date`,
    STR_TO_DATE(`date`, '%m/%d/%Y') AS formatted_date
FROM layoffs_clean_v2;
UPDATE layoffs_clean_v2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
SELECT *
FROM layoffs_clean_v2
LIMIT 10;
ALTER TABLE layoffs_clean_v2
MODIFY COLUMN `date` DATE;

-- NULL and Blank Values

SELECT *
FROM layoffs_clean_v2
WHERE industry IS NULL
    OR industry = '';
SELECT *
FROM layoffs_clean_v2
WHERE company = 'Airbnb';
-- >> Industry is Travel

-- UPDATE NULL VALUES
SELECT *
FROM layoffs_clean_v2 AS t1
    JOIN layoffs_clean_v2 AS t2 ON t1.company = t2.company
WHERE (
        t1.industry IS NULL
        OR t1.industry = ''
    )
    AND t2.industry IS NOT NULL;
UPDATE layoffs_clean_v2 AS t1
    JOIN layoffs_clean_v2 AS t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (
        t1.industry IS NULL
        OR t1.industry = ''
    )
    AND t2.industry IS NOT NULL;
-- >> DID NOT CHANGETHE TABLE


UPDATE layoffs_clean_v2
SET industry = NULL
WHERE industry = '';
-- >> CHANGED BLANKS TO NULLS FIRST


-- UPDATE NULL VALUES
UPDATE layoffs_clean_v2 AS t1
    JOIN layoffs_clean_v2 AS t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
    AND t2.industry IS NOT NULL;
-- >>
SELECT *
FROM layoffs_clean_v2
WHERE country IS NULL
    OR country = '';


-- Remove Unnecessary Columns or Rows
DELETE FROM layoffs_clean_v2
WHERE total_laid_off IS NULL
    AND percentage_laid_off IS NULL;
SELECT *
FROM layoffs_clean_v2;
ALTER TABLE layoffs_clean_v2 DROP COLUMN row_num;
-----------------------------------------------
-- DATA EXPLORING

-----------------------------------------------

SELECT MAX(total_laid_off) AS max_laid_off,
    MIN(total_laid_off) AS min_laid_off,
    AVG(total_laid_off) AS avg_laid_off,
    SUM(total_laid_off) AS total_laid_off,
    MAX(percentage_laid_off) AS max_percentage
FROM layoffs_clean_v2;

SELECT company,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY company
ORDER BY total_laid_off DESC;

SELECT MIN(`date`) AS min_date,
    MAX(`date`) AS max_date
FROM layoffs_clean_v2;

SELECT industry,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY industry
ORDER BY total_laid_off DESC;

SELECT country,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY country
ORDER BY total_laid_off DESC;

-- This query calculates the total number of layoffs per year and sorts the results in descending order.
SELECT YEAR(`date`),
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;


-- This query calculates the total number of layoffs per month and sorts the results in descending order.
WITH Rolling_Total AS (
  SELECT 
    SUBSTRING(date, 1, 7) AS `month`,
    SUM(total_laid_off) AS monthly_total
  FROM layoffs_clean_v2
  GROUP BY `month`
)
SELECT 
  `month`,
  monthly_total,
  SUM(monthly_total) OVER (ORDER BY `month`) AS cumulative_total
FROM Rolling_Total;


-- This query calculates the total number of layoffs per stage and sorts the results in descending order.
SELECT stage,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- This query calculates the total number of layoffs per industry and sorts the results in descending order.
WITH Rolling_Total AS (
    SELECT country,
        SUBSTRING(`date`, 1, 7) AS `Year Month`,
        SUM(total_laid_off) AS total
    FROM layoffs_clean_v2
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY country,
        `Year Month`
    ORDER BY `Year Month` ASC
)
SELECT country,
    `Year Month`,
    total,
    SUM(total) OVER (
        ORDER BY `Year Month`
    ) AS cumulative_total
FROM Rolling_Total;





-- This Common Table Expression (CTE) named Company_Year calculates the total number of layoffs per company per year.
WITH Company_Year (
    company,
    years,
    total_laid_off
) AS (
    SELECT company,
        YEAR(`date`) AS years,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_clean_v2
    GROUP BY company,
        years
),

-- This CTE named Company_Yar_Rank ranks the companies by the total number of layoffs per year in descending order.
Company_Yar_Rank AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY years
            ORDER BY total_laid_off DESC
        ) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)

-- The final query selects all columns from the Company_Yar_Rank CTE where the ranking is less than or equal to 5,
-- effectively retrieving the top 5 companies with the highest number of layoffs per year.
SELECT *
FROM Company_Yar_Rank
WHERE Ranking <= 5;