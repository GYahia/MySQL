
# Unicorn Companies Analysis 🦄
Source Link: https://www.mavenanalytics.io/blog/maven-unicorn-challenge

A SQL-based analysis of companies valued at over $1 billion ("unicorns"). This project explores trends in industries, countries, funding, and the time taken to achieve unicorn status.

---

## 📋 Project Overview
**Goal**: Analyze a dataset of unicorn companies to answer:  
- Which industries/countries dominate the unicorn landscape?  
- How many investors do unicorns typically have?  
- How long does it take to become a unicorn?  

**Dataset**: `Unicorn_Companies` table with columns:  
`Company`, `Valuation`, `Date Joined`, `Industry`, `City`, `Country`, `Year Founded`, `Funding`, `Select Investors`.

---

## 🛠️ Key Features
### 1. **Data Cleaning & Preparation**  
- **Handling Missing Values**:  
    Identified and analyzed NULLs/empty cells in `City`, `Funding`, and `Select Investors`.
    ```sql
    SELECT * FROM Unicorn_Companies 
    WHERE City = "" OR Funding NOT LIKE "$%" OR Select Investors LIKE "n/a";
    ```

- **Valuation Standardization**:  
    Converted Valuation (Example: "$4B" → "4") to numeric values.
    ```sql  
    UPDATE Unicorn_Companies
    SET Valuation = SUBSTRING_INDEX(SUBSTR(Valuation,2), "B", 1);
    ```

- **Investor Count**:  
    Added a `Count_Investors` column by counting commas in `Select Investors`.
    ```sql
    ALTER TABLE Unicorn_Companies ADD COLUMN Count_Investors INT;
    UPDATE Unicorn_Companies
    SET Count_Investors = LENGTH(Select Investors) - LENGTH(REPLACE(Select Investors, ",", "")) + 1;
    ```

### 2. **Core Analyses**  
- **Industry Dominance**:  
    Fintech and Internet softwre/services account for 36% of unicorns.
    ```sql
    SELECT Industry, COUNT(Company) AS company_count, 
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM Unicorn_Companies), 2) AS percent_count
    FROM Unicorn_Companies
    GROUP BY Industry
    ORDER BY company_count DESC;
    ```
- **Country Dominance**:  
    The U.S. and China represent 75% of total unicorn valuation.
    ```sql
    SELECT Country, SUM(Valuation) AS total_value
    FROM Unicorn_Companies
    GROUP BY Country
    ORDER BY total_value DESC;
    ```
- **Investor Trends**:  
    75% of unicorns have 3+ investors; only 4.5% have 1 investor.
    ```sql
    SELECT Count_Investors, COUNT(*), 
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM Unicorn_Companies), 2) AS percent
    FROM Unicorn_Companies
    GROUP BY Count_Investors
    ORDER BY COUNT(*) DESC;
    ```
- **Time to Unicorn Status**:  
    Average time to reach $1B valuation: 7 years.
    ```sql
    SELECT Industry, 
    ROUND(AVG(TIMESTAMPDIFF(YEAR, STR_TO_DATE(Year_Founded, "%Y"), Date_Joined)), 0) AS avg_years
    FROM Unicorn_Companies
    GROUP BY Industry
    ORDER BY avg_years ASC;
    ```
---
## 🚀 Setup Instructions
### 1. **Import Data**:

- Create a MySQL database and import the Unicorn_Companies dataset (CSV/Excel).

- Run SQL Script:
Execute the provided UnicornCompanies.sql to:  
    - Clean and standardize data.
    - Add the Count_Investors column.
    - Perform analyses.

## 📊 Key Insights
- **Top Industries**: Fintech, Internet software/services, E-commerce, and AI.

- **Geographic Hotspots**: U.S. and China dominate in total valuation.

- **Investor Influence**: Most unicorns have 3+ investors.

- **Growth Speed**: Average unicorn age is 10 years; takes 7 years to hit $1B.

## 🔧 Future Enhancements
- Integrate external data (e.g., GDP, market trends).

- Build a Tableau/Power BI dashboard for visual trends.

- Analyze funding rounds in-depth.



