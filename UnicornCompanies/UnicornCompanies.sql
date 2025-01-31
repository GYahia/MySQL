SELECT * From `Unicorn_Companies`;




-- Checking NULL VALUES

SELECT *
From `Unicorn_Companies`
WHERE `Company` is NULL OR `Valuation` IS NULL OR `Date Joined` IS NULL OR `Industry` IS NULL OR `City` IS NULL OR `Country` IS NULL OR `Year Founded` IS NULL OR 
`Funding` IS NULL OR `Select Investors` IS NULL;



-- Checking DATA

/* A first glanse at the xlsx file showed 
- Some empty cells for City
- Unknown values for Funding
- Missing information for Select Investors */




SELECT * FROM `Unicorn_Companies`
WHERE `City`="";

Select `Country` , COUNT(*)
FROM `Unicorn_Companies`
WHERE `City`=""
GROUP BY `Country`
ORDER BY COUNT(*) DESC;

/* Missing information regarding cities impact mostly Asian based Companies in Singapore */

Select * FROM `Unicorn_Companies`
WHERE `Funding` NOT LIKE "$%";

/* 12 companies have no information regarding their `Funding`, their valuation isat a maximumof $4B.*/

Select * FROM `Unicorn_Companies`
WHERE `Select Investors` LIKE "n/a";

/* only onecompany laacks information on its investors, also has small valuation comparedto the list*/


-- Valuation and Funding data need to be formatted



SELECT `Valuation`, `Funding`
FROM `Unicorn_Companies`;

SELECT SUBSTRING_INDEX(SUBSTR(Valuation,2),"B",1)
FROM `Unicorn_Companies`;

UPDATE `Unicorn_Companies`
SET `Valuation`= SUBSTRING_INDEX(SUBSTR(Valuation,2),"B",1);

SELECT * FROM `Unicorn_Companies`;

/* For Funding we have two different scenarios (millions and billions) and since some companies have no info at all, we will leave as it is for now*/



/* Check most present categoriesin this list */

SELECT `Industry`,  COUNT(`Company`) AS company_count ,
    ROUND(COUNT(*) *100 /
        (SELECT COUNT(*) FROM `Unicorn_Companies`),2) AS percent_count
FROM `Unicorn_Companies`
GROUP BY `Industry`
ORDER BY company_count DESC ;


/* Fintech and Internet software & services represent more than a third of present companies in this list 
5% of the companies are not categorized and needto bechecked as well.*/



SELECT `Industry`,  COUNT(`Company`) AS company_count , 
    ROUND(COUNT(*) *100 / 
        (SELECT COUNT(*) FROM `Unicorn_Companies`),2) AS percent_count,
    SUM(`Valuation`) AS total_value, Round(SUM(`Valuation`) * 100 / 
        (SELECT SUM(`Valuation`) FROM `Unicorn_Companies`),2)
FROM `Unicorn_Companies`
GROUP BY `Industry`
ORDER BY total_value DESC ;

/* the order of presence for the industries remains the same for the top and have amst same presence in terms of value as it is of company count */

SELECT `Country`,SUM(`Valuation`) AS value_country, ROUND(AVG(`Valuation`),2),COUNT(`Company`) AS number_cie,
    Round(SUM(`Valuation`)*100/(SELECT SUM(`Valuation`)
                            FROM `Unicorn_Companies`),2) AS percent_value
FROM `Unicorn_Companies`
GROUP BY `Country`
ORDER BY value_country DESC;

/* US and China are way higher on the list interms of value of their companies */

SELECT Country, ROUND(AVG(Valuation),2) AS avg_value
FROM `Unicorn_Companies`
GROUP BY `Country`
ORDER BY avg_value DESC
LIMIT 10;


/* Calculating numberofinvestors by company */
SELECT LENGTH(`Select Investors`), LENGTH(REPLACE(`Select Investors`,",","")), `Select Investors`
FROM `Unicorn_Companies`;

SELECT `Company`, LENGTH(`Select Investors`)- LENGTH(REPLACE(`Select Investors`,",",""))+1  AS count_investors
FROM `Unicorn_Companies`;

ALTER TABLE `Unicorn_Companies`
ADD (Count_Investors int);

UPDATE `Unicorn_Companies`
SET `Count_Investors`= LENGTH(`Select Investors`)- LENGTH(REPLACE(`Select Investors`,",",""))+1;

SELECT * 
FROM `Unicorn_Companies`;

SELECT `Count_Investors`, COUNT(*), 
    ROUND(COUNT(*) *100/ (SELECT COUNT(*)
                        FROM `Unicorn_Companies`),2) AS percent
FROM `Unicorn_Companies`
GROUP BY `Count_Investors`
ORDER BY COUNT(*) DESC; 


SELECT 
TABLE_CATALOG,
TABLE_SCHEMA,
TABLE_NAME, 
COLUMN_NAME, 
DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'Unicorn_Companies'; 

SELECT `Company`,`Industry` , CAST(`Valuation` AS SIGNED) AS value_cie, `Country`-- in mysql canot cast as int, https://www.w3schools.com/sql/func_mysql_convert.asp
FROM `Unicorn_Companies`
WHERE CAST(`Valuation` AS SIGNED) >= 20
ORDER BY value_cie DESC  ;

-- Check Age of companies in the list
SELECT `Company`,`Year Founded`,DATE_FORMAT(CURDATE(), '%Y')-`Year Founded` AS age, 
    (SELECT Round(DATE_FORMAT(CURDATE(), '%Y')-AVG(`Year Founded`),0)
     FROM `Unicorn_Companies`)                                          -- AVG age for the list
FROM `Unicorn_Companies`
GROUP BY age, `Company`,`Year Founded`
ORDER BY age ASC;

-- Check time needed to be listed
SELECT `Industry`, Round(AVG(TIMESTAMPDIFF(YEAR,DATE_FORMAT(`Year Founded`,"%Y"), STR_TO_DATE(`Date Joined`,'%Y-%m-%d'))),1) AS avg_age 
FROM `Unicorn_Companies`
GROUP BY `Industry`
ORDER BY avg_age ASC;

WITH company_age(industry,foundation,listing)
AS (
    SELECT `Industry`,STR_TO_DATE(CONCAT(CAST(`Year Founded` AS CHAR),"-01-01"),"%Y-%m-%d") , STR_TO_DATE(`Date Joined`,'%Y-%m-%d') 
    FROM `Unicorn_Companies`
    GROUP BY `Industry`,`Year Founded`, `Date Joined`
)
SELECT industry,Round(AVG(TIMESTAMPDIFF(YEAR,foundation,listing)),0) as diff_list,
    (SELECT Round(AVG(TIMESTAMPDIFF(YEAR,foundation,listing)),0) AS avg_age_global
    FROM company_age)
FROM company_age
GROUP BY industry
ORDER BY diff_list;

/* Conclusion
- More likely to put in place a unicorn company if based in the US or China
- Most promising industries are Fintech, Internet software & services,E-commerce & direct-to-consumer andArtificial intelligence
- To have a $1B company, ivestors are needed since only lessthan 4.5% of them have only 1 investor.
- Companies appearing on the list have an average age of 10 years.
- On average companies that are in the promising industries take less time 
- On average it takes 7 years to get to $1B value
*/





