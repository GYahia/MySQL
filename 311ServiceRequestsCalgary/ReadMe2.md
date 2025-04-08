# 311 Service Requests Data Analysis - Calgary

This project involves the exploration and analysis of 311 service requests data for the city of Calgary. The data was downloaded from the [Calgary Open Data Portal](https://data.calgary.ca/) and covers service requests up to **February 10, 2025**.

---

## 📊 Project Overview

The goal of this project is to analyze 311 service requests data to uncover trends in service demand, efficiency, and geographical distribution. Key focus areas include:

- **Temporal patterns** (monthly, seasonal, yearly trends).
- **Service request types** (most common services, recurring issues).
- **Geographical hotspots** (communities with high request volumes).
- **Agency performance** (response times, request handling efficiency).

---

## 📁 Data Overview

### Original Data Format
The raw data was imported into MySQL with the following structure:

| Field Name            | Data Type       |
|-----------------------|----------------|
| service_request_id    | varchar(255)    |
| requested_date        | timestamp       |
| updated_date          | timestamp       |
| closed_date           | timestamp       |
| status_description    | varchar(255)    |
| source                | varchar(255)    |
| service_name          | varchar(255)    |
| agency_responsible    | varchar(255)    |
| address               | varchar(255)    |
| comm_code             | varchar(255)    |
| comm_name             | varchar(255)    |
| location_type         | varchar(255)    |
| longitude             | double          |
| latitude              | double          |
| point                 | varchar(255)    |

---

## 🧹 Data Cleaning Steps

### Key Transformations Applied:
1. **Created a Clean Copy**:  
   - Raw data was copied to `service_requests_clean_v3` for cleaning.  
2. **Standardized Fields**:  
   - Capitalized the first letter of `service_name` entries (e.g., "cart management" → "Cart Management").  
3. **Handled Missing Data**:  
   - Removed **5.6% of rows** (378,196 rows) with missing `comm_code`, `comm_name`, or geospatial data (`longitude`, `latitude`, `point`).  
4. **Dropped Irrelevant Columns**:  
   - Removed `address` (100% empty) and `location_type` (non-critical for analysis).  
5. **Filled Missing Dates**:  
   - Used `closed_date` to fill missing `updated_date` and vice versa.  
   - Removed 31 rows where both dates were missing.  
6. **Filtered Invalid Statuses**:  
   - Deleted entries with statuses `TO BE DELETED` and `Duplicate (Open)` (0.0013% of data).  

### Final Cleaned Dataset:
- **Rows**: 6,263,716 (reduced from an initial 6,677,122).  
- **Columns**:  
  `service_request_id`, `requested_date`, `updated_date`, `closed_date`, `status_description`, `source`, `service_name`, `agency_responsible`, `comm_code`, `comm_name`, `longitude`, `latitude`, `point`.  
- **Exported As**: `service_requests_clean_v3.csv`.

---

## 📈 Data Exploration Highlights

### ⏳ **Temporal Analysis**
- **Monthly Trends**:  
  - **Busiest Months**: June (peak), followed by May, July, and August.  
  - **Average Monthly Requests**: ~478,659 requests/year.  
- **Daily Trends**:  
  - **Highest Volume**: Midweek (Tuesday–Thursday).  
  - **Lowest Volume**: Weekends (Saturday/Sunday).  
- **Seasonal Trends**:  
  - **Summer** (29.4% of total requests), **Spring** (25.3%), **Fall** (23.5%), **Winter** (21.9%).  
  - **Top Seasonal Services**:  
    - Winter: Roads & Bylaw Snow/Ice Control.  
    - Summer: Property Tax Inquiries.  

### 🚧 **Service Request Trends**
- **Most Frequent Services**:  
  1. **Cart Management** (1M+ requests).  
  2. **Property Tax Account Inquiries** (~590K requests).  
  3. **Roadway Maintenance** (~580K requests).  
- **Resolution Metrics**:  
  - **97%** of requests were marked "Closed".  
  - **8%** took >30 days to resolve (*unresolved*).  
  - **Longest Delays**: *FAC Inspections* and *Major Transit Projects* averaged **500+ days** for resolution.  

### 🌍 **Geographical Analysis**
- **Hotspot Communities**:  
  1. **Downtown Commercial Core** (3,925 recurring requests).  
  2. **Beltline** (3,826).  
  3. **Bowness** (3,222).  
- **Recurring Issues by Location**:  
  - *Roads - Parking Signs* in **Beltline** (38 cases/year).  
  - *Roads - Traffic Markings* in **Silverado** (31 cases/year).  

### ⚙️ **Service Efficiency Analysis**
- **Top Agencies by Volume**:  
  1. **Calgary Community Standards** (16.3% of requests).  
  2. **Roads Department** (15%).  
  3. **Building Services** (13.6%).  
- **Slowest Response Times**:  
  - **PD - Emergency Response**: ~100+ days average.  
  - **TRAN - Green Line**: ~90+ days average.  
- **Fastest Resolution**:  
  - **Waste & Recycling Services**: ~7 days average.  

---

## 📁 SQL Files

### 1. `311_services_requests_calgary - data_cleaning.sql`
- **Purpose**: Clean raw data for analysis.  
- **Output**: `service_requests_clean_v3.csv` (6.2M rows, 13 columns).  

### 2. `311_services_requests_calgary - data_exploration.sql`
- **Purpose**: Perform detailed analysis of trends and efficiency.  
- **Key Queries**:  
  - Temporal trends by month, day, and season.  
  - Service type frequency and resolution times.  
  - Geographical hotspots and recurring issues.  
  - Agency performance metrics.  

---
## 📈 Key Insights
1. Seasonality Matters: Summer and spring require additional staffing for high-demand services like Cart Management.

2. Geographical Hotspots: Downtown and Beltline need proactive resource allocation.

3. Efficiency Gaps: Agencies like Emergency Response require process optimization to reduce 100+ day response times.
---

## ⚙️ How to Use the Code

### 1️⃣ Set Up MySQL
1. Install **MySQL Server 8.0+**.  
2. Create a database named `311_service_requests`.  

### 2️⃣ Run the SQL Files
1. Execute `data_cleaning.sql` to clean the raw data.  
2. Run `data_exploration.sql` to reproduce the analysis.  

### 3️⃣ Outputs
- Cleaned data: `service_requests_clean_v3.csv`.  
- Key insights are embedded in SQL comments and result sets.  




---

## 📦 Dependencies
- **MySQL Server 8.0+**.  
- **MySQL Workbench** (recommended for query execution).  

---

**Happy Analyzing!** 🚀




---





