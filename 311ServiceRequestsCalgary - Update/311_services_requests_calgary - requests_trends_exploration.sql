-- Active: 1736824156068@@localhost@3306@311_service_requests
-- Data downloaded from Calgary website for the date of 17 Jan 2026
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

----------------------------------------------------------------------------------
-- Service Requests Trends
----------------------------------------------------------------------------------
SELECT * FROM service_requests_clean_v3 LIMIT 5;
-- Most common service types
SELECT service_name, COUNT(*) AS request_count
FROM service_requests_clean_v3
GROUP BY
    service_name
ORDER BY request_count DESC
LIMIT 10;
-- Cart management, propert tax account inq, TIPP agreement request, CBS inspection - electrical,
-- Waste residential, snow and ice sidewalk, snow and ice control: over 150K requests


-- Percentage of unresolved requests (>30 days)
SELECT
    COUNT(*) AS total_requests,
    SUM(
        CASE
            WHEN response_time_days > 30 THEN 1
            ELSE 0
        END
    ) AS unresolved_requests,
    ROUND(
        SUM(
            CASE
                WHEN response_time_days > 30 THEN 1
                ELSE 0
            END
        ) * 100 / COUNT(*)
    ) AS unresolved_percentage
FROM service_requests_clean_v3
ORDER BY unresolved_percentage;
-- 8%


-- Percentage of requests by status
SELECT
    status_description,
    COUNT(*) AS request_count,
    ROUND(
        COUNT(*) * 100 / (
            SELECT COUNT(*)
            FROM service_requests_clean_v3
        )
    ) AS percentage
FROM service_requests_clean_v3
GROUP BY
    status_description
ORDER BY request_count DESC;
-- Closed 97%, duplicate closed 2% and 1% open


-- Average handling time of Open requests
SELECT AVG(response_time_days) AS avg_response_time_days
FROM service_requests_clean_v3
WHERE
    status_description = 'Open';
-- on average open for 73 days+


-- Recurring requests at the same location
-- needs a self join



-- OPTIMIZE TABLE service_requests_clean_v3;

-- Show indexes on the table
SHOW INDEX FROM service_requests_clean_v3;

SELECT * FROM service_requests_clean_v3 LIMIT 5;



SELECT COUNT(POINT)
FROM service_requests_clean_v3
WHERE
    POINT IS NULL
    OR POINT = '';
-- 62 entries with null points
DELETE FROM service_requests_clean_v3
WHERE
    POINT IS NULL
    OR POINT = '';

SHOW INDEX FROM service_requests_clean_v3;

/*
Complex queries will start to avoid any issues with performance
will create a new table to run the analysis
*/
CREATE TABLE service_requests_v3 LIKE service_requests_clean_v3;

INSERT INTO
    service_requests_v3
SELECT *
FROM service_requests_clean_v3;

-- new total number of rows 6672832

-- count the number of occurence for the same point and service name
SELECT
    sr1.service_name,
    sr1.point,
    sr1.comm_name,
    YEAR(sr1.requested_date) AS year_requested,
    COUNT(
        DISTINCT sr2.service_request_id
    ) AS recurrence_count -- Count unique occurrences
FROM (
        SELECT *
        FROM service_requests_v3
        LIMIT 100000
    ) sr1
    JOIN (
        SELECT *
        FROM service_requests_v3
        LIMIT 100000
    ) sr2 ON sr1.point = sr2.point
    AND sr1.service_name = sr2.service_name
    AND sr2.requested_date > sr1.requested_date
    AND sr2.requested_date <= DATE_ADD(
        sr1.requested_date,
        INTERVAL 365 DAY
    )
    AND ABS(sr1.longitude - sr2.longitude) < 0.0001
    AND ABS(sr1.latitude - sr2.latitude) < 0.0001
WHERE
    sr1.service_request_id != sr2.service_request_id
GROUP BY
    sr1.service_name,
    sr1.point,
    sr1.comm_name,
    YEAR(sr1.requested_date);

-- LImiting the query to 100K rows to see the performance
/* The above query identifies the number of requests for the same service name and point within a year
The query below will identify the most common service requests for the same point within a year
The query will be used to identify the most common service requests for the same community within a year
The query will be used to identify the most common service requests for the same community and service name within a year
*/
-- Number of reoccurrences per year
 

-- Keep getting timeout errors so I will create a new table with only the necessary columns
CREATE TABLE service_requests_analysis AS
SELECT
    service_request_id,
    requested_date,
    service_name,
    comm_name,
    longitude,
    latitude,
    point
FROM service_requests_v3;

-- Still timing out

SELECT COUNT(DISTINCT service_name), COUNT(DISTINCT point) FROM service_requests_analysis;

-- point has a higher selectivity

ALTER TABLE service_requests_analysis
  ADD PRIMARY KEY (service_request_id);

CREATE INDEX idx_point_service ON service_requests_analysis (point, service_name, requested_date);

CREATE INDEX idx_requested_date ON service_requests_analysis (requested_date);

CREATE INDEX idx_sr1_year ON service_requests_analysis ((YEAR(requested_date)));

SHOW INDEX FROM service_requests_analysis;

ANALYZE TABLE service_requests_analysis;

-- Optimizing the query

-- Calculate the number of requests that were repeated within 30 days and calculate only the number of first occurences
-- How often do new issues come back quickly?

SELECT
  YEAR(sr1.requested_date) AS year_requested,
  COUNT(*) AS first_occurrences_with_30d_repeat
FROM service_requests_analysis sr1
WHERE
  -- First occurrence: no prior match in previous 30 days
  NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY
  )
  AND
  -- Has at least one repeat in next 30 days
  EXISTS (
    SELECT 1
    FROM service_requests_analysis sr2
    WHERE sr2.point = sr1.point
      AND sr2.service_name = sr1.service_name
      AND sr2.service_request_id <> sr1.service_request_id
      AND sr2.requested_date > sr1.requested_date
      AND sr2.requested_date <= sr1.requested_date + INTERVAL 30 DAY
  )
GROUP BY YEAR(sr1.requested_date)
ORDER BY year_requested;



/*
2012	35686
2013	34179
2014	33996
2015	34406
2016	38620
2017	41331
2018	40939
2019	44525
2020	47007
2021	40523
2022	41758
2023	51710
2024	44398
2025	42864
 */

-- Top 3 service names by year (by number of reoccurring first occurrences)

WITH firsts AS (
  SELECT
    sr1.service_request_id,
    sr1.service_name,
    sr1.comm_name,
    sr1.point,
    sr1.requested_date,
    YEAR(sr1.requested_date) AS year_requested
  FROM service_requests_analysis sr1
  WHERE NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY
  )
),
firsts_with_repeat AS (
  SELECT
    f.year_requested,
    f.service_name
  FROM firsts f
  WHERE EXISTS (
    SELECT 1
    FROM service_requests_analysis sr2
    WHERE sr2.point = f.point
      AND sr2.service_name = f.service_name
      AND sr2.service_request_id <> f.service_request_id
      AND sr2.requested_date > f.requested_date
      AND sr2.requested_date <= f.requested_date + INTERVAL 30 DAY
  )
),
counts AS (
  SELECT
    year_requested,
    service_name,
    COUNT(*) AS reoccurring_first_occurrences
  FROM firsts_with_repeat
  GROUP BY year_requested, service_name
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY year_requested
      ORDER BY reoccurring_first_occurrences DESC
    ) AS rn
  FROM counts
)
SELECT
  year_requested,
  service_name,
  reoccurring_first_occurrences
FROM ranked
WHERE rn <= 3
ORDER BY year_requested, reoccurring_first_occurrences DESC;

/*
 2012	CBS Inspection - Plumbing	534
2012	CBS - RIM - Property Research	533
2012	Z - Roads - Roadway Maintenance	506
2013	CBS - RIM - Property Research	471
2013	CBS Inspection - Plumbing	453
2013	Corporate - Graffiti Concerns	450
2014	CBS - RIM - Property Research	503
2014	CBS Inspection - Plumbing	487
2014	Roads - Dead Animal Pick-Up	481
2015	Roads - Roadway Maintenance	508
2015	Roads - Debris on Street/Sidewalk/Boulevard	507
2015	CBS - RIM - Property Research	496
2016	Roads - Traffic or Pedestrian Light Repair	615
2016	Roads - Roadway Maintenance	610
2016	Roads - Debris on Street/Sidewalk/Boulevard	590
2017	Roads - Traffic or Pedestrian Light Repair	709
2017	Roads - Roadway Maintenance	647
2017	Roads - Debris on Street/Sidewalk/Boulevard	588
2018	Roads - Traffic or Pedestrian Light Repair	687
2018	Roads - Roadway Maintenance	684
2018	Roads - Debris on Street/Sidewalk/Boulevard	592
2019	Roads - Traffic or Pedestrian Light Repair	828
2019	Roads - Pothole Maintenance	748
2019	Roads - Debris on Street/Sidewalk/Boulevard	665
2020	CFD - Operation Birthdays	2845
2020	Roads - Pothole Maintenance	774
2020	Roads - Snow and Ice Control	757
2021	Bylaw - Tree - Shrub Infraction	619
2021	Roads - Signs - Missing - Damaged	612
2021	Corporate - Graffiti Concerns	597
2022	Bylaw - Snow and Ice on Sidewalk	974
2022	Bylaw - Tree - Shrub Infraction	734
2022	Roads - Signs - Missing - Damaged	719
2023	WRS - Compost - Green Cart	895
2023	Roads - Signs - Missing - Damaged	877
2023	Roads - Pothole Maintenance	869
2024	Roads - Signs - Missing - Damaged	1018
2024	DBBS - RIM - Property Research	738
2024	Roads - Pothole Maintenance	664
2025	Bylaw - Snow and Ice on Sidewalk	772
2025	Roads - Signs - Missing - Damaged	725
2025	Roads - Traffic or Pedestrian Light Repair	689
 */

-- Top 10 service names overall (by number of reoccurring first occurrences)

WITH firsts AS (
  SELECT
    sr1.service_request_id,
    sr1.service_name,
    sr1.point,
    sr1.requested_date  
  FROM service_requests_analysis sr1
  WHERE NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY
  )
),
firsts_with_repeat AS (
  SELECT
    f.service_name
  FROM firsts f
  WHERE EXISTS (
    SELECT 1
    FROM service_requests_analysis sr2
    WHERE sr2.point = f.point
      AND sr2.service_name = f.service_name
      AND sr2.service_request_id <> f.service_request_id
      AND sr2.requested_date > f.requested_date
      AND sr2.requested_date <= f.requested_date + INTERVAL 30 DAY   
  )
)
SELECT
  service_name,
  COUNT(*) AS reoccurring_first_occurrences
FROM firsts_with_repeat
GROUP BY service_name
ORDER BY reoccurring_first_occurrences DESC
LIMIT 10;

/*
 Roads - Signs - Missing - Damaged	7616
Roads - Debris on Street/Sidewalk/Boulevard	7357
Corporate - Graffiti Concerns	7164
Roads - Traffic or Pedestrian Light Repair	7147
Roads - Roadway Maintenance	7086
Roads - Dead Animal Pick-Up	6735
Roads - Snow and Ice Control	6452
Bylaw - Snow and Ice on Sidewalk	6403
AS - Animal at Large	6378
311 Contact Us	6155
 */

-- Top 3 service names by comm_name overall

WITH firsts AS (
  SELECT
    sr1.service_request_id,
    sr1.service_name,
    sr1.comm_name,
    sr1.point,
    sr1.requested_date  
  FROM service_requests_analysis sr1
  WHERE NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY 
  )
),
firsts_with_repeat AS (
  SELECT
    f.comm_name,
    f.service_name
  FROM firsts f
  WHERE EXISTS (
    SELECT 1
    FROM service_requests_analysis sr2
    WHERE sr2.point = f.point
      AND sr2.service_name = f.service_name
      AND sr2.service_request_id <> f.service_request_id
      AND sr2.requested_date > f.requested_date
      AND sr2.requested_date <= f.requested_date + INTERVAL 30 DAY    
  )
)
SELECT
  comm_name,
  service_name,
  COUNT(*) AS reoccurring_first_occurrences
FROM firsts_with_repeat
GROUP BY comm_name, service_name
ORDER BY reoccurring_first_occurrences DESC
LIMIT 3;

/*
GREENVIEW INDUSTRIAL PARK	WATR - Industrial Monitoring Inquiry	164
WOODBINE	Bylaw - Tree - Shrub Infraction	143
GLENDALE	Bylaw - Tree - Shrub Infraction	131
*/

-- 30-day recurrence rate by year (citywide)

WITH firsts AS (
  SELECT
    sr1.service_request_id,
    sr1.service_name,
    sr1.point,
    sr1.requested_date,
    YEAR(sr1.requested_date) AS year_requested
  FROM service_requests_analysis sr1
  WHERE NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY
  )
),
reoccurring_firsts AS (
  SELECT
    f.service_request_id,
    f.year_requested
  FROM firsts f
  WHERE EXISTS (
    SELECT 1
    FROM service_requests_analysis sr2
    WHERE sr2.point = f.point
      AND sr2.service_name = f.service_name
      AND sr2.service_request_id <> f.service_request_id
      AND sr2.requested_date > f.requested_date
      AND sr2.requested_date <= f.requested_date + INTERVAL 30 DAY
  )
)
SELECT
  f.year_requested,
  COUNT(*) AS first_occurrences,
  COUNT(r.service_request_id) AS first_occurrences_with_30d_repeat,
  ROUND(COUNT(r.service_request_id) / COUNT(*) * 100, 2) AS recurrence_rate_pct
FROM firsts f
LEFT JOIN reoccurring_firsts r
  ON r.service_request_id = f.service_request_id
GROUP BY f.year_requested
ORDER BY f.year_requested;

/*
2012	77260	35686	46.19
2013	75909	34179	45.03
2014	75648	33996	44.94
2015	78998	34406	43.55
2016	88933	38620	43.43
2017	94563	41331	43.71
2018	94016	40939	43.54
2019	100056	44525	44.50
2020	103864	47007	45.26
2021	95545	40523	42.41
2022	100354	41758	41.61
2023	117034	51710	44.18
2024	103134	44398	43.05
2025	99449	42864	43.10
*/

-- Top 3 services per year (based on # of first occurrences that reoccur within 30 days)
-- Includes counts + rate

WITH firsts AS (
  SELECT
    sr1.service_request_id,
    sr1.service_name,
    sr1.point,
    sr1.requested_date,
    YEAR(sr1.requested_date) AS year_requested
  FROM service_requests_analysis sr1
  WHERE NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY
  )
),
firsts_scored AS (
  SELECT
    f.year_requested,
    f.service_name,
    f.service_request_id,
    CASE WHEN EXISTS (
      SELECT 1
      FROM service_requests_analysis sr2
      WHERE sr2.point = f.point
        AND sr2.service_name = f.service_name
        AND sr2.service_request_id <> f.service_request_id
        AND sr2.requested_date > f.requested_date
        AND sr2.requested_date <= f.requested_date + INTERVAL 30 DAY
    ) THEN 1 ELSE 0 END AS reoccurs_30d
  FROM firsts f
),
service_year_rollup AS (
  SELECT
    year_requested,
    service_name,
    COUNT(*) AS first_occurrences,
    SUM(reoccurs_30d) AS first_occurrences_with_30d_repeat,
    ROUND(SUM(reoccurs_30d) / COUNT(*) * 100, 2) AS recurrence_rate_pct
  FROM firsts_scored
  GROUP BY year_requested, service_name
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY year_requested
      ORDER BY first_occurrences_with_30d_repeat DESC
    ) AS rn
  FROM service_year_rollup
)
SELECT
  year_requested,
  service_name,
  first_occurrences,
  first_occurrences_with_30d_repeat,
  recurrence_rate_pct
FROM ranked
WHERE rn <= 3
ORDER BY year_requested, first_occurrences_with_30d_repeat DESC;

/*
2012	CBS Inspection - Plumbing	756	534	70.63
2012	CBS - RIM - Property Research	790	533	67.47
2012	Z - Roads - Roadway Maintenance	785	506	64.46
2013	CBS - RIM - Property Research	789	471	59.70
2013	CBS Inspection - Plumbing	662	453	68.43
2013	Corporate - Graffiti Concerns	640	450	70.31
2014	CBS - RIM - Property Research	776	503	64.82
2014	CBS Inspection - Plumbing	664	487	73.34
2014	Roads - Dead Animal Pick-Up	782	481	61.51
2015	Roads - Roadway Maintenance	831	508	61.13
2015	Roads - Debris on Street/Sidewalk/Boulevard	825	507	61.45
2015	CBS - RIM - Property Research	822	496	60.34
2016	Roads - Traffic or Pedestrian Light Repair	1204	615	51.08
2016	Roads - Roadway Maintenance	1000	610	61.00
2016	Roads - Debris on Street/Sidewalk/Boulevard	1016	590	58.07
2017	Roads - Traffic or Pedestrian Light Repair	1351	709	52.48
2017	Roads - Roadway Maintenance	1055	647	61.33
2017	Roads - Debris on Street/Sidewalk/Boulevard	995	588	59.10
2018	Roads - Traffic or Pedestrian Light Repair	1252	687	54.87
2018	Roads - Roadway Maintenance	1092	684	62.64
2018	Roads - Debris on Street/Sidewalk/Boulevard	1041	592	56.87
2019	Roads - Traffic or Pedestrian Light Repair	1404	828	58.97
2019	Roads - Pothole Maintenance	1325	748	56.45
2019	Roads - Debris on Street/Sidewalk/Boulevard	1095	665	60.73
2020	CFD - Operation Birthdays	2864	2845	99.34
2020	Roads - Pothole Maintenance	1237	774	62.57
2020	Roads - Snow and Ice Control	1010	757	74.95
2021	Bylaw - Tree - Shrub Infraction	1209	619	51.20
2021	Roads - Signs - Missing - Damaged	1515	612	40.40
2021	Corporate - Graffiti Concerns	1045	597	57.13
2022	Bylaw - Snow and Ice on Sidewalk	1279	974	76.15
2022	Bylaw - Tree - Shrub Infraction	1573	734	46.66
2022	Roads - Signs - Missing - Damaged	1698	719	42.34
2023	WRS - Compost - Green Cart	1216	895	73.60
2023	Roads - Signs - Missing - Damaged	1962	877	44.70
2023	Roads - Pothole Maintenance	1456	869	59.68
2024	Roads - Signs - Missing - Damaged	1862	1018	54.67
2024	DBBS - RIM - Property Research	1414	738	52.19
2024	Roads - Pothole Maintenance	1142	664	58.14
2025	Bylaw - Snow and Ice on Sidewalk	1073	772	71.95
2025	Roads - Signs - Missing - Damaged	1221	725	59.38
2025	Roads - Traffic or Pedestrian Light Repair	1287	689	53.54
 */

-- Top services overall (by # of first occurrences that reoccur within 30 days)

WITH firsts AS (
  SELECT
    sr1.service_request_id,
    sr1.service_name,
    sr1.point,
    sr1.requested_date
  FROM service_requests_analysis sr1
  WHERE NOT EXISTS (
    SELECT 1
    FROM service_requests_analysis sr0
    WHERE sr0.point = sr1.point
      AND sr0.service_name = sr1.service_name
      AND sr0.service_request_id <> sr1.service_request_id
      AND sr0.requested_date < sr1.requested_date
      AND sr0.requested_date >= sr1.requested_date - INTERVAL 30 DAY
  )
),
firsts_scored AS (
  SELECT
    f.service_name,
    CASE WHEN EXISTS (
      SELECT 1
      FROM service_requests_analysis sr2
      WHERE sr2.point = f.point
        AND sr2.service_name = f.service_name
        AND sr2.service_request_id <> f.service_request_id
        AND sr2.requested_date > f.requested_date
        AND sr2.requested_date <= f.requested_date + INTERVAL 30 DAY
    ) THEN 1 ELSE 0 END AS reoccurs_30d
  FROM firsts f
)
SELECT
  service_name,
  COUNT(*) AS first_occurrences,
  SUM(reoccurs_30d) AS first_occurrences_with_30d_repeat,
  ROUND(SUM(reoccurs_30d) / COUNT(*) * 100, 2) AS recurrence_rate_pct
FROM firsts_scored
GROUP BY service_name
ORDER BY first_occurrences_with_30d_repeat DESC
LIMIT 10;

/*
Roads - Signs - Missing - Damaged	14851	7616	51.28
Roads - Debris on Street/Sidewalk/Boulevard	13188	7357	55.79
Corporate - Graffiti Concerns	12025	7164	59.58
Roads - Traffic or Pedestrian Light Repair	13893	7147	51.44
Roads - Roadway Maintenance	13065	7086	54.24
Roads - Dead Animal Pick-Up	12091	6735	55.70
Roads - Snow and Ice Control	9264	6452	69.65
Bylaw - Snow and Ice on Sidewalk	8450	6403	75.78
AS - Animal at Large	10880	6378	58.62
311 Contact Us	9212	6155	66.82
*/