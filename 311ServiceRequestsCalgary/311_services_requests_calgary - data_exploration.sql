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
SELECT YEAR(requested_date) AS year_requested,
       COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY year_requested
ORDER BY year_requested ASC;
-- the years 2010 and 2011 have 31 and 74 entries >> irrelevant compared to the total and will change the averages
-- Also the year 205 since it has been taken into consideration until February 10 has minimal entries
-- I will exclude them from the analysis
DELETE FROM service_requests_clean_v3
WHERE YEAR(requested_date) IN (2010, 2011, 2025);
-- New number of rows after deletion
SELECT COUNT(*)
FROM service_requests_clean_v3;
-- 6222565


SELECT COUNT(service_request_id) / COUNT(DISTINCT YEAR(requested_date)) AS avg_requests_per_year
FROM service_requests_clean_v3;
-- 478659

-- Calculate the total number of requests per month
SELECT MONTHNAME(requested_date) AS month_request,
       COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY month_request
ORDER BY request_count DESC;
-- June has the most requests, May to August are the busiest months


-- Calculate the average number of requests per month
SELECT MONTHNAME(requested_date) AS month_request,
       COUNT(*) / COUNT(DISTINCT YEAR(requested_date)) AS avg_request_count
FROM service_requests_clean_v3
GROUP BY month_request
ORDER BY avg_request_count DESC;
-- June has the most requests, May to August are the busiest months


-- Calculate the total number of requests per day
SELECT DAYNAME(requested_date) AS day_requested,
       COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY day_requested
ORDER BY request_count DESC;
-- Tuesday to Thursday are the busiest days, The weekend has the least requests


-- Calculate the average number of requests per day
SELECT DAYNAME(requested_date) AS day_requested,
       COUNT(*) / COUNT(DISTINCT YEAR(requested_date)) AS avg_request_count
FROM service_requests_clean_v3
GROUP BY day_requested
ORDER BY avg_request_count DESC;
-- Monday has the most requests
-- MIDWEEK IS WHEN THERE IS THE MOST REQUEST TUESDAY TO THURSDAY


-- Add a column for season
ALTER TABLE service_requests_clean_v3
ADD COLUMN season VARCHAR
(10);


-- Update the season column based on the requested_date
UPDATE service_requests_clean_v3
SET season = CASE
              WHEN MONTH(requested_date) IN (12, 1, 2) THEN 'Winter'
              WHEN MONTH(requested_date) IN (3, 4, 5) THEN 'Spring'
              WHEN MONTH(requested_date) IN (6, 7, 8) THEN 'Summer'
              WHEN MONTH(requested_date) IN (9, 10, 11) THEN 'Fall'
       END;


-- Calculate the total number of requests per season
SELECT DISTINCT season,
       COUNT(*) AS request_count,
       ROUND(COUNT(*) * 100 / 6263611) AS percentage
FROM service_requests_clean_v3
GROUP BY season
ORDER BY request_count DESC;
-- 25.3% Spring, 29.4% Summer, 23.5% Fall, 21.9% Winter


-- Calculate the average number of requests per season
SELECT season,
       COUNT(*) / COUNT(DISTINCT YEAR(requested_date)) AS avg_request_count
FROM service_requests_clean_v3
GROUP BY season
ORDER BY avg_request_count DESC;
-- Summer has the most requests, Spring to Fall are the busiest seasons


-- Calculate the total number of requests per year
SELECT YEAR(requested_date) AS year_requested,
       COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY year_requested
ORDER BY request_count DESC;
-- 2014,2023 and 2018 are the years with over 1/2 a million requests


-- Calculate total number of requests per year and show which year has more requests than average
SELECT Year(requested_date) AS year_requested,
       COUNT(*) AS request_count,
       AVG(COUNT(*)) OVER () AS avg_requests,
       CASE
              WHEN COUNT(*) > AVG(COUNT(*)) OVER () THEN 'Above Average'
              ELSE 'Below Average'
       END AS request_count_status
FROM service_requests_clean_v3
GROUP BY year_requested
ORDER BY request_count;
-- from 2013 to 2024, only 5 years were above average 2017,2020,2018,2023,2014 ASC


----------------------------------------------------------------------------------
-- For this next part I am commenting out different ways to trying to retrieve the data used
-- for the analysis to see which one is the most efficient
-- I will leave the index and the queries using CTE since they are the ones with the best performance at this point
----------------------------------------------------------------------------------
CREATE INDEX idx_season_service_name ON service_requests_clean_v3 (season, service_name);
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
       ranked_requests
       AS
       (
              SELECT season,
                     service_name,
                     COUNT(*) AS request_count
              FROM service_requests_clean_v3
              GROUP BY season,
              service_name
       ),
       top_requests
       AS
       (
              SELECT season,
                     service_name,
                     request_count,
                     ROW_NUMBER() OVER (
                     PARTITION BY season
                     ORDER BY request_count DESC
              ) AS row_num
              FROM ranked_requests
       )
SELECT season,
       service_name,
       request_count
FROM top_requests
WHERE row_num IN (1, 2, 3)
ORDER BY season;
-- before index 1m24 , after index 14s
-- Fall: Cart management, Spring: Cart Management, SummerFinance property tax, Winter: Roads and Bylaw snow and ice

DROP INDEX idx_season_service_name ON service_requests_clean_v3;
ALTER TABLE service_requests_clean_v3
ADD COLUMN month_requested VARCHAR
(20);
UPDATE service_requests_clean_v3
SET month_requested = MONTHNAME(requested_date);


-- Average response time between submission and closure
ALTER TABLE service_requests_clean_v3
ADD COLUMN response_time_days DOUBLE;
UPDATE service_requests_clean_v3
SET response_time_days = DATEDIFF(closed_date, requested_date);
SELECT AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3;
-- 18 days
SELECT service_request_id,
       requested_date,
       closed_date,
       response_time_days
FROM service_requests_clean_v3
WHERE response_time_days < 0;
-- 0 values


-- Average response time by request type
CREATE INDEX idx_service_name_response_time_days ON service_requests_clean_v3 (service_name, response_time_days);
SELECT service_name,
       MIN(response_time_days) AS min_response_time_days,
       AVG(response_time_days) AS avg_response_time_days,
       MAX(response_time_days) AS max_response_time_days
FROM service_requests_clean_v3
GROUP BY service_name
ORDER BY avg_response_time_days DESC
LIMIT 10;
-- FAC inspection , Master Indem const, Major Transit Projects, Rapid damage assessment: all over 500 days avg response time


SELECT month_requested
,
       service_name,
       AVG
(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3
GROUP BY month_requested,
       service_name
ORDER BY avg_response_time_days DESC;
-- Not sure what this data means

SELECT month_requested,
       AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3
GROUP BY month_requested
ORDER BY avg_response_time_days DESC;
-- Sept, May and Apr have responsise times  over 20 days
DROP INDEX idx_service_name_response_time_days ON service_requests_clean_v3;



----------------------------------------------------------------------------------
-- Service Requests Trends
----------------------------------------------------------------------------------

SELECT *
FROM service_requests_clean_v3
LIMIT
5;


-- Most common service types
SELECT service_name,
       COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY service_name
ORDER BY request_count DESC
LIMIT 10;
-- Cart management, propert tax account inq, TIPP agreement request, CBS inspection - electrical: over 150K requests


-- Percentage of unresolved requests (>30 days)
SELECT COUNT (*) AS total_requests,
       SUM (
              CASE
                     WHEN response_time_days > 30 THEN 1
                     ELSE 0
              END
       ) AS unresolved_requests,
       ROUND (
              SUM (
                     CASE
                            WHEN response_time_days > 30 THEN 1
                            ELSE 0
                     END
              ) * 100 / COUNT (*)
       ) AS unresolved_percentage
FROM service_requests_clean_v3
ORDER BY unresolved_percentage;
-- 8%


-- Percentage of requests by status
SELECT status_description,
       COUNT(*) AS request_count,
       ROUND(COUNT(*) * 100 / 6263611) AS percentage
FROM service_requests_clean_v3
GROUP BY status_description
ORDER BY request_count DESC;
-- Closed 97%, duplicate closed 2% and 1% open


-- Average handling time of Open requests
SELECT AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3
WHERE status_description = 'Open';
-- on average open for 97 days+


-- Recurring requests at the same location
-- needs a self join
ALTER TABLE service_requests_clean_v3 ENGINE = InnoDB;
OPTIMIZE TABLE service_requests_clean_v3;
-- Show indexes on the table
SHOW INDEX FROM service_requests_clean_v3;


SELECT *
FROM service_requests_clean_v3
LIMIT
5;


CREATE INDEX idx_service_name_point_date ON service_requests_clean_v3 (service_name, point, requested_date);
CREATE INDEX idx_service_name_point_latitude_longitude ON service_requests_clean_v3(service_name, point, latitude, longitude);



SELECT COUNT(point)
FROM service_requests_clean_v3
WHERE point IS  NULL OR point='';

-- 62 entries with null points

DELETE FROM service_requests_clean_v3
WHERE point IS NULL OR point='';



-- count the number of occurence for the same point and service name

SELECT sr1.service_name,
           sr1.point,
           sr1.comm_name,
           YEAR(sr1.requested_date) AS year_requested,
           COUNT(DISTINCT sr2.service_request_id) AS recurrence_count  -- Count unique occurrences
    FROM (SELECT * FROM service_requests_clean_v3 LIMIT 100000)sr1
    JOIN (SELECT * FROM service_requests_clean_v3 LIMIT 100000) sr2
        ON sr1.point = sr2.point
        AND sr1.service_name = sr2.service_name
        AND sr2.requested_date > sr1.requested_date
        AND sr2.requested_date <= DATE_ADD(sr1.requested_date, INTERVAL 365 DAY)
        AND ABS(sr1.longitude - sr2.longitude) < 0.0001
        AND ABS(sr1.latitude - sr2.latitude) < 0.0001
    WHERE sr1.service_request_id != sr2.service_request_id
    GROUP BY sr1.service_name, sr1.point, sr1.comm_name, YEAR(sr1.requested_date);

-- LImiting the query to 100K rows to see the performance

/* The above query identifies the number of requests for the same service name and point within a year
   The query below will identify the most common service requests for the same point within a year
   The query will be used to identify the most common service requests for the same community within a year
   The query will be used to identify the most common service requests for the same community and service name within a year
*/


-- Number of reoccurrences per year

WITH ServiceRequestCounts1 AS (
    SELECT sr1.service_name,
           sr1.point,
           sr1.comm_name,
           YEAR(sr1.requested_date) AS year_requested,
           COUNT(DISTINCT sr2.service_request_id) AS recurrence_count  -- Count unique occurrences
    FROM service_requests_clean_v3 sr1
    LEFT JOIN service_requests_clean_v3 sr2
        ON sr1.point = sr2.point
        AND sr1.service_name = sr2.service_name
        AND sr2.requested_date > sr1.requested_date
        AND sr2.requested_date <= DATE_ADD(sr1.requested_date, INTERVAL 365 DAY)
        AND ABS(sr1.longitude - sr2.longitude) < 0.0001
        AND ABS(sr1.latitude - sr2.latitude) < 0.0001
    WHERE sr1.service_request_id != sr2.service_request_id
    GROUP BY sr1.service_name, sr1.point, sr1.comm_name, YEAR(sr1.requested_date)
)
SELECT year_requested, COUNT(*) AS occurrences
FROM ServiceRequestCounts1
GROUP BY year_requested
ORDER BY year_requested ASC
;

-- 2h23 minutes to run the query
-- 2023 has the most reoccurrences ad also 2019 has more than an average
-- trend is increasing
-- the year 2023 neads more investigation


-- Number of reoccurrences per service_name
WITH ServiceRequestCounts1 AS (
    SELECT sr1.service_name,
           sr1.point,
           sr1.comm_name,
           YEAR(sr1.requested_date) AS year_requested,
           COUNT(DISTINCT sr2.service_request_id) AS recurrence_count  -- Count unique occurrences
    FROM service_requests_clean_v3 sr1
    LEFT JOIN service_requests_clean_v3 sr2
        ON sr1.point = sr2.point
        AND sr1.service_name = sr2.service_name
        AND sr2.requested_date > sr1.requested_date
        AND sr2.requested_date <= DATE_ADD(sr1.requested_date, INTERVAL 365 DAY)
        AND ABS(sr1.longitude - sr2.longitude) < 0.0001
        AND ABS(sr1.latitude - sr2.latitude) < 0.0001
    WHERE sr1.service_request_id != sr2.service_request_id
    GROUP BY sr1.service_name, sr1.point, sr1.comm_name, YEAR(sr1.requested_date)
)
SELECT service_name, COUNT(*) AS occurrences
FROM ServiceRequestCounts1
GROUP BY service_name
ORDER BY occurrences DESC
LIMIT 5;

-- top 3 over 4000 reoccurrences: Snow and ice control, Traffic and roadmarking, roadway maintenance





----------------------------------------------------------------------------------
-- Geographical Analysis
----------------------------------------------------------------------------------

-- Number of reoccurrences per comm_name
WITH ServiceRequestCounts2 AS (
       SELECT sr1.service_name,
              sr1.point,
              sr1.comm_name,
              YEAR(sr1.requested_date) AS year_requested,
              COUNT(DISTINCT sr2.service_request_id) AS recurrence_count -- Count unique occurrences
       FROM service_requests_clean_v3 sr1
              LEFT JOIN service_requests_clean_v3 sr2 ON sr1.point = sr2.point
              AND sr1.service_name = sr2.service_name
              AND sr2.requested_date > sr1.requested_date
              AND sr2.requested_date <= DATE_ADD(sr1.requested_date, INTERVAL 365 DAY)
              AND ABS(sr1.longitude - sr2.longitude) < 0.0001
              AND ABS(sr1.latitude - sr2.latitude) < 0.0001
       WHERE sr1.service_request_id != sr2.service_request_id
       GROUP BY sr1.service_name,
              sr1.point,
              sr1.comm_name,
              YEAR(sr1.requested_date)
)
SELECT comm_name,
       COUNT(*) AS occurrences
FROM ServiceRequestCounts2
GROUP BY comm_name
ORDER BY occurrences DESC
LIMIT 5;

/*
DOWNTOWN COMMERCIAL CORE	3925
BELTLINE	3826
BOWNESS	3222
CRESCENT HEIGHTS	3081
BRIDGELAND/RIVERSIDE	3037
*/

-- Number of reoccurrences per service_name and comm_name
WITH ServiceRequestCounts3 AS (
       SELECT sr1.service_name,
              sr1.point,
              sr1.comm_name,
              YEAR(sr1.requested_date) AS year_requested,
              COUNT(DISTINCT sr2.service_request_id) AS recurrence_count -- Count unique occurrences
       FROM service_requests_clean_v3 sr1
              LEFT JOIN service_requests_clean_v3 sr2 ON sr1.point = sr2.point
              AND sr1.service_name = sr2.service_name
              AND sr2.requested_date > sr1.requested_date
              AND sr2.requested_date <= DATE_ADD(sr1.requested_date, INTERVAL 365 DAY)
       WHERE sr1.service_request_id != sr2.service_request_id
       GROUP BY sr1.service_name,
              sr1.point,
              sr1.comm_name,
              YEAR(sr1.requested_date)
)
SELECT service_name,
       comm_name,
       COUNT(*) AS occurrences
FROM ServiceRequestCounts3
GROUP BY service_name,
       comm_name
ORDER BY occurrences DESC
LIMIT 5;

/*
Roads - Signs - Parking	BELTLINE	38
Roads - Signs - Traffic and Roadmarking	BELTLINE	36
Roads - Signs - Traffic and Roadmarking	SILVERADO	31
Roads - Signs - Parking	LOWER MOUNT ROYAL	30
Roads - Signs - Traffic and Roadmarking	MAHOGANY	30
*/


-- Average response time by community
SELECT COUNT(DISTINCT comm_name)
FROM service_requests_clean_v3;

-- total of 272 communities

-- aVERAGE RESPONSE TIME FOR EACH COMMUNITY AFTER REDUCING TO UNIQUE REQUESTS
WITH UniqueRequests AS (
       SELECT DISTINCT requested_date,
              closed_date,
              point,
              service_name,
              comm_name,
              MIN(response_time_days) AS response_time_days
       FROM service_requests_clean_v3
       GROUP BY requested_date,
              closed_date,
              point,
              service_name,
              comm_name
)
SELECT comm_name,
       ROUND(AVG(response_time_days), 0) AS avg_response_time,
       (
              SELECT ROUND(AVG(response_time_days), 0)
              FROM UniqueRequests
       ) AS avg_overall,
       FROM UniqueRequests
GROUP BY comm_name
ORDER BY avg_response_time DESC;




----------------------------------------------------------------------------------
-- Service Efficiency Analysis
----------------------------------------------------------------------------------

-- Agencies handling most requests
SHOW COLUMNS FROM service_requests_clean_v3;
WITH AgencyRequests AS (
       SELECT agency_responsible,
              COUNT(*) AS total_requests,
              ROUND(
                     100 * COUNT(*) / (
                            SELECT COUNT(*)
                            FROM service_requests_clean_v3
                     ),
                     2
              ) AS percent_total_request,
              ROUND(
                     (
                            SELECT COUNT(*)
                            FROM service_requests_clean_v3
                     ) / COUNT(*) OVER(),
                     0
              ) AS average
       From service_requests_clean_v3
       GROUP BY agency_responsible
       ORDER BY total_requests DESC
)
SELECT *,
       CASE
              WHEN total_requests > average THEN 'Above Average'
              ELSE 'Below Average'
       END
FROM `AgencyRequests`;

/* 
CS - Calgary Community Standards	1014220	16.30	76821	Above Average
TRAN - Roads	932559	14.99	76821	Above Average
PD - Calgary Building Services	847508	13.62	76821	Above Average
CFOD - Finance	590335	9.49	76821	Above Average
UEP - Waste and Recycling Services	580333	9.33	76821	Above Average
*/


--Delays between request and update

SELECT service_name,
       response_time_days,
       DATEDIFF(updated_date,requested_date) AS delay_response
FROM service_requests_clean_v3
WHERE closed_date >= updated_date
GROUP BY service_name,response_time_days,delay_response
;


-- the way the tickets are being handled and updated does not give any information about the efficiency of the response

-- Agency efficiency

SELECT agency_responsible,
       COUNT(*) AS total_requests,
       ROUND(
              100 * COUNT(*) / (
                     SELECT COUNT(*)
                     FROM service_requests_clean_v3
              ),
              2
       ) AS percent_total_request,
       ROUND(
              (
                     SELECT COUNT(*)
                     FROM service_requests_clean_v3
              ) / COUNT(*) OVER(),
              0
       ) AS average
FROM service_requests_clean_v3
GROUP BY agency_responsible
ORDER BY total_requests DESC;

/* 3 agencies are above 10% each: CS - Calgary Community Standards, TRAN - Roads, PD - Calgary Building Services*/

-- Response time by agency

SELECT agency_responsible,
       MIN(response_time_days) AS min_response_time_days,
       AVG(response_time_days) AS avg_response_time_days,
       MAX(response_time_days) AS max_response_time_days
FROM service_requests_clean_v3
GROUP BY agency_responsible
ORDER BY avg_response_time_days DESC;

/* 3 agencies have over 100 days in avg_response_time: PD - Emergency Response, PICS - Collaboration, Analyticsand Innovation and Tran - Green Line*/