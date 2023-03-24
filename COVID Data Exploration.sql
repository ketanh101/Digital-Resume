
SELECT *
FROM project .. CovidDeaths$
ORDER by 3,4

-- Select data
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project..CovidDeaths$
ORDER BY 1,2

-- Change data types
ALTER TABLE dbo.CovidDeaths$
ALTER COLUMN total_cases bigint;

ALTER TABLE dbo.CovidDeaths$
ALTER COLUMN total_deaths bigint;


---- Looking at Total Cases vs Total Deaths
-- Shows likelihood of death if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM project..CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

---- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as Percent_Population_Infected
FROM project..CovidDeaths$
WHERE continent is not null
--WHERE location like '%states%'
ORDER BY 1,2

---- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM project..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY Percent_Population_Infected desc

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM project..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY Total_Death_Count desc


-- Showing Continents with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM project..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage
FROM project..CovidDeaths$
WHERE continent is not null 
AND new_cases != 0
--AND location like '%states%'
--GROUP BY date
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
as RollingPeopleVaccinated
--, RollingPeopleVaccinated
FROM project..CovidDeaths$ dea
JOIN project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- TEMP TABLE --------------------------------------------------------------

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_Vaccinations bigint,
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
as RollingPeopleVaccinated
--, RollingPeopleVaccinated
FROM project..CovidDeaths$ dea
JOIN project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3


Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--------------------------------------------------------------------

-- Creating View to store data for later visualizations
CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) 
as RollingPeopleVaccinated
--, RollingPeopleVaccinated
FROM project..CovidDeaths$ dea
JOIN project..CovidVaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

Select *
FROM PercentPopulationVaccinated