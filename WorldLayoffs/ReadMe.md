# World Layoffs Analysis Project

## Overview
This project analyzes global layoff data to uncover trends in workforce reductions across companies, industries, and countries. The dataset is cleaned, standardized, and optimized for analytical queries to answer questions like:
- Which companies/industries had the most layoffs?
- How do layoffs vary by year or country?
- What is the cumulative impact over time?

---

## Database Schema
### Tables
1. **`layoffs` (Raw Data)**
   - Initially imported from CSV (structure inferred from cleaning steps)
   - Columns: `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_millions`

2. **`layoffs_clean_v2` (Cleaned Data)**
   - Final cleaned version after data processing
   - Columns: Same as above, with:
     - Standardized formats (e.g., dates as `DATE` type)
     - Removed duplicates and NULLs
     - Validated industry/country names

---

## Key Features
### Data Cleaning Steps
1. **Duplicate Removal**  
   Used `ROW_NUMBER()` to identify and delete exact duplicates across all columns.

2. **Standardization**  
   - Trimmed whitespace from `company` names  
   - Consolidated variations (e.g., "Crypto", "CryptoCurrency" → "Crypto")  
   - Formatted `date` as `YYYY-MM-DD`  
   - Normalized country names (e.g., "United States%" → "United States")

3. **Handling Missing Data**  
   - Replaced blank `industry` values with `NULL`  
   - Filled missing `industry` values using non-NULL entries from the same company  
   - Removed rows with both `total_laid_off` and `percentage_laid_off` as `NULL`

---

## Example Queries
### 1. Top 5 Companies by Layoffs (All Time)
```sql
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 5;
```

### 2. Layoffs by Industry
```sql
SELECT industry, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY industry
ORDER BY total_laid_off DESC;
```

### 3. Yearly Layoff Trends
```sql
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_clean_v2
GROUP BY YEAR(date)
ORDER BY year DESC;
```

### 4. Rolling Cumulative Layoffs (By Month)
```sql
WITH Rolling_Total AS (
  SELECT 
    SUBSTRING(date, 1, 7) AS year_month,
    SUM(total_laid_off) AS monthly_total
  FROM layoffs_clean_v2
  GROUP BY year_month
)
SELECT 
  year_month,
  monthly_total,
  SUM(monthly_total) OVER (ORDER BY year_month) AS cumulative_total
FROM Rolling_Total;
```