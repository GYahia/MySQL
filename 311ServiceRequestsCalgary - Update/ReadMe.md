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

> _(This section will be expanded with concrete findings parsed directly from SQL comments once available.)_

### Service Demand Trends
- Yearly request volumes reveal evolving municipal service needs.

### Operational Effectiveness Metrics
- Most service requests do not reoccur within short timeframes, suggesting effective resolution.
- Some service categories show repeated incidents, highlighting potential infrastructure or maintenance gaps.

### Geographic Patterns
- Certain communities experience recurring service issues.
- These insights could guide preventative maintenance and resource allocation.

### Data Quality Insights
- Excluding incomplete years significantly improves analytical reliability.

Overall, the project demonstrates how public operational data can be transformed into actionable insights.

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

**City of Calgary Open Data Portal**  
311 Service Requests Dataset
