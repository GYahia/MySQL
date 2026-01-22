-- Active: 1736824156068@@localhost@3306@311_service_requests
-- Data downloaded from Calgary website for the date of 10 Feb 2025
-- Source: https://data.calgary.ca/Services-and-Amenities/311-Service-Requests/iahh-g8bj/about_data
-- Use the newly created database
USE 311_service_requests;

SHOW COLUMNS FROM service_requests_clean_v3;
----------------------------------------------------------------------------------
-- DATA  EXPLORATION
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Temporal Analysis
----------------------------------------------------------------------------------
-- How has the volume of service requests changed over time (monthly, seasonally, or annually)?
SELECT
    YEAR(requested_date) AS year_requested,
    COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY
    year_requested
ORDER BY year_requested ASC;
-- the years 2010 and 2011 have 31 and 74 entries >> irrelevant compared to the total and will change the averages
-- Also the year 2026 since it has been taken into consideration until January 16th has minimal entries
-- I will exclude them from the analysis
DELETE FROM service_requests_clean_v3
WHERE
    YEAR(requested_date) IN (2010, 2011, 2026);

-- New number of rows after deletion
SELECT COUNT(*) FROM service_requests_clean_v3;
-- 6672894
SELECT COUNT(service_request_id) / COUNT(DISTINCT YEAR(requested_date)) AS avg_requests_per_year
FROM service_requests_clean_v3;
-- 476635 requests per year on average

-- Calculate the total number of requests per month
SELECT
    MONTHNAME(requested_date) AS month_request,
    COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY
    month_request
ORDER BY request_count DESC;
-- June (over 730k) has the most requests, May to August are the busiest months (all 3 over 600k)

-- Calculate the average number of requests per month
SELECT
    MONTHNAME(requested_date) AS month_request,
    COUNT(*) / COUNT(DISTINCT YEAR(requested_date)) AS avg_request_count
FROM service_requests_clean_v3
GROUP BY
    month_request
ORDER BY avg_request_count DESC;
-- June has the most requests , May to August are the busiest months

-- Calculate the total number of requests per day of the week
SELECT
    DAYNAME(requested_date) AS day_requested,
    COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY
    day_requested
ORDER BY request_count DESC;
-- Tuesday to Thursday are the busiest days, The weekend has the least requests
/*
Tuesday	1244017
Wednesday	1215784
Thursday	1182361
Monday	       1136544
Friday	       1040804
Saturday	454374
Sunday	       399010
*/

-- Calculate the average number of requests per day of the week per year
SELECT
    DAYNAME(requested_date) AS day_requested,
    COUNT(*) / COUNT(DISTINCT YEAR(requested_date)) AS avg_request_count
FROM service_requests_clean_v3
GROUP BY
    day_requested
ORDER BY avg_request_count DESC;

-- Add a column for season
ALTER TABLE service_requests_clean_v3 ADD COLUMN season VARCHAR(10);
-- Update the season column based on the requested_date
UPDATE service_requests_clean_v3
SET
    season = CASE
        WHEN MONTH(requested_date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(requested_date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(requested_date) IN (6, 7, 8) THEN 'Summer'
        WHEN MONTH(requested_date) IN (9, 10, 11) THEN 'Fall'
    END;


-- Calculate the total number of requests per season and its percentage
SELECT DISTINCT
    season,
    COUNT(*) AS request_count,
    ROUND(
        COUNT(*) * 100 / (
            SELECT COUNT(*)
            FROM service_requests_clean_v3
        )
    ) AS percentage
FROM service_requests_clean_v3
GROUP BY
    season
ORDER BY request_count DESC;
-- Summer 30%, Spring 25%, Fall 24%, Winter 21%


-- Calculate the total number of requests per year
SELECT
    YEAR(requested_date) AS year_requested,
    COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY
    year_requested
ORDER BY request_count DESC;
-- 2014,2023 and 2018 are the years with over 1/2 a million requests


-- Calculate total number of requests per year and show which year has more requests than average
SELECT
    Year(requested_date) AS year_requested,
    COUNT(*) AS request_count,
    AVG(COUNT(*)) OVER () AS avg_requests,
    CASE
        WHEN COUNT(*) > AVG(COUNT(*)) OVER () THEN 'Above Average'
        ELSE 'Below Average'
    END AS request_count_status
FROM service_requests_clean_v3
GROUP BY
    year_requested
ORDER BY request_count;
-- from 2013 to 2026, only 5 years were above average 2017,2020,2018,2023,2014 ASC
----------------------------------------------------------------------------------
-- For this next part I am commenting out different ways to trying to retrieve the data used
-- for the analysis to see which one is the most efficient
-- I will leave the index and the queries using CTE since they are the ones with the best performance at this point
----------------------------------------------------------------------------------
-- Optimized query using the new index
/*SELECT season, service_name, request_count
FROM (
SELECT season, service_name, COUNT(*) AS request_count,
ROW_NUMBER() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS row_num
FROM service_requests_clean_v3
GROUP BY season, service_name
) AS ranked_requests
WHERE row_num IN (1,2,3)
ORDER BY season; -- before index 1m33 , after index 1m25
*/
-- Optimized CTE query using the new index
WITH
    ranked_requests AS (
        SELECT
            season,
            service_name,
            COUNT(*) AS request_count
        FROM service_requests_clean_v3
        GROUP BY
            season,
            service_name
    ),
    top_requests AS (
        SELECT
            season,
            service_name,
            request_count,
            ROW_NUMBER() OVER (
                PARTITION BY
                    season
                ORDER BY request_count DESC
            ) AS row_num
        FROM ranked_requests
    )
SELECT
    season,
    service_name,
    request_count
FROM top_requests
WHERE
    row_num IN (1, 2, 3)
ORDER BY season;
-- Fall: Cart management, Spring: Cart Management, SummerFinance property tax, Winter: Roads and Bylaw snow and ice
ALTER TABLE service_requests_clean_v3
ADD COLUMN month_requested VARCHAR(20);

UPDATE service_requests_clean_v3
SET
    month_requested = MONTHNAME(requested_date);

-- Average response time between submission and closure
ALTER TABLE service_requests_clean_v3
ADD COLUMN response_time_days DOUBLE;

UPDATE service_requests_clean_v3
SET
    response_time_days = DATEDIFF(closed_date, requested_date);


SELECT AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3;
-- over 19 days
SELECT
    service_request_id,
    requested_date,
    closed_date,
    response_time_days
FROM service_requests_clean_v3
WHERE
    response_time_days < 0;
-- 0 values

-- Average response time by request type


SELECT
    service_name,
    MIN(response_time_days) AS min_response_time_days,
    AVG(response_time_days) AS avg_response_time_days,
    MAX(response_time_days) AS max_response_time_days
FROM service_requests_clean_v3
GROUP BY
    service_name
ORDER BY avg_response_time_days DESC
LIMIT 10;
-- FAC inspection , Master Indem const, Major Transit Projects, Rapid damage assessment, Traffic and Roadmarking: all over 500 days avg response time
SELECT
    month_requested,
    service_name,
    AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3
GROUP BY
    month_requested,
    service_name
ORDER BY avg_response_time_days DESC;
-- On average, Streetlight in Downtown during February, Traffic Cam Inquiry in July and Lane Reversal in August are services
-- with response times over 2000 days
SELECT
    month_requested,
    AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3
GROUP BY
    month_requested
ORDER BY avg_response_time_days DESC;
-- Sept, May and Apr have responsise times  over 21 days