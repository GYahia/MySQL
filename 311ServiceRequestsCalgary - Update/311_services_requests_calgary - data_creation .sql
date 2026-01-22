-- Active: 1736824156068@@localhost@3306@311_service_requests
-- Data downloaded from Calgary website for the date of 10 Feb 2025
-- Source: https://data.calgary.ca/Services-and-Amenities/311-Service-Requests/iahh-g8bj/about_data

-- Create a new database
DROP DATABASE IF EXISTS 311_service_requests;
SHOW DATABASES;

-- Create the database
CREATE DATABASE 311_service_requests;
-- Show all databases
SHOW DATABASES;


SHOW VARIABLES LIKE "secure_file_priv";

-- Use the newly created database
USE 311_service_requests;


DROP TABLE IF EXISTS service_requests;
-- Create the table if it does not exist
CREATE TABLE IF NOT EXISTS service_requests (
    service_request_id VARCHAR(255 ),
    requested_date TIMESTAMP,  
    updated_date TIMESTAMP, 
    closed_date TIMESTAMP, 
    status_description VARCHAR(255),
    source VARCHAR(255),
    service_name VARCHAR(255),
    agency_responsible VARCHAR(255),
    address VARCHAR(255),
    comm_code VARCHAR(255),
    comm_name VARCHAR(255),
    location_type VARCHAR(255),
    longitude DOUBLE,
    latitude DOUBLE,
    point VARCHAR(255)   -- POSSIBLY NEED TO CHANGE IT TO GEOMETRY AT SOME , too many errors when using POINT OR GEOMETRY SRID 4326
);
-- COULD NOT LAOD longitude and latitude as DOUBLE due to error: Data Truncated for column 'longitude' at row 23 
SHOW TABLES;

SHOW COLUMNS FROM service_requests;
--------------------------------------------------------
-- DATA was imported from CSV file using MySQL Workbench
--------------------------------------------------------

/* First Glance at the CSV File in Excel shows:
- Missing information in columns: comm_code, comm_name, location_type. update_date and closed_date
- service_name and agency_respomnsible could be be divided in columns with more details
- service_name has some fields with a lower case letter instead of an upper   DONE
- coom_code and comm_name have alphanumerical values for some rows
*/

USE 311_service_requests;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/311_Service_Requests_20260117.csv'
INTO TABLE service_requests
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
-- Map CSV columns to variables, then assign to table columns:
(
  @service_request_id, 
  @requested_date, 
  @updated_date, 
  @closed_date, 
  @status_description, 
  @source, 
  @service_name, 
  @agency_responsible, 
  @address, 
  @comm_code, 
  @comm_name, 
  @location_type, 
  @longitude,  -- Treat empty as NULL
  @latitude,   -- Treat empty as NULL
  @point
)
SET
  service_request_id = @service_request_id,
  requested_date = STR_TO_DATE(NULLIF(@requested_date,''), '%Y/%m/%d %h:%i:%s %p'),
  updated_date = STR_TO_DATE(NULLIF(@updated_date,''), '%Y/%m/%d %h:%i:%s %p'),
  closed_date = STR_TO_DATE(NULLIF(@closed_date,''), '%Y/%m/%d %h:%i:%s %p'),
  status_description = @status_description,
  source = @source,
  service_name = @service_name,
  agency_responsible = @agency_responsible,
  address = @address,
  comm_code = @comm_code,
  comm_name = @comm_name,
  location_type = @location_type,
  longitude = NULLIF(@longitude, ''), -- Convert empty string to NULL
  latitude = NULLIF(@latitude, ''),
  point = @point; 

SELECT COUNT(*) FROM service_requests;

SELECT * FROM service_requests LIMIT 10;

