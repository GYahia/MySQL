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
(SELECT
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
ORDER BY pct_point_change DESC LIMIT 10)
UNION ALL
(SELECT
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
ORDER BY pct_point_change ASC LIMIT 10);

/*
Roads - Streetlight - Specialty and Bridge Light Maintenance	0.00	100.00	100.00	Worsening
WRS - Landfill - Operations	0.00	100.00	100.00	Worsening
Z - CNS - CHAMPS Inquiry	0.00	100.00	100.00	Worsening
Z - Roads - Traffic Camera Inquiry	3.23	100.00	96.77	Worsening
REC - Mobile Skateparks / Skateboard Programs	13.33	100.00	86.67	Worsening
Roads - Street Cleaning Annual Program	0.00	74.38	74.38	Worsening
311 Contact Us	0.00	69.64	69.64	Worsening
CED - Filming and Drone Activities (Behind The Scenes)	30.77	100.00	69.23	Worsening
DBBS Inspection - Electrical	0.00	68.58	68.58	Worsening
RSP - Subsidized Programs - Fair Entry	0.00	65.10	65.10	Worsening
Partnerships - Employee Complaint - Compliment	100.00	0.00	-100.00	Improving
Customer Service & Communications - General Concerns	100.00	0.00	-100.00	Improving
CPB - CPB and Office of Land Servicing & Housing Projects	100.00	0.00	-100.00	Improving
REC - Pool - Canyon Meadows	100.00	0.00	-100.00	Improving
REC - Pool - Thornhill	100.00	0.00	-100.00	Improving
PSD - Major Transit Projects Inquiry	100.00	4.55	-95.45	Improving
PDA - Rapid Damage Assessment	100.00	11.11	-88.89	Improving
CFD - Inspection - Windshield Washer Dispenser - FHB	85.71	0.00	-85.71	Improving
REC - Southland Leisure Centre Inquiry	100.00	25.00	-75.00	Improving
Roads - E-Scooter	100.00	28.57	-71.43	Improving
*/

-- Query 13: Top 3 worsening services per community
-- "Worsening" = last_year_rate - first_year_rate is positive and meaningful
-- Filter out low-volume community/service combos to reduce noise.

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
firsts_scored AS (
  SELECT
    f.comm_name,
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
    comm_name,
    service_name,
    year_requested,
    COUNT(*) AS first_occurrences,
    SUM(reoccurs_30d) / COUNT(*) AS recurrence_rate
  FROM firsts_scored
  GROUP BY comm_name, service_name, year_requested
),
first_last_year AS (
  SELECT
    comm_name,
    service_name,
    MIN(year_requested) AS first_year,
    MAX(year_requested) AS last_year,
    SUM(first_occurrences) AS total_first_occurrences_all_years
  FROM yearly_rates
  GROUP BY comm_name, service_name
),
trend_base AS (
  SELECT
    f.comm_name,
    f.service_name,
    f.total_first_occurrences_all_years,
    y1.recurrence_rate AS first_year_rate,
    y2.recurrence_rate AS last_year_rate
  FROM first_last_year f
  JOIN yearly_rates y1
    ON y1.comm_name = f.comm_name
   AND y1.service_name = f.service_name
   AND y1.year_requested = f.first_year
  JOIN yearly_rates y2
    ON y2.comm_name = f.comm_name
   AND y2.service_name = f.service_name
   AND y2.year_requested = f.last_year
),
worsening AS (
  SELECT
    comm_name,
    service_name,
    total_first_occurrences_all_years,
    ROUND(first_year_rate * 100, 2) AS first_year_rate_pct,
    ROUND(last_year_rate * 100, 2) AS last_year_rate_pct,
    ROUND((last_year_rate - first_year_rate) * 100, 2) AS pct_point_change
  FROM trend_base
  WHERE total_first_occurrences_all_years >= 50
    AND (last_year_rate - first_year_rate) > 0.02  -- only meaningful worsening
),
ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY comm_name
      ORDER BY pct_point_change DESC, total_first_occurrences_all_years DESC, service_name
    ) AS rn
  FROM worsening
)
SELECT
  comm_name,
  service_name,
  total_first_occurrences_all_years,
  first_year_rate_pct,
  last_year_rate_pct,
  pct_point_change
FROM ranked
WHERE rn <= 5
ORDER BY comm_name, pct_point_change DESC;


-- Trend direction by community x service

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
firsts_scored AS (
  SELECT
    f.comm_name,
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
    comm_name,
    service_name,
    year_requested,
    COUNT(*) AS first_occurrences,
    SUM(reoccurs_30d) / COUNT(*) AS recurrence_rate
  FROM firsts_scored
  GROUP BY comm_name, service_name, year_requested
),
first_last_year AS (
  SELECT
    comm_name,
    service_name,
    MIN(year_requested) AS first_year,
    MAX(year_requested) AS last_year,
    SUM(first_occurrences) AS total_first_occurrences_all_years
  FROM yearly_rates
  GROUP BY comm_name, service_name
),
trend_base AS (
  SELECT
    f.comm_name,
    f.service_name,
    f.total_first_occurrences_all_years,
    y1.recurrence_rate AS first_year_rate,
    y2.recurrence_rate AS last_year_rate
  FROM first_last_year f
  JOIN yearly_rates y1
    ON y1.comm_name = f.comm_name
   AND y1.service_name = f.service_name
   AND y1.year_requested = f.first_year
  JOIN yearly_rates y2
    ON y2.comm_name = f.comm_name
   AND y2.service_name = f.service_name
   AND y2.year_requested = f.last_year
)
(SELECT
  comm_name,
  service_name,
  total_first_occurrences_all_years,
  ROUND(first_year_rate * 100, 2) AS first_year_rate_pct,
  ROUND(last_year_rate * 100, 2) AS last_year_rate_pct,
  ROUND((last_year_rate - first_year_rate) * 100, 2) AS pct_point_change,
  CASE
    WHEN last_year_rate < first_year_rate - 0.02 THEN 'Improving'
    WHEN last_year_rate > first_year_rate + 0.02 THEN 'Worsening'
    ELSE 'Stable'
  END AS trend_direction
FROM trend_base
WHERE total_first_occurrences_all_years >= 50 -- to reduce noisy low-volume combos
ORDER BY pct_point_change DESC, total_first_occurrences_all_years DESC LIMIT 10)
UNION ALL
(SELECT
  comm_name,
  service_name,
  total_first_occurrences_all_years,
  ROUND(first_year_rate * 100, 2) AS first_year_rate_pct,
  ROUND(last_year_rate * 100, 2) AS last_year_rate_pct,
  ROUND((last_year_rate - first_year_rate) * 100, 2) AS pct_point_change,
  CASE
    WHEN last_year_rate < first_year_rate - 0.02 THEN 'Improving'
    WHEN last_year_rate > first_year_rate + 0.02 THEN 'Worsening'
    ELSE 'Stable'
  END AS trend_direction
FROM trend_base
WHERE total_first_occurrences_all_years >= 50 -- to reduce noisy low-volume combos
ORDER BY pct_point_change ASC, total_first_occurrences_all_years ASC LIMIT 10);

/*
RICHMOND	Roads - Signs - Traffic and Roadmarking	103	0.00	100.00	100.00	Worsening
MAHOGANY	Roads - Signs - Traffic and Roadmarking	100	0.00	100.00	100.00	Worsening
WINDSOR PARK	Roads - Signs - Parking	81	0.00	100.00	100.00	Worsening
SETON	Roads - Signs - Traffic and Roadmarking	78	0.00	100.00	100.00	Worsening
HAWKWOOD	Roads - Sidewalk - Curb and Gutter Repair	77	0.00	100.00	100.00	Worsening
MARLBOROUGH PARK	Roads - Signs - Parking	75	0.00	100.00	100.00	Worsening
PARKDALE	WATS - Water Pressure Issues	75	0.00	100.00	100.00	Worsening
APPLEWOOD PARK	Roads - Dead Animal Pick-Up	74	0.00	100.00	100.00	Worsening
LINCOLN PARK	Roads - Traffic or Pedestrian Light Repair	74	0.00	100.00	100.00	Worsening
MILLRISE	Roads - Debris on Street/Sidewalk/Boulevard	71	0.00	100.00	100.00	Worsening
WINSTON HEIGHTS/MOUNTVIEW	Law - Risk Management and Claims	50	100.00	0.00	-100.00	Improving
MOUNT PLEASANT	WATS - Cross Connection Inquiries	50	100.00	0.00	-100.00	Improving
FAIRVIEW INDUSTRIAL	CBS - RIM - Property Research	50	100.00	0.00	-100.00	Improving
OAKRIDGE	AS - Lost and Found Animal	50	100.00	0.00	-100.00	Improving
COLLINGWOOD	WATS - Water Outage	51	100.00	0.00	-100.00	Improving
GREENVIEW INDUSTRIAL PARK	CBS - RIM - Property Research	51	100.00	0.00	-100.00	Improving
MISSION	AS - Pick Up Stray	51	100.00	0.00	-100.00	Improving
DEER RIDGE	WATS - Water Off-On Appointment	52	100.00	0.00	-100.00	Improving
HAWKWOOD	AS - Pick Up Stray	52	100.00	0.00	-100.00	Improving
HAMPTONS	Roads - Traffic Signal Timing Inquiry	52	100.00	0.00	-100.00	Improving
*/

