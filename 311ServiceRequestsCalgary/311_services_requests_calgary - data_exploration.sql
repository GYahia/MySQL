-- Active: 1736824156068@@localhost@3306@311_service_requests
-- Data downloaded from Calgary website for the date of 10 Feb 2025
-- Source: https://data.calgary.ca/Services-and-Amenities/311-Service-Requests/iahh-g8bj/about_data


-- Use the newly created database
USE 311_service_requests;

SHOW COLUMNS FROM service_requests_clean_v3;
----------------------------------------------------------------------------------
-- DATA  EXPLORATION
----------------------------------------------------------------------------------

-- Temporal Analysis

SELECT YEAR(requested_date) AS year_requested, COUNT(*) AS request_count 
FROM service_requests_clean_v3
GROUP BY year_requested
ORDER BY year_requested ASC;


-- the years 2010 and 2011 have 31 and 74 entries >> irrelevant compared to the total and will change the averages
-- I will exclude them from the analysis

DELETE FROM service_requests_clean_v3
WHERE YEAR(requested_date) IN (2010, 2011);

-- New number of rows 6263611

SELECT COUNT(service_request_id)/COUNT(DISTINCT YEAR(requested_date)) AS avg_requests_per_year 
FROM service_requests_clean_v3; --447400.7857 >> 447401

SELECT MONTHNAME(requested_date) AS month_requested, COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY month_requested
ORDER BY month_requested, request_count DESC;

SELECT DAYNAME(requested_date) AS day_requested, COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY day_requested
ORDER BY FIELD(day_requested, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'); 

-- MIDWEEK IS WHEN THERE IS THE MOST REQUEST TUESDAY TO THURSDAY

-- Add a column for season
ALTER TABLE service_requests_clean_v3
ADD COLUMN season VARCHAR(10);

-- Update the season column based on the requested_date
UPDATE service_requests_clean_v3
SET season = CASE
    WHEN MONTH(requested_date) IN (12, 1, 2) THEN 'Winter'
    WHEN MONTH(requested_date) IN (3, 4, 5) THEN 'Spring'
    WHEN MONTH(requested_date) IN (6, 7, 8) THEN 'Summer'
    WHEN MONTH(requested_date) IN (9, 10, 11) THEN 'Fall'
END;

-- Verify the update
SELECT DISTINCT season, COUNT(*) AS request_count, ROUND(COUNT(*)*100/6263611,1) AS percentage
FROM service_requests_clean_v3
GROUP BY season
ORDER BY request_count DESC;

-- 25.3% Spring, 29.4% Summer, 23.5% Fall, 21.9% Winter

-- Get the service type with the highest request for each season
SELECT season, service_name, request_count
FROM (
    SELECT season, service_name, COUNT(*) AS request_count,
           ROW_NUMBER() OVER (PARTITION BY season ORDER BY COUNT(*) DESC) AS row_num
    FROM service_requests_clean_v3
    GROUP BY season, service_name
) AS ranked_requests
WHERE row_num IN (1,2,3)
ORDER BY season AND request_count DESC;

-- Get the service type with the highest request for each month
SELECT month_requested, service_name, request_count
FROM (
    SELECT MONTHNAME(requested_date) AS month_requested, service_name, COUNT(*) AS request_count,
           ROW_NUMBER() OVER (PARTITION BY MONTHNAME(requested_date) ORDER BY COUNT(*) DESC) AS row_num
    FROM service_requests_clean_v3
    GROUP BY month_requested, service_name
) AS ranked_requests
WHERE row_num IN (1,2,3)
ORDER BY FIELD(month_requested, 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December') ;

-- The biggest requests seem to happen in Winter season in regards to snow whether it is for roads or bylaw


-- Average response time between submission and closure

SELECT AVG(DATEDIFF(closed_date, requested_date)) AS avg_response_time_days
FROM service_requests_clean_v3; -- 18 days

-- Average response time by request type
SELECT service_name, AVG(DATEDIFF(closed_date, requested_date)) AS avg_response_time_days
FROM service_requests_clean_v3
GROUP BY service_name
ORDER BY avg_response_time_days DESC; -- 18 days
