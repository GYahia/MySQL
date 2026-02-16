# Calgary 311 Service Requests Analysis (SQL Project)

> **SQL-based analytics project exploring civic service demand, operational efficiency, and recurring issues using City of Calgary 311 data.**

---

## 📌 Project Overview

Cities generate vast amounts of operational data through public service channels such as 311 systems. However, raw service request data alone does not provide actionable insight — it must be cleaned, structured, and analyzed before it can inform operational decisions.

This project analyzes **City of Calgary 311 service request data** using SQL to uncover patterns in civic service demand, operational efficiency, and recurring infrastructure or service issues.

The goal was to transform raw open-data records into a reliable analytical dataset capable of answering practical questions such as:

- 📈 How service request demand changes over time  
- 🛠️ Whether municipal interventions resolve issues effectively  
- 🏘️ Which communities experience recurring service problems  
- 📍 What patterns could inform resource allocation or preventative maintenance  

The dataset was sourced from the **City of Calgary Open Data Portal** and processed entirely using SQL to simulate a realistic analytics engineering workflow.

---

### Why SQL

SQL was chosen because it:

- Efficiently handles structured civic datasets at scale  
- Enables reproducible, auditable transformations  
- Supports complex aggregations and time-based analysis  
- Reflects real-world data warehouse workflows used by analytics and data engineering teams  

---

## 🎯 Objectives & Main Targets

### Primary Goals

- Transform raw civic service request data into an analysis-ready format  
- Identify trends in municipal service demand  
- Measure service effectiveness through recurrence analysis  
- Explore geographic clustering of civic issues  

---

### Key Questions Addressed

- How has the volume of 311 requests evolved over time?  
- Are some service categories prone to repeat incidents?  
- Do certain communities experience recurring infrastructure issues?  
- Are service interventions generally effective within short timeframes?

---

### What Success Looks Like

- Clean, standardized datasets suitable for repeat analysis  
- Reliable analytical queries producing consistent metrics  
- Insights that could inform operational planning or public policy  

---

## 🧠 Approach & Steps Taken

### 1. Database & Schema Creation

A dedicated SQL database (`311_service_requests`) was created to store and analyze the dataset.

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

**Design considerations:**

- Flexible data types to accommodate inconsistent open-data formatting  
- Separate timestamp fields for lifecycle tracking  
- Geographic attributes retained for future spatial analysis  

> **Design philosophy:** reliability first, optimization second.

---

### 2. Data Cleaning & Standardization

Cleaning was intentionally iterative to reflect real-world data engineering practice.

**Key steps included:**

- Duplicate detection using `ROW_NUMBER()` window functions  
- Text normalization and category standardization  
- Timestamp validation and consistency checks  
- Creation of progressively refined cleaned tables  

This ensures analytical results are not distorted by formatting inconsistencies or duplicate records.

---

### 3. Analytical Dataset Preparation

A dedicated analysis table was created to:

- Avoid repeatedly cleaning raw data  
- Improve query performance  
- Support modular analytical exploration  

This mirrors common **staging → analytics mart** patterns in data warehouses.

---

### 4. Exploratory Analytical Modules

#### ⏱️ Temporal Exploration
- Yearly service request trends  
- Removal of incomplete years for statistical accuracy  

#### ⚙️ Efficiency Exploration
- Identification of first occurrences of service requests  
- Detection of reoccurring issues within a 30-day window  
- Measurement of resolution effectiveness  

#### 🗺️ Geographic Exploration
- Community-level clustering of recurring issues  
- Combined service-type and location analysis  

#### 📊 Request Trend Exploration
- Aggregated demand patterns  
- Long-term operational insights  

---

## 🧩 Key SQL Components

### Core Tables

**`service_requests`**  
- Raw ingested dataset  
- Preserves original open-data records  

**`service_requests_clean_v3`**  
- Cleaned, standardized dataset  
- Primary source for analysis  

**`service_requests_analysis`**  
- Analytical dataset optimized for reporting and exploration  

---

### Notable SQL Techniques

**Window Functions**
- Duplicate detection  
- Chronological ordering of service requests  

**Common Table Expressions (CTEs)**
- Modular analytical logic  
- Reoccurrence tracking  

**Temporal Aggregation**
- Year-based trend analysis  
- Exclusion of incomplete years  

**Iterative Data Cleaning**
- Versioned cleaned tables  
- Controlled refinement workflow  

---

## 📈 Results & Insights

The analysis produces practical outputs across **demand trends**, **service efficiency**, and **geographic recurrence hotspots**. Results below are derived directly from the SQL exploration queries and documented query outputs.

### 📌 Dataset Scope & Cleaning Outcomes
- After excluding statistically insignificant / incomplete years (**2010**, **2011**) and partial capture for **2026 (through Jan 16)**, the cleaned dataset contains:
  - **6,672,894** records (`service_requests_clean_v3`)
- Average request volume across the retained years:
  - **~476,635 requests per year** (computed as total requests / distinct years)

---

### 📈 Service Demand Trends (Temporal Patterns)

**Seasonality**
- Requests are strongly seasonal:
  - **Summer: ~30%**
  - **Spring: ~25%**
  - **Fall: ~24%**
  - **Winter: ~21%**

**Monthly spikes**
- **June has the highest volume** (730k+ requests)
- **May–August are consistently the busiest months** (each exceeding 600k total requests across the dataset)

**Day-of-week behavior**
- Weekday demand dominates:
  - **Tue–Thu are busiest** (Tuesday highest at ~1.24M)
  - Weekend demand is lowest:
    - **Saturday ~454k**
    - **Sunday ~399k**

**High-volume years**
- The highest-demand years include **2014, 2018, and 2023**, each surpassing **500k+ requests**
- Only **five years** were above the overall yearly average:  
  **2014, 2017, 2018, 2020, 2023**

---

### ⏱️ Service Responsiveness (Lifecycle / Resolution)

**Overall response time**
- Average time from request to closure:
  - **19+ days** (mean response time)

**Long-duration service categories**
- Some request types show extremely long average closure times (500+ days), including:
  - FAC inspection  
  - Major transit projects  
  - Rapid damage assessment  
  - Traffic / roadmarking inquiry categories  

**Extreme outliers**
- Specific combinations of service and month show unusually high response time averages (2000+ days), such as:
  - Streetlight-related requests in **Downtown** during **February**
  - Traffic camera inquiry in **July**
  - Lane reversal in **August**

**Unresolved >30 days**
- Requests taking longer than 30 days represent about:
  - **~8%** of all requests

**Status distribution**
- **Closed: ~97%**
- **Duplicate Closed: ~2%**
- **Open: ~1%**
- Requests marked **Open** remain open on average:
  - **73+ days**

---

### 🔁 Recurrence & Operational Effectiveness (30-Day Repeat Logic)

To measure whether issues are truly resolved, the analysis defines:

- A **first occurrence** = no matching service at the same point in the previous 30 days  
- A **repeat** = a matching service request appears again at the same point within the next 30 days  

**Citywide recurrence rate**
- Roughly **41%–46%** of first occurrences recur within 30 days, depending on year.
  - Example:
    - **2022: 41.61%**
    - **2020: 45.26%**
    - **2025: 43.10%**

**One-off resolution rate (non-repeating)**
- The share of first occurrences that **do NOT** recur within 30 days is fairly stable:
  - ~**54%–58%** year-over-year
  - Highest observed: **2022 ~58.39%**

**How many “new” issues reoccur quickly**
- Annual counts of first occurrences that repeat within 30 days range from:
  - ~**34k–52k**, peaking in **2023 (51,710)**

---

### 🧭 What Reoccurs Most (Service-Level Insights)

**Top services (overall) by volume of repeating first occurrences**
These services produce the highest number of first occurrences that recur within 30 days:

- Roads – Signs – Missing / Damaged (**7,616**)  
- Roads – Debris on Street/Sidewalk/Boulevard (**7,357**)  
- Corporate – Graffiti Concerns (**7,164**)  
- Roads – Traffic or Pedestrian Light Repair (**7,147**)  
- Roads – Roadway Maintenance (**7,086**)  

**High recurrence-rate services (not just volume)**
Some services have very high recurrence rates (recur / first occurrences), including:

- Bylaw – Snow and Ice on Sidewalk: **~75.78%**
- Roads – Snow and Ice Control: **~69.65%**
- 311 Contact Us: **~66.82%**

> Interpretation: these categories may represent issues that are either ongoing by nature (e.g., winter conditions) or reflect repeated follow-up and reporting patterns.

---

### 🗺️ Geographic Hotspots (Community + Point Patterns)

**Community hotspots (by recurring first occurrences)**
Top communities by count of recurring first occurrences include:
- **Downtown Commercial Core (5,690)**
- **Beltline (5,504)**
- **Bowness (4,958)**
- **Bridgeland/Riverside (4,434)**

Each community contributes roughly **~0.5%–1.0%** of total recurrence volume individually, indicating recurrence is widespread but concentrated in high-activity areas.

**Service + community combinations with strongest recurrence**
Top combinations (first occurrences and recurrence rates):
- Greenview Industrial Park — *WATR Industrial Monitoring Inquiry*: **84.10% recurrence**
- Glendale — *Bylaw Tree/Shrub Infraction*: **81.37%**
- Willow Park — *Bylaw Tree/Shrub Infraction*: **82.67%**
- Auburn Bay / Mahogany — *CFD Operation Birthdays*: **100%** recurrence (small volume but fully repeating)

**Point-level hotspot concentration**
- The analysis identified **571,942** repeating first occurrences (citywide).
- Individual hotspot points can account for thousands of repeats:
  - Top hotspot point: **4,151** repeating first occurrences (~0.73% of total repeats)

> Interpretation: a small number of physical locations generate disproportionate repeat activity — a useful signal for preventive maintenance, targeted inspections, or operational workflow review.

---

### ✅ Why These Results Matter
These findings help bridge operational questions to data-driven insight:

- **Seasonality and weekday demand patterns** support staffing and resource planning  
- **Long closure times and outliers** reveal services that may need process review or better SLA tracking  
- **30-day recurrence metrics** provide a practical proxy for “resolution effectiveness”  
- **Community and point hotspots** help prioritize field work, infrastructure investment, and enforcement operations


---

## 🔮 Future Improvements

### Technical Enhancements
- Add spatial indexing and GIS integration for advanced geographic analysis  
- Implement automated ETL pipelines for continuous data updates  
- Introduce indexing strategies for query performance optimization  
- Normalize categorical fields into dimension tables  

### Visualization & Reporting
- BI dashboard integration (Power BI, Tableau, or Looker)  
- Automated reporting workflows  
- Executive-level summary dashboards  

---

## 📚 Data Source

 
**[Calgary Open Data Portal](https://data.calgary.ca/)**

311 Service Requests Dataset
