
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