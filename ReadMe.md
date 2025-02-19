# Data Analysis Portfolio 🚀

A collection of SQL and data analysis projects showcasing skills in data cleaning, exploration, and visualization. This repository serves as a portfolio to demonstrate proficiency in deriving insights from raw datasets.

---

## 📋 Project Overview
This repository contains multiple data analysis projects, each focusing on different datasets and analytical techniques. Key highlights include:
- **Data Cleaning**: Standardization, deduplication, and handling missing values.
- **Exploratory Data Analysis (EDA)**: Trend identification, aggregation, and statistical summaries.
- **Advanced Queries**: Window functions, CTEs, and time-series analysis.
- **Visualizations**: Results formatted for dashboards or reporting.

---

## 🛠️ Key Features
### 1. **Analyses Included**
| Project Name               | Description                                                                              | Tools Used          |
|----------------------------|------------------------------------------------------------------------------------------|---------------------|
| WorldLayoffs               | Analysis of global layoffs trends (Example: companies, industries, countries).           | MySQL               |
| UnicornCompanies           | Analysis per industry, country and funding of unicorn companies.                         | MySQL               |
| 311ServiceRequestsCalgary  | Temporal, Service Type Analyses and Geographical Distribution Visualization (n Progress) | Excel, MySQL         |

### 2. **Core Techniques**
- **Data Cleaning**: 
  - Deduplication using `ROW_NUMBER()` and CTEs.
  - Standardization of categorical values (e.g., industries, countries).
  - Date formatting and NULL handling.
- **Aggregation**: 
  - `SUM()`, `AVG()`, and window functions (`OVER()`, `PARTITION BY`).
  - Rolling totals and cumulative metrics.
- **Ranking**: 
  - `DENSE_RANK()` for top-N queries (e.g., "Top 5 Companies by Layoffs").

---

## 🚀 Setup Instructions
1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/GYahia/MySQL.git

2. **Database Setup**: 
- Import datasets into MySQL using Workbench or CLI:
    ```sql
    CREATE DATABASE [database_name];
    USE [database_name];
    -- Import CSV via MySQL Workbench's Table Data Import Wizard.
    ```

3. **Run Queries**:  
- Execute SQL scripts (e.g., world_layoffs.sql) to replicate cleaning and analysis steps.

## 📊 Example Queries
1. **Top 5 Industries by Layoffs (SQL)**  
    ```sql
    SELECT industry, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_clean_v2
    GROUP BY industry
    ORDER BY total_laid_off DESC
    LIMIT 5;
    ```

3. **Yearly Layoff Trends**
    ```sql
    SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_clean_v2
    GROUP BY YEAR(date)
    ORDER BY year;
    ```

## 🔧 Future Enhancements
- Add interactive dashboards (e.g., Tableau/Power BI).
- Integrate Python scripts for automated data cleaning.
- Expand analysis to include macroeconomic factors (e.g., GDP, inflation).

---

