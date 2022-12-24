USE portfolioProject1;

SELECT * 
FROM covidDeaths
ORDER BY 3,4;

SELECT * 
FROM covidVaccinations
ORDER BY 3,4;

--TOTAL DEATHS VS TOTAL CASES

 SELECT location, date, total_cases, total_deaths
 FROM covidDeaths
 ORDER BY 1,2;

 
 --PERCENTAGE OF DYING BY COVID BY COUNTRY

 SELECT location, date, total_cases, total_deaths, 
 (total_deaths/total_cases)*100 AS CovidDeathPercentage
 FROM covidDeaths;

--In India
 SELECT location, date, total_cases, total_deaths, 
 (total_deaths/total_cases)*100 AS CovidDeathPercentage
 FROM covidDeaths
 WHERE location='India'
 ORDER BY 1,2;


--COUNTRIES WITH THE HIGHEST INFECTION RATES PER POPULATION
SELECT TOP 20 location, 
(MAX(total_cases)/MAX(population))*100 as Infection_Rate
FROM covidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY Infection_Rate desc;

SELECT TOP 20 location, MAX(total_cases) AS Max_Cases
FROM covidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY Max_Cases desc;

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(total_deaths) as total_deaths, 
MAX(total_deaths/population)*100 as Death_Rate
FROM covidDeaths
GROUP BY LOCATION
ORDER BY Death_Rate desc;

-- GLOBAL NUMBERS

--THE TOTAL CASES, TOTAL DEATHS BY DATES

SELECT coviddeaths.date, 
SUM(total_cases+new_cases) as total_cases,
SUM(CAST(total_deaths AS int) + CAST(new_deaths AS int)) as total_deaths
FROM covidDeaths
WHERE continent is not null
GROUP BY coviddeaths.date
ORDER BY 1;


--NEW CASES BY DATES, NEW TOTAL DEATHS
SELECT date,
SUM(new_cases) as cases_per_day,
SUM(CAST(new_deaths as int)) as deaths_per_day,
SUM(new_cases)/SUM(CAST(new_deaths AS int)) as deathspercentage_per_day
FROM coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- OVERALL
SELECT location,
SUM(new_cases) AS TotalCases,
SUM(CAST(new_deaths as int)) as TotalDeaths,
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM covidDeaths
WHERE total_cases>5000 AND continent is not null 
GROUP BY location
ORDER BY DeathPercentage desc;


--COUNTRIES BY TOTAL DEATHS
SELECT location, MAX(total_cases) as total_covid_cases
FROM covidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_covid_cases desc;

-- Rolling Vaccinations
SELECT cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   SUM(CAST(cv.new_vaccinations as bigint)) 
	   OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM covidDeaths cd
INNER JOIN covidVaccinations cv
ON cd.location=cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY cd.location;


--Rolling Vaccinations using CTE
with PopvsVac (Continent, Location, Date, population, New_Vaccinations, RollingPeopleVaccinated)
as
	(
	SELECT cd.continent,
	   cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations,
	   SUM(CAST(cv.new_vaccinations as bigint)) 
	   OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
		FROM covidDeaths cd
		INNER JOIN covidVaccinations cv
		ON cd.location=cv.location
		AND cd.date = cv.date
		WHERE cd.continent is not null
	)

SELECT *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

--###### CREATING VIEWS OF ALL THE TABLES FOR LATER VISUALISATIONS#######

--PERCENTAGE OF DYING BY COVID BY COUNTRY
CREATE VIEW death_percentage_by_date AS
SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS CovidDeathPercentage
FROM covidDeaths;


--COUNTRIES WITH THE HIGHEST INFECTION RATES PER POPULATION
CREATE VIEW infection_rates AS
SELECT TOP 20 location, 
(MAX(total_cases)/MAX(population))*100 as Infection_Rate
FROM covidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY Infection_Rate desc;

--COUNTRIES WITH MAX NUMBER OF CASES
CREATE VIEW max_cases AS
SELECT TOP 20 location, MAX(total_cases) AS Max_Cases
FROM covidDeaths
WHERE continent is not Null
GROUP BY location
ORDER BY Max_Cases desc;

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
CREATE VIEW deathcount_per_population AS
SELECT location, MAX(total_deaths) as total_deaths, 
MAX(total_deaths/population)*100 as Death_Rate
FROM covidDeaths
GROUP BY LOCATION

-- GLOBAL NUMBERS

--THE TOTAL CASES, TOTAL DEATHS & DEATH PERCENTAGE 
CREATE VIEW global_numbers AS
SELECT
SUM(CAST(new_cases AS float )) as total_cases,
SUM(CAST(new_deaths AS float)) as total_deaths,
SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 as death_percentage
FROM covidDeaths
WHERE continent is not null;



--NEW CASES BY DATES, NEW TOTAL DEATHS
CREATE VIEW deaths_per_day AS
SELECT date,
SUM(new_cases) as cases_per_day,
SUM(CAST(new_deaths as int)) as deaths_per_day,
SUM(new_cases)/SUM(CAST(new_deaths AS int)) as deathspercentage_per_day
FROM coviddeaths
WHERE continent is not null
GROUP BY date;

--contintent
CREATE VIEW continent_deaths AS
SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent;


SELECT cd.location,
	   cd.date,
	   cd.population,
	   cv.new_vaccinations
	--,SUM(CAST(cv.new_vaccinations as bigint)) 
	 --OVER (PARTITION BY cd.location ORDER BY cd.location,cd.date) AS RollingPeopleVaccinated
FROM covidDeaths cd
INNER JOIN covidVaccinations cv
ON cd.location=cv.location
AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY cd.location;




