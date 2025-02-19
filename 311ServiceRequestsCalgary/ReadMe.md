# 311 Service Requests Data Analysis - Calgary

This project involves the analysis of 311 service requests data for the city of Calgary. The data was downloaded from the [Calgary Open Data Portal](https://data.calgary.ca/) and covers service requests up to **February 10, 2025**.

---

## 📊 Project Overview

The goal of this project is to **clean**, **analyze**, and **prepare** the 311 service requests data for further analysis or visualization. The data contains information about service requests, including:

- Type of service
- The agency responsible
- Status of the request
- Geographical information (longitude and latitude)

### 🔍 Key Steps

1. **Data Import**  
   The raw data was imported from a CSV file into a MySQL database.

2. **Data Cleaning**  
   The data was cleaned to handle missing values, standardize fields, and remove duplicates.

3. **Data Transformation**  
   The cleaned data was further processed to ensure consistency and prepare it for analysis.

4. **Data Export**  
   The final cleaned data was exported to a CSV file for further use.

---

## 📁 SQL Files

### 1. `311_services_requests_calgary - data_creation.sql`

This file contains the SQL code to:

- Create a new database (`311_service_requests`).
- Define the schema for the `service_requests` table.
- Load the data from the CSV file into the `service_requests` table.


Format of the imported table:
| Field Name            | Data Type       |
|-----------------------|----------------|
| service_request_id    | varchar(255)    |
| requested_date        | timestamp       |
| updated_date         | timestamp       |
| closed_date          | timestamp       |
| status_description   | varchar(255)    |
| source              | varchar(255)    |
| service_name         | varchar(255)    |
| agency_responsible   | varchar(255)    |
| address             | varchar(255)    |
| comm_code           | varchar(255)    |
| comm_name           | varchar(255)    |
| location_type       | varchar(255)    |
| longitude           | double          |
| latitude            | double          |
| point              | varchar(255)    |

### 2. `311_services_requests_calgary - data_cleaning.sql`

This file contains the SQL code to:

- Create a clean copy of the raw data table.
- Standardize the `service_name` field to ensure consistent capitalization.
- Handle missing values in `comm_code`, `comm_name`, `longitude`, and `latitude`.
- Remove rows with missing or irrelevant data.
- Export the cleaned data to a new CSV file.

---

## 🧹 Data Cleaning Steps

### 📏 Standardization

- The `service_name` field was standardized to ensure that all entries start with an uppercase letter.
- Missing `comm_code` values were replaced with `comm_name` where applicable.

### 📉 Handling Missing Data

- Rows with missing `comm_code`, `comm_name`, `longitude`, and `latitude` were removed.
- Missing `updated_date` and `closed_date` values were filled in using available data.

### 🗑️ Removing Irrelevant Data

- The `address` column was dropped as it contained no useful information.
- Rows with status descriptions like **"TO BE DELETED"** and **"Duplicate (Open)"** were removed.

### ✅ Final Clean Data

- The final cleaned data was exported to a CSV file: `service_requests_clean_v3.csv` for further analysis.

---

## ⚙️ How to Use the Code

### 1️⃣ Set Up MySQL

- Ensure **MySQL** is installed and running on your machine.
- Create a new database named `311_service_requests`.

### 2️⃣ Run the SQL Files

- Execute the `311_services_requests_calgary - data_creation.sql` file to create the database and import the raw data.
- Execute the `311_services_requests_calgary - data_cleaning.sql` file to clean and transform the data.

### 3️⃣ Export the Cleaned Data

- The final cleaned data will be exported to a CSV file: `service_requests_clean_v3.csv`.

---

## 📈 Data Analysis

The cleaned data can now be used for further analysis, such as:

- Identifying trends in service requests over time.
- Analyzing the most common types of service requests.
- Visualizing the geographical distribution of service requests.

---

## 📦 Dependencies

- **MySQL Server 8.0** or higher.
- **MySQL Workbench** (optional, for easier execution of SQL scripts).

---

**Happy Analyzing!** 🚀

