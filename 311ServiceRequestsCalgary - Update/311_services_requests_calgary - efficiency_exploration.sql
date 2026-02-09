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
-- Efficiency Analysis
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
-- Using Table "service_requests_analysis"
----------------------------------------------------------------------------------

-- % of first occurrences that never reoccur within 30 days

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
  year_requested,
  COUNT(*) AS first_occurrences,
  SUM(CASE WHEN reoccurs_30d = 0 THEN 1 ELSE 0 END) AS one_off_first_occurrences,
  ROUND(SUM(CASE WHEN reoccurs_30d = 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS one_off_rate_pct
FROM firsts_scored
GROUP BY year_requested
ORDER BY year_requested;

/*
2012	77260	41574	53.81
2013	75909	41730	54.97
2014	75648	41652	55.06
2015	78998	44592	56.45
2016	88933	50313	56.57
2017	94563	53232	56.29
2018	94016	53077	56.46
2019	100056	55531	55.50
2020	103864	56857	54.74
2021	95545	55022	57.59
2022	100354	58596	58.39
2023	117034	65324	55.82
2024	103134	58736	56.95
2025	99449	56585	56.90
*/

-- Stability of recurrence rates by service over time

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
    f.service_name,
    f.year_requested,
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
yearly_rates AS (
  SELECT
    service_name,
    year_requested,
    COUNT(*) AS first_occurrences,
    SUM(reoccurs_30d) AS recurring_first_occurrences,
    SUM(reoccurs_30d) / COUNT(*) AS recurrence_rate
  FROM firsts_scored
  GROUP BY service_name, year_requested
)
SELECT
  service_name,
  ROUND(AVG(recurrence_rate) * 100, 2) AS avg_recurrence_rate_pct,
  ROUND(STDDEV_POP(recurrence_rate) * 100, 2) AS stddev_recurrence_rate_pct,
  ROUND(MAX(recurrence_rate) * 100, 2) AS max_rate_pct,
  ROUND(MIN(recurrence_rate) * 100, 2) AS min_rate_pct,
  ROUND(MAX(recurrence_rate) / NULLIF(MIN(recurrence_rate), 0), 2) AS max_min_ratio
FROM yearly_rates
GROUP BY service_name
ORDER BY stddev_recurrence_rate_pct DESC
LIMIT 20;
