-- Active: 1678997493870@@localhost@3306@PortfolioProject
-- Active: 1678997493870@@localhost@3306@PortfolioProject

/* This part of the code is to enable the local data loading mysql  Ver 8.0.32-0ubuntu0.22.04.2 for Linux on x86_64 ((Ubuntu))*/
SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile = true;


-- Dropping tables if already exist in the databasebefore creating them from scratch
DROP TABLE IF EXISTS `CovidDeaths`;
DROP TABLE IF EXISTS `CovidVaccinations`;

/* Creating tables with right variables and loading data from csv files */
Create Table CovidVaccinations
(iso_code	varchar(100)	,
continent	varchar(100)	,
location	varchar(100)	,
date	varchar(100)	,
new_tests	int	,
total_tests	int	,
total_tests_per_thousand	FLOAT	,
new_tests_per_thousand	FLOAT	,
new_tests_smoothed	int	,
new_tests_smoothed_per_thousand	FLOAT	,
positive_rate	FLOAT	,
tests_per_case	FLOAT	,
tests_units	int	,
total_vaccinations	int	,
people_vaccinated	int	,
people_fully_vaccinated	int	,
new_vaccinations	int	,
new_vaccinations_smoothed	int	,
total_vaccinations_per_hundred	FLOAT	,
people_vaccinated_per_hundred	FLOAT	,
people_fully_vaccinated_per_hundred	FLOAT	,
new_vaccinations_smoothed_per_million	FLOAT	,
stringency_index	int	,
population_density	FLOAT	,
median_age	FLOAT	,
aged_65_older	int	,
aged_70_older	int	,
gdp_per_capita	FLOAT	,
extreme_poverty	int	,
cardiovasc_death_rate	FLOAT	,
diabetes_prevalence	FLOAT	,
female_smokers	FLOAT	,
male_smokers	FLOAT	,
handwashing_facilities	int	,
hospital_beds_per_thousand	FLOAT	,
life_expectancy	FLOAT	,
human_development_index	FLOAT);



CREATE TABLE CovidDeaths
(iso_code	varchar(100)	,
continent	varchar(100)	,
location	varchar(100)	,
date	varchar(100)	,
total_cases	int	,
new_cases	int	,
new_cases_smoothed	int	,
total_deaths int,
new_deaths	int	,
new_deaths_smoothed	int	,
total_cases_per_million	FLOAT	,
new_cases_per_million	FLOAT	,
new_cases_smoothed_per_million	FLOAT	,
total_deaths_per_million	FLOAT	,
new_deaths_per_million	FLOAT	,
new_deaths_smoothed_per_million	FLOAT	,
reproduction_rate	FLOAT	,
icu_patients	int	,
icu_patients_per_million	FLOAT	,
hosp_patients	int	,
hosp_patients_per_million	FLOAT	,
weekly_icu_admissions	int	,
weekly_icu_admissions_per_million	FLOAT	,
weekly_hosp_admissions	int	,
weekly_hosp_admissions_per_million	FLOAT	,
new_tests	int	,
total_tests	int	,
total_tests_per_thousand	FLOAT	,
new_tests_per_thousand	FLOAT	,
new_tests_smoothed	int	,
new_tests_smoothed_per_thousand	FLOAT	,
positive_rate	FLOAT	,
tests_per_case	FLOAT	,
tests_units	int	,
total_vaccinations	int	,
people_vaccinated	int	,
people_fully_vaccinated	int	,
new_vaccinations	int	,
new_vaccinations_smoothed	int	,
total_vaccinations_per_hundred	FLOAT	,
people_vaccinated_per_hundred	FLOAT	,
people_fully_vaccinated_per_hundred	FLOAT	,
new_vaccinations_smoothed_per_million	FLOAT	,
stringency_index	int	,
population	int	,
population_density	FLOAT	,
median_age	FLOAT	,
aged_65_older	int	,
aged_70_older	int	,
gdp_per_capita	FLOAT	,
extreme_poverty	int	,
cardiovasc_death_rate	FLOAT	,
diabetes_prevalence	FLOAT	,
female_smokers 	FLOAT	,
male_smokers	FLOAT	,
handwashing_facilities	int	,
hospital_beds_per_thousand	FLOAT	,
life_expectancy	FLOAT	,
human_development_index	FLOAT);


LOAD DATA LOCAL INFILE '/home/gyahia/Desktop/BootCamp/CovidVaccinations.csv'
INTO TABLE CovidVaccinations
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@iso_code,	@continent,	@location,	@date,	@new_tests,	@total_tests,	@total_tests_per_thousand,	@new_tests_per_thousand,	@new_tests_smoothed,	@new_tests_smoothed_per_thousand,	@positive_rate,	@tests_per_case,	@tests_units,	@total_vaccinations,	@people_vaccinated,	@people_fully_vaccinated,	@new_vaccinations,	@new_vaccinations_smoothed,	@total_vaccinations_per_hundred,	@people_vaccinated_per_hundred,	@people_fully_vaccinated_per_hundred,	@new_vaccinations_smoothed_per_million,	@stringency_index,	@population_density,	@median_age,	@aged_65_older,	@aged_70_older,	@gdp_per_capita,	@extreme_poverty,	@cardiovasc_death_rate,	@diabetes_prevalence,	@female_smokers,	@male_smokers,	@handwashing_facilities,	@hospital_beds_per_thousand,	@life_expectancy,	@human_development_index)
SET 
iso_code=NULLIF(@iso_code,''),
continent=NULLIF(@continent,''),
location=NULLIF(@location,''),
date=NULLIF(@date,''),
new_tests=NULLIF(@new_tests,''),
total_tests=NULLIF(@total_tests,''),
total_tests_per_thousand=NULLIF(@total_tests_per_thousand,''),
new_tests_per_thousand=NULLIF(@new_tests_per_thousand,''),
new_tests_smoothed=NULLIF(@new_tests_smoothed,''),
new_tests_smoothed_per_thousand=NULLIF(@new_tests_smoothed_per_thousand,''),
positive_rate=NULLIF(@positive_rate,''),
tests_per_case=NULLIF(@tests_per_case,''),
tests_units=NULLIF(@tests_units,''),
total_vaccinations=NULLIF(@total_vaccinations,''),
people_vaccinated=NULLIF(@people_vaccinated,''),
people_fully_vaccinated=NULLIF(@people_fully_vaccinated,''),
new_vaccinations=NULLIF(@new_vaccinations,''),
new_vaccinations_smoothed=NULLIF(@new_vaccinations_smoothed,''),
total_vaccinations_per_hundred=NULLIF(@total_vaccinations_per_hundred,''),
people_vaccinated_per_hundred=NULLIF(@people_vaccinated_per_hundred,''),
people_fully_vaccinated_per_hundred=NULLIF(@people_fully_vaccinated_per_hundred,''),
new_vaccinations_smoothed_per_million=NULLIF(@new_vaccinations_smoothed_per_million,''),
stringency_index=NULLIF(@stringency_index,''),
population_density=NULLIF(@population_density,''),
median_age=NULLIF(@median_age,''),
aged_65_older=NULLIF(@aged_65_older,''),
aged_70_older=NULLIF(@aged_70_older,''),
gdp_per_capita=NULLIF(@gdp_per_capita,''),
extreme_poverty=NULLIF(@extreme_poverty,''),
cardiovasc_death_rate=NULLIF(@cardiovasc_death_rate,''),
diabetes_prevalence=NULLIF(@diabetes_prevalence,''),
female_smokers=NULLIF(@female_smokers,''),
male_smokers=NULLIF(@male_smokers,''),
handwashing_facilities=NULLIF(@handwashing_facilities,''),
hospital_beds_per_thousand=NULLIF(@hospital_beds_per_thousand,''),
life_expectancy=NULLIF(@life_expectancy,''),
human_development_index=NULLIF(@human_development_index,'')
;





LOAD DATA LOCAL INFILE '/home/gyahia/Desktop/BootCamp/CovidDeaths.csv'
INTO TABLE CovidDeaths
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@iso_code,@continent,	@location,@date,@total_cases,@new_cases,@new_cases_smoothed,@total_deaths,@new_deaths,@new_deaths_smoothed,	@total_cases_per_million,@new_cases_per_million,	@new_cases_smoothed_per_million,	@total_deaths_per_million,	@new_deaths_per_million,	@new_deaths_smoothed_per_million,	@reproduction_rate,	@icu_patients,	@icu_patients_per_million,	@hosp_patients,	@hosp_patients_per_million,	@weekly_icu_admissions,	@weekly_icu_admissions_per_million,	@weekly_hosp_admissions,	@weekly_hosp_admissions_per_million,	@new_tests,	@total_tests,	@total_tests_per_thousand,	@new_tests_per_thousand,	@new_tests_smoothed,	@new_tests_smoothed_per_thousand,	@positive_rate,	@tests_per_case,	@tests_units,	@total_vaccinations,	@people_vaccinated,	@people_fully_vaccinated,	@new_vaccinations,	@new_vaccinations_smoothed,	@total_vaccinations_per_hundred,	@people_vaccinated_per_hundred,	@people_fully_vaccinated_per_hundred,	@new_vaccinations_smoothed_per_million,	@stringency_index,	@population,	@population_density,	@median_age,	@aged_65_older,	@aged_70_older,	@gdp_per_capita,	@extreme_poverty,	@cardiovasc_death_rate,	@diabetes_prevalence,	@female_smokers,	@male_smokers,	@handwashing_facilities,	@hospital_beds_per_thousand,	@life_expectancy,	@human_development_index)
SET 
iso_code=NULLIF(@iso_code,''),
continent=NULLIF(@continent,''),
location=NULLIF(@location,''),
date=NULLIF(@date,''),
total_cases=NULLIF(@total_cases,''),
new_cases=NULLIF(@new_cases,''),
new_cases_smoothed=NULLIF(@new_cases_smoothed,''),
total_deaths=NULLIF(@total_deaths,''),
new_deaths=NULLIF(@new_deaths,''),
new_deaths_smoothed=NULLIF(@new_deaths_smoothed,''),
total_cases_per_million=NULLIF(@total_cases_per_million,''),
new_cases_per_million=NULLIF(@new_cases_per_million,''),
new_cases_smoothed_per_million=NULLIF(@new_cases_smoothed_per_million,''),
total_deaths_per_million=NULLIF(@total_deaths_per_million,''),
new_deaths_per_million=NULLIF(@new_deaths_per_million,''),
new_deaths_smoothed_per_million=NULLIF(@new_deaths_smoothed_per_million,''),
reproduction_rate=NULLIF(@reproduction_rate,''),
icu_patients=NULLIF(@icu_patients,''),
icu_patients_per_million=NULLIF(@icu_patients_per_million,''),
hosp_patients=NULLIF(@hosp_patients,''),
hosp_patients_per_million=NULLIF(@hosp_patients_per_million,''),
weekly_icu_admissions=NULLIF(@weekly_icu_admissions,''),
weekly_icu_admissions_per_million=NULLIF(@weekly_icu_admissions_per_million,''),
weekly_hosp_admissions=NULLIF(@weekly_hosp_admissions,''),
weekly_hosp_admissions_per_million=NULLIF(@weekly_hosp_admissions_per_million,''),
new_tests=NULLIF(@new_tests,''),
total_tests=NULLIF(@total_tests,''),
total_tests_per_thousand=NULLIF(@total_tests_per_thousand,''),
new_tests_per_thousand=NULLIF(@new_tests_per_thousand,''),
new_tests_smoothed=NULLIF(@new_tests_smoothed,''),
new_tests_smoothed_per_thousand=NULLIF(@new_tests_smoothed_per_thousand,''),
positive_rate=NULLIF(@positive_rate,''),
tests_per_case=NULLIF(@tests_per_case,''),
tests_units=NULLIF(@tests_units,''),
total_vaccinations=NULLIF(@total_vaccinations,''),
people_vaccinated=NULLIF(@people_vaccinated,''),
people_fully_vaccinated=NULLIF(@people_fully_vaccinated,''),
new_vaccinations=NULLIF(@new_vaccinations,''),
new_vaccinations_smoothed=NULLIF(@new_vaccinations_smoothed,''),
total_vaccinations_per_hundred=NULLIF(@total_vaccinations_per_hundred,''),
people_vaccinated_per_hundred=NULLIF(@people_vaccinated_per_hundred,''),
people_fully_vaccinated_per_hundred=NULLIF(@people_fully_vaccinated_per_hundred,''),
new_vaccinations_smoothed_per_million=NULLIF(@new_vaccinations_smoothed_per_million,''),
stringency_index=NULLIF(@stringency_index,''),
population=NULLIF(@population,''),
population_density=NULLIF(@population_density,''),
median_age=NULLIF(@median_age,''),
aged_65_older=NULLIF(@aged_65_older,''),
aged_70_older=NULLIF(@aged_70_older,''),
gdp_per_capita=NULLIF(@gdp_per_capita,''),
extreme_poverty=NULLIF(@extreme_poverty,''),
cardiovasc_death_rate=NULLIF(@cardiovasc_death_rate,''),
diabetes_prevalence=NULLIF(@diabetes_prevalence,''),
female_smokers=NULLIF(@female_smokers,''),
male_smokers=NULLIF(@male_smokers,''),
handwashing_facilities=NULLIF(@handwashing_facilities,''),
hospital_beds_per_thousand=NULLIF(@hospital_beds_per_thousand,''),
life_expectancy=NULLIF(@life_expectancy,''),
human_development_index=NULLIF(@human_development_index,'')
;


/*OPTIONALLY ENCLOSED BY ''*/
SELECT * FROM `CovidVaccinations` LIMIT 100;

SELECT * FROM `CovidDeaths` LIMIT 100;

SELECT COUNT(iso_code),COUNT(continent) FROM `CovidDeaths`;


SELECT   COUNT(iso_code), COUNT(continent), COUNT(new_tests) FROM `CovidVaccinations`;


Select location,date,total_cases,new_cases,total_deaths, population
FROM `CovidDeaths`;

-- Working on Cases VS Deaths total 

-- Checking likelihood of dying if covid has been contacted (focus on Tunisiaasa country)
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM `CovidDeaths`
WHERE location LIKE '%tun%';


-- Working on Cases VS population total 

Select location,date,total_cases,population,CONCAT((total_cases/population)*100,"%") AS Percent_population_with_covid
FROM `CovidDeaths`
WHERE location LIKE '%tun%';

Select location,date,total_cases,population,CONCAT((total_cases/population)*100,"%") AS Percent_population_with_covid
FROM `CovidDeaths`
WHERE location LIKE '%states%';

-- Highest infection rate vs population
Select location,MAX(total_cases) AS MaxInfectionCount,population,(MAX(total_cases)/population)*100 AS Max_percent_population_with_covid
FROM `CovidDeaths`
GROUP BY location, population
ORDER BY Max_percent_population_with_covid DESC;

-- Highest infection rate vs population for countries with over 100 million people
Select location,MAX(total_cases) AS MaxInfectionCount,population,(MAX(total_cases)/population)*100 AS Max_percent_population_with_covid
FROM `CovidDeaths`
WHERE population > 100000000 AND continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_percent_population_with_covid DESC;

-- Highest death count per country
SELECT location, MAX(total_deaths)
FROM `CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC;

-- Highest death rate per capita
Select location,MAX(total_deaths) AS MaxDeathCount,population,(MAX(total_deaths)/population)*100 AS Max_percent_deaths
FROM `CovidDeaths`
-- WHERE population > 100000000
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Max_percent_deaths DESC;

-- Highest death count per continent
SELECT continent, MAX(total_deaths)
FROM `CovidDeaths`
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY MAX(total_deaths) DESC;

-- this statement above does not give the accurate information, for example the max deaths fornorth america and the USA are exactly the Same
-- will be checking the data per continent using the data coming from locaion = continent name and continent variable is NULL


-- Highest death count per continent (accurate data)
SELECT location, MAX(total_deaths)
FROM `CovidDeaths`
WHERE continent is  NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC;

SELECT location, MAX(total_deaths),population,(MAX(total_deaths)/population)*100
FROM `CovidDeaths`
WHERE continent is  NULL
GROUP BY location,population
--ORDER BY population DESC;
ORDER BY MAX(total_deaths) DESC;

-- Statement above shows that world population is consideredto be asia's population


-- Population by continent
SELECT location,population
FROM `CovidDeaths`
WHERE continent is NULL
GROUP BY location,population;

-- Total population with sum for continents as location
SELECT SUM(pop.population)
FROM    (SELECT location,population
        FROM `CovidDeaths`
        WHERE continent is NULL
        GROUP BY location,population
        ) AS pop
;
-- Total population with sum for continents as location minus EU
SELECT SUM(pop.population)
FROM    (SELECT location,population
        FROM `CovidDeaths`
        WHERE continent is NULL and location<>"European Union"
        GROUP BY location,population
        ) AS pop
;

--WITH SUBQUERY
SELECT location,population, 
   (SELECT SUM(pop.population)
FROM    (SELECT location,population
        FROM `CovidDeaths`
        WHERE continent is NULL and location<>"European Union"
        GROUP BY location,population
        ) AS pop
) AS TotalPop
FROM `CovidDeaths`
WHERE continent is  NULL
GROUP BY location,population
ORDER BY population DESC;

--WITH CTE
WITH totalPopPerCont (location, population)
AS (
    SELECT location, population
    FROM `CovidDeaths`
    WHERE continent is NULL
    GROUP BY location,population
)
SELECT  SUM(population)
FROM totalPopPerCont;


-- Global numbers

-- Converting format of the dates
UPDATE `CovidDeaths`
SET 
    date = str_to_date(date, '%m/%d/%Y');

UPDATE `CovidVaccinations`
SET 
    date = STR_TO_DATE(`date`,'%d/%m/%Y');


-- Total cases and deaths per date globally
SELECT `date`,SUM(new_cases),SUM(new_deaths),(SUM(new_deaths)/SUM(new_cases))*100
FROM `CovidDeaths`
WHERE continent is NOT NULL
GROUP BY `date`
ORDER BY 1,2;

-- Total cases and deaths globally
SELECT SUM(new_cases),SUM(new_deaths),(SUM(new_deaths)/SUM(new_cases))*100
FROM `CovidDeaths`
WHERE continent is NOT NULL
ORDER BY 1,2;


-- Ranking countries by biggest death percentage vs number of cases
SELECT location ,MAX(total_cases) AS max_cases,MAX(total_deaths) AS max_deaths , (MAX(total_deaths)/MAX(total_cases))*100 AS max_percent_death 
FROM `CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_percent_death DESC;

/*------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
        Working on both tables now
--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------*/

SELECT * FROM `CovidDeaths` AS dea
JOIN `CovidDeaths` AS vacc
    ON dea.location = vacc.location
    and dea.`date`=vacc.date;

SELECT dea.continent, dea.location, dea.date ,dea.population,vacc.new_vaccinations
FROM `CovidDeaths` AS dea
JOIN `CovidDeaths` AS vacc
    ON dea.location = vacc.location
    and dea.`date`=vacc.date
Where dea.continent IS NOT NULL AND vacc.new_vaccinations IS NOT NULL
ORDER BY 2,3; 

SELECT dea.continent, dea.location,dea.date ,dea.population, vacc.new_vaccinations, SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date),vacc.total_vaccinations
FROM `CovidDeaths` AS dea
JOIN `CovidDeaths` AS vacc
    ON dea.location = vacc.location
    and dea.`date`=vacc.date
Where dea.continent IS NOT NULL 
GROUP BY dea.location,dea.continent, dea.date ,dea.population, vacc.new_vaccinations,vacc.total_vaccinations
ORDER BY 2,3; 

-- USING A CTE
WITH PopVsVacc (continent, location,date,population, new_vaccinations, RollingVaccinated,total_vaccinations)
AS (
SELECT dea.continent, dea.location,dea.date ,dea.population, vacc.new_vaccinations, 
        SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinated,
        vacc.total_vaccinations
FROM `CovidDeaths` AS dea
JOIN `CovidDeaths` AS vacc
    ON dea.location = vacc.location
    and dea.`date`=vacc.date
Where dea.continent IS NOT NULL 
GROUP BY dea.location,dea.continent, dea.date ,dea.population, vacc.new_vaccinations,vacc.total_vaccinations
ORDER BY 2,3
)
SELECT * , (RollingVaccinated/population)*100
FROM PopVsVacc
WHERE RollingVaccinated is NOT NULL;

-- Rolling number of vaccinatedpeople is not equal to toal vaccinations provided in the data, to be double checked






/*------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------
        CREEATING VIEWS FOR GLOBAL NUMBERS
--------------------------------------------------------------------------------------
------------------------------------------------------------------------------------*/

-- Population by continent
SELECT location,population
FROM `CovidDeaths`
WHERE continent is NULL
GROUP BY location,population;

CREATE VIEW PopulationByContinent AS 
SELECT location,population
FROM `CovidDeaths`
WHERE continent is NULL
GROUP BY location,population;

SELECT * FROM `PopulationByContinent`;

Create VIEW RollingPercentVaccinations AS
WITH PopVsVacc (continent, location,date,population, new_vaccinations, RollingVaccinated,total_vaccinations)
AS (
SELECT dea.continent, dea.location,dea.date ,dea.population, vacc.new_vaccinations, 
        SUM(vacc.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingVaccinated,
        vacc.total_vaccinations
FROM `CovidDeaths` AS dea
JOIN `CovidDeaths` AS vacc
    ON dea.location = vacc.location
    and dea.`date`=vacc.date
Where dea.continent IS NOT NULL 
GROUP BY dea.location,dea.continent, dea.date ,dea.population, vacc.new_vaccinations,vacc.total_vaccinations
ORDER BY 2,3
)
SELECT * , (RollingVaccinated/population)*100
FROM PopVsVacc
WHERE RollingVaccinated is NOT NULL;

SELECT * FROM `RollingPercentVaccinations`;