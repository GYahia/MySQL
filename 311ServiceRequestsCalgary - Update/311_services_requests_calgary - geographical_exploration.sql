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
-- Geographical Analysis
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Using Table "service_requests_analysis"
----------------------------------------------------------------------------------

-- Top 3 service_name x comm_name overall
-- (by # of first occurrences that reoccur within 30 days)

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
firsts_scored AS (
  SELECT
    f.comm_name,
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
  comm_name,
  service_name,
  COUNT(*) AS first_occurrences,
  SUM(reoccurs_30d) AS first_occurrences_with_30d_repeat,
  ROUND(SUM(reoccurs_30d) / COUNT(*) * 100, 2) AS recurrence_rate_pct
FROM firsts_scored
GROUP BY comm_name, service_name
ORDER BY first_occurrences_with_30d_repeat DESC
LIMIT 3;
