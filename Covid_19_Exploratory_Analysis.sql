USE PortfolioProject;

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

DELETE FROM CovidDeaths
WHERE population IS NULL;
DELETE FROM CovidDeaths
WHERE continent IS NULL;

SELECT COUNT(*)
FROM CovidDeaths;

-- Select data that we are going to use
SELECT location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
ORDER BY 1,2;


-- Looking at total cases vs total deaths

SELECT location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Looking at total cases vs population
SELECT location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location,
	population,
	MAX(total_cases) AS infected_count,
	MAX((total_cases/population))*100 AS infected_rate
FROM CovidDeaths
GROUP BY location, population
ORDER BY infected_rate DESC;

-- Showing countries with Highest Death Count per Population
SELECT location,
	MAX(CAST(total_deaths AS int)) AS deaths_count
FROM CovidDeaths
GROUP BY location
ORDER BY deaths_count DESC;

-- Notice: total_deaths is counted by running total, to show total deaths for each continent
-- Huge Notice: It is not allowed to use ORDER BY clause inside CTE, views or subqueries
WITH cte AS (
SELECT continent, 
	location,
	MAX(CAST(total_deaths AS int)) AS deaths_count
FROM CovidDeaths
GROUP BY continent, location)

SELECT continent, SUM(deaths_count) AS total_deaths_count
FROM cte
GROUP BY continent
ORDER BY total_deaths_count DESC;

-- showing continents with the highest death count per population
SELECT continent,
	MAX(CAST(total_deaths AS int)) AS deaths_count
FROM CovidDeaths
GROUP BY continent
ORDER BY deaths_count DESC;

-- Total cases across world on each date
SELECT date, 
	SUM(new_cases) AS global_cases, 
	SUM(CAST(new_deaths AS int)) AS global_deaths, 
	SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS global_death_percentage
FROM CovidDeaths
GROUP BY date
ORDER BY 1;

-- Join two tables together and look at total vaccinated population
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_total_vaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date
ORDER BY 2,3

-- Calcualte running total percentage of global vaccinated people
WITH cte AS (
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_total_vaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date)

SELECT *, running_total_vaccinated/population*100 AS running_total_vaccinated_perc
FROM cte;

-- Another way to do: Temp Table

-- Create View to store data for later visualization
GO
CREATE VIEW  running_total_vaccinatedd_view 
AS
SELECT d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS running_total_vaccinated
FROM CovidDeaths d
JOIN CovidVaccinations v
	ON d.location = v.location
	AND d.date = v.date;
GO;



