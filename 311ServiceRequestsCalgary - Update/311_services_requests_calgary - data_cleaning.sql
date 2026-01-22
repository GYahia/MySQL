-- Active: 1736824156068@@localhost@3306@311_service_requests
-- Data downloaded from Calgary website for the date of 10 Feb 2025
-- Source: https://data.calgary.ca/Services-and-Amenities/311-Service-Requests/iahh-g8bj/about_data

-- Use the newly created database
USE 311_service_requests;


--------------------------------------------------------
-- DATA CLEANING
--------------------------------------------------------

-- CREATE A COPY OF THE RAW DATA TABLE TO WORK ON

DROP TABLE IF EXISTS service_requests_clean;
CREATE TABLE service_requests_clean LIKE service_requests;

INSERT INTO service_requests_clean
SELECT *
FROM service_requests;

SELECT * 
FROM service_requests_clean
LIMIT 100;

-- Finding Duplicates

WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY service_request_id, requested_date, updated_date, closed_date, status_description, source, service_name, agency_responsible, address, comm_code, comm_name, location_type, longitude, latitude, point) AS row_num
    FROM service_requests_clean
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- No Duplicates Found

-- Standardize Data 
SELECT * 
FROM service_requests_clean
WHERE BINARY LEFT(service_name, 1) = LOWER(LEFT(service_name, 1))
AND service_name NOT REGEXP '^[0-9]';
--  All results of the query start with the lower letter Z

UPDATE service_requests_clean
SET 
  service_name = CONCAT(UPPER(LEFT(service_name, 1)), SUBSTRING(service_name, 2))
WHERE BINARY LEFT(service_name, 1) = LOWER(LEFT(service_name, 1));


-- Check for entries that start with numbers for comm_code and/or comm_name
SELECT DISTINCT comm_code, comm_name
FROM service_requests_clean
WHERE comm_code REGEXP '^[0-9]'OR comm_name REGEXP '^[0-9]'; 

-- Most of them have the same values, some entries have N/A in comm_code and an Alphanumerical value in comm_name
UPDATE service_requests_clean
SET comm_code = comm_name
WHERE comm_code = 'N/A';

SELECT COUNT(comm_name)
FROM service_requests_clean
WHERE comm_name REGEXP '^[0-9]' OR comm_code REGEXP '^[0-9]';

SELECT COUNT(*)
FROM service_requests_clean; -- Total of 7136649 entries

-- 34879 entries out of 7136649 have a comm_name or comm_code that starts with a number: 0.49%
-- For this analysis I am choosing to leave out those values as they are not significant


DROP TABLE IF EXISTS service_requests_clean_v2;
CREATE TABLE service_requests_clean_v2 LIKE service_requests_clean;

INSERT INTO service_requests_clean_v2
SELECT *
FROM service_requests_clean;

DELETE FROM service_requests_clean_v2
WHERE comm_name REGEXP '^[0-9]' OR comm_code REGEXP '^[0-9]';

SELECT *
FROM service_requests_clean_v2; --> Address column has almost all NULL or Empty fields

SELECT *
FROM service_requests_clean_v2
WHERE address != '';

-- 7136649 rows in the table, all entries have an empty address field

-- Drop the address column
ALTER TABLE service_requests_clean_v2
DROP COLUMN address;

SELECT *
FROM service_requests_clean_v2;

-- CHECK IF SERVICE REQUEST ID HAS EMPTY OR NULL VALUES
SELECT COUNT(service_request_id)
FROM service_requests_clean_v2
WHERE service_request_id = '' OR service_request_id IS NULL; --> 0   

-- check range of dates 
SELECT MIN(requested_date), MAX(requested_date)
FROM service_requests_clean_v2; -- 2010-01-25 >> 2026-01-16

SELECT MIN(updated_date), MAX(updated_date)
FROM service_requests_clean_v2; --2012-01-01 >> 2026-01-16

SELECT MIN(closed_date), MAX(closed_date)
FROM service_requests_clean_v2; --2010-02-17 >> 2026-01-16


-- CHECK FOR MISSING DATES
SELECT service_request_id, requested_date, updated_date, closed_date
FROM service_requests_clean_v2
WHERE updated_date IS NULL or requested_date IS NULL or closed_date IS NULL;

-- Updated date has A LOT OF missing values AND SOME IN CLOSED DATE

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE updated_date IS NULL; -- 77620 >> 1.08%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE closed_date IS NULL; -- 65367 >> 0.92%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE updated_date = requested_date;  --562778 >> 7.9%

SELECT COUNT(updated_date)
FROM service_requests_clean_v2
WHERE updated_date = closed_date; -- 5634158 >> 78.9%



-- Fill in the missing updated_date with the closed_date
UPDATE service_requests_clean_v2
SET updated_date = closed_date
WHERE updated_date IS NULL;


-- Fill in the missing closed_date with the updated_date
UPDATE service_requests_clean_v2
SET closed_date = updated_date
WHERE closed_date IS NULL;

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE closed_date IS NULL AND updated_date IS NULL; -- 31 

-- Drop those entries column
DELETE FROM service_requests_clean_v2
WHERE closed_date IS NULL AND updated_date IS NULL;


SELECT *
FROM service_requests_clean_v2;

SELECT COUNT(*)
FROM service_requests_clean_v2;  -- New number of rows 7101739

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE status_description != 'Closed'; -- 179135 >> 2.5% are not closed tickets

SELECT status_description,COUNT(status_description), COUNT(status_description)*100/7101739 AS percentage
FROM service_requests_clean_v2
GROUP BY status_description ; -- 97.48% CLOSED , 1.55% DUPLICATE CLOSED, 0.95% OPEN, 0.027 DUPLICATE OPEN AND 0.0015 TO BE DELETED

DELETE FROM service_requests_clean_v2
WHERE status_description = 'TO BE DELETED';

DELETE FROM service_requests_clean_v2
WHERE status_description = 'Duplicate (Open)';

SELECT status_description,COUNT(status_description), COUNT(status_description)*100/7101739 AS percentage
FROM service_requests_clean_v2
GROUP BY status_description ; -- 97.48% CLOSED , 1.55% DUPLICATE CLOSED, 0.95% OPEN

SELECT service_request_id, requested_date, updated_date, closed_date, status_description, source, service_name, agency_responsible, comm_code, comm_name, location_type
FROM service_requests_clean_v2
WHERE status_description ='Duplicate (Closed)' LIMIT 100;  -- Some of those entries have a closed date before the updated date -- 

WITH duplicate_cte_v2 AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY service_request_id, requested_date, closed_date, source, service_name, agency_responsible, comm_code, comm_name, location_type, longitude, latitude, point) AS row_num
    FROM service_requests_clean_v2
)
SELECT *
FROM duplicate_cte_v2
WHERE row_num > 1;

-- NO DUPLICATES FOUND 


WITH first_ticket_cte AS (
  SELECT service_request_id,
    requested_date,
    updated_date,
    closed_date,
    service_name,
    agency_responsible,
    comm_name,
    longitude,
    latitude
  FROM service_requests_clean_v2
  WHERE status_description = 'Closed' -- First ticket must be closed
),
second_ticket_cte AS (
  SELECT service_request_id,
    requested_date,
    updated_date,
    closed_date,
    service_name,
    agency_responsible,
    comm_name,
    longitude,
    latitude
  FROM service_requests_clean_v2
  WHERE status_description = 'Duplicate (Closed)' -- Second ticket is a duplicate
)
SELECT f.service_request_id AS f_ticket_id,
  f.requested_date AS f_requested_date,
  f.updated_date AS f_updated_date,
  f.closed_date AS f_closed_date,
  s.service_request_id AS s_ticket_id,
  s.requested_date AS s_requested_date,
  s.updated_date AS s_updated_date,
  s.closed_date AS s_closed_date
FROM first_ticket_cte f
  JOIN second_ticket_cte s ON f.service_name = s.service_name
  AND f.agency_responsible = s.agency_responsible
  AND f.comm_name = s.comm_name
  AND f.requested_date <= s.requested_date
  AND f.closed_date >= s.requested_date
  AND ABS(f.longitude - s.longitude) < 0.0001
  AND ABS(f.latitude - s.latitude) < 0.0001;

WITH first_ticket_cte AS (
  SELECT service_request_id,
    requested_date,
    updated_date,
    closed_date,
    service_name,
    agency_responsible,
    comm_name,
    longitude,
    latitude
  FROM service_requests_clean_v2
  WHERE status_description = 'Closed' -- First ticket must be closed
),
second_ticket_cte AS (
  SELECT service_request_id,
    requested_date,
    updated_date,
    closed_date,
    service_name,
    agency_responsible,
    comm_name,
    longitude,
    latitude
  FROM service_requests_clean_v2
  WHERE status_description = 'Duplicate (Closed)' -- Second ticket is a duplicate
)
SELECT COUNT(*) AS duplicate_count
FROM first_ticket_cte f
  JOIN second_ticket_cte s ON f.service_name = s.service_name
  AND f.agency_responsible = s.agency_responsible
  AND f.comm_name = s.comm_name
  AND f.requested_date <= s.requested_date
  AND f.closed_date >= s.requested_date
  AND ABS(f.longitude - s.longitude) < 0.0001
  AND ABS(f.latitude - s.latitude) < 0.0001; -- 898699 >> 12.7%





  -- There is no clear path of removing the closed or duplicated closed
  -- in some case the updated date in duplciate closed = closed date, contrary to the original closed ticket
  -- in order to avoid missing any important data, i will keep both them for now




SHOW COLUMNS FROM service_requests_clean_v2;


/*
-- Export the table to a CSV file
SELECT *
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/service_requests_clean_v2.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM service_requests_clean_v2;
*/

SELECT location_type, COUNT(*) AS location_count
FROM service_requests_clean_v2
WHERE location_type NOT LIKE '%Comm%'
GROUP BY location_type; -- The only other value is None : 408909 >> 5.8%

-- LOCATION TYPE IS NOT VERY IMPORTANT FOR THIS ANALYSIS, DROP THE COLUMN
ALTER TABLE service_requests_clean_v2
DROP COLUMN location_type;


SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE service_request_id='' OR service_request_id IS NULL   
;
--------- 0

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE source='' OR source IS NULL
; 

--------- 0

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE service_name='' OR service_name IS NULL
;
---------- 0
SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE agency_responsible='' OR agency_responsible IS NULL
;

---------- 0

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE comm_code='' OR comm_code IS NULL
;

---------- 408909 >> 5.7%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE comm_name='' OR comm_name IS NULL
;

---------- 408909 >> 5.7%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE longitude IS NULL
;

---------- 409737 >> 5.8%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE latitude IS NULL
;

---------- 409737 >> 5.8%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE point IS NULL OR point=''
;

---------- 409737 >> 5.8%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE point IS NULL OR point='' AND longitude IS NULL AND latitude IS NULL;
---------- 409737 >> 5.6%

SELECT COUNT(*)
FROM service_requests_clean_v2
WHERE comm_code='' OR comm_code IS NULL AND comm_name='' OR comm_name IS NULL;
---------- 408909 >> 5.6%


SELECT *
FROM service_requests_clean_v2
WHERE comm_code=''OR comm_code IS NULL;

SELECT comm_name, point, COUNT(*)
FROM service_requests_clean_v2
WHERE comm_code='' OR comm_code IS NULL
GROUP BY comm_name, point;

-- 408909 rows have missing comm_code and comm_name, all of them have missing longitude, latitude and point


SELECT comm_code, comm_name, COUNT(*)
FROM service_requests_clean_v2
WHERE point IS NULL OR point=''
GROUP BY comm_code, comm_name;

-- 408909 with comm_name NULL/Empty , 766 with N/A

-- FOR THIS ANALYSIS I WILL DROP THE ROWS WITH MISSING VALUES FOR comm_code, comm_name, longitude, latitude and point

DROP TABLE IF EXISTS service_requests_clean_v3;
CREATE TABLE service_requests_clean_v3 LIKE service_requests_clean_v2;

INSERT INTO service_requests_clean_v3
SELECT *
FROM service_requests_clean_v2
WHERE comm_code != '' AND comm_code IS NOT NULL AND comm_code!='N/A';

-- New number of rows 6690076

SELECT *
FROM service_requests_clean_v3;

SELECT *
FROM service_requests_clean_v3
LIMIT 100000
INTO OUTFILE 'C:/USERS/ghass/Documents/Data Analysis/GitHub/MySQL/311ServiceRequestsCalgary - Update/service_requests_clean_v3.csv'
CHARACTER SET utf8
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n';

SHOW COLUMNS FROM service_requests_clean_v3;

SELECT 'service_request_id', 'requested_date', 'updated_date', 'closed_date', 'status_description', 'source', 'service_name', 'agency_responsible', 'comm_code', 'comm_name', 'longitude', 'latitude', 'point'
UNION ALL
SELECT *
FROM service_requests_clean_v3
LIMIT 100000
INTO OUTFILE 'C:/USERS/ghass/Documents/Data Analysis/GitHub/MySQL/311ServiceRequestsCalgary - Update/service_requests_clean_v3_bis.csv'
CHARACTER SET utf8
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY ''
LINES TERMINATED BY '\n';

