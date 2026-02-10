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

/*
CPB - CPB and Office of Land Servicing & Housing Projects	50.00	50.0	100.00	0.00	
Z - Roads - Traffic Camera Inquiry	51.62	48.38	100.00	3.23	30.96
Partnerships - Employee Complaint - Compliment	33.33	47.14	100.00	0.00	
RSP - Southland Leisure Centre Inquiry	66.67	47.14	100.00	0.00	
Z - CNS - CHAMPS Inquiry	35.56	45.65	100.00	0.00	
REC - Pool - Canyon Meadows	54.33	44.05	100.00	0.00	
REC - Pool - Sir Winston Churchill	55.33	43.21	100.00	0.00	
CFD - Inspection - Windshield Washer Dispenser - FHB	42.86	42.86	85.71	0.00	
PSD - Major Transit Projects Inquiry	26.14	42.68	100.00	0.00	
REC - Pool - Bob Bahan	58.33	39.38	100.00	0.00	
PDA - Rapid Damage Assessment	22.22	39.13	100.00	0.00	
REC - Pool - Killarney	43.89	37.88	100.00	0.00	
REC - Pool - Foothills	71.97	37.65	100.00	0.00	
REC - Pool - Thornhill	43.18	37.31	100.00	0.00	
WRS - Landfill - Operations	16.67	37.27	100.00	0.00	
Roads - Streetlight - Specialty and Bridge Light Maintenance	41.43	36.59	100.00	0.00	
DBBS Inspection - Electrical	29.50	36.27	78.91	0.00	
DBBS Inspection - Residential Improvement Project - RIP	49.71	36.0	84.10	0.00	
CED - Filming and Drone Activities (Behind The Scenes)	39.60	35.56	100.00	13.33	7.50
PSD - Major Road Projects Inquiry	37.50	35.36	100.00	0.00	
*/

-- Trend direction detection for recurrence rates

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
    SUM(reoccurs_30d) / COUNT(*) AS recurrence_rate
  FROM firsts_scored
  GROUP BY service_name, year_requested
),
first_last_year AS (
  SELECT
    service_name,
    MIN(year_requested) AS first_year,
    MAX(year_requested) AS last_year
  FROM yearly_rates
  GROUP BY service_name
),
trend_base AS (
  SELECT
    f.service_name,
    y1.recurrence_rate AS first_year_rate,
    y2.recurrence_rate AS last_year_rate
  FROM first_last_year f
  JOIN yearly_rates y1
    ON y1.service_name = f.service_name
   AND y1.year_requested = f.first_year
  JOIN yearly_rates y2
    ON y2.service_name = f.service_name
   AND y2.year_requested = f.last_year
)
SELECT
  service_name,
  ROUND(first_year_rate * 100, 2) AS first_year_rate_pct,
  ROUND(last_year_rate * 100, 2) AS last_year_rate_pct,
  ROUND((last_year_rate - first_year_rate) * 100, 2) AS pct_point_change,
  CASE
    WHEN last_year_rate < first_year_rate - 0.02 THEN 'Improving'
    WHEN last_year_rate > first_year_rate + 0.02 THEN 'Worsening'
    ELSE 'Stable'
  END AS trend_direction
FROM trend_base
ORDER BY pct_point_change DESC;

/*
WRS - Landfill - Operations	0.00	100.00	100.00	Worsening
Roads - Streetlight - Specialty and Bridge Light Maintenance	0.00	100.00	100.00	Worsening
Z - CNS - CHAMPS Inquiry	0.00	100.00	100.00	Worsening
Z - Roads - Traffic Camera Inquiry	3.23	100.00	96.77	Worsening
REC - Mobile Skateparks / Skateboard Programs	13.33	100.00	86.67	Worsening
*/