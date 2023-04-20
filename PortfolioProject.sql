SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is  NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT DISTINCT Location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION Like '%India%'
AND continent is NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1,2



-- Looking at Total Cases vs Population
-- Shows what percenatge of population got covid

SELECT Location, date, population, total_cases,  (total_deaths/population) * 100 as PercentPopulation
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION Like '%India%'
WHERE continent is NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1,2 


--Looking at Countries with Highest Infection rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected desc

--Showing Countries With Highest Death Count per Population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE loacation like = '%India%'
WHERE continent is  NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


-- Let's Break Things DOWN By CONTINENT

--Showing Contintents with the highest Death Count per population

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE loacation like = '%India%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


--GLOBAL Numbers


SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
    CASE
	WHEN SUM(new_cases) = 0 THEN NULL 
	ELSE (SUM(new_deaths) * 100.0) / SUM(new_cases)
	END AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

-- USEING CTE


With PopvsVac ( continent, Location, date, population, new_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is NOT NULL AND dea.population is NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


--TEMP Table

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_Vaccinations int,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is NOT NULL AND dea.population is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentagePopulationVaccinated


-- Creating view to store data for later Visualisations

CREATE VIEW PercentagePopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(FLOAT,vac.new_vaccinations)) over (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent is NOT NULL AND dea.population is NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentagePopulationVaccinated


CREATE VIEW DeathPercentage As
SELECT DISTINCT Location, date, total_cases, total_deaths, (total_deaths/ total_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE LOCATION Like '%India%'
AND continent is NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
--ORDER BY 1,2

SELECT * 
FROM DeathPercentage

CREATE VIEW PercentPopulation AS
SELECT Location, date, population, total_cases,  (total_deaths/population) * 100 as PercentPopulation
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION Like '%India%'
WHERE continent is NOT NULL AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
--ORDER BY 1,2 

SELECT * 
FROM PercentPopulation

CREATE VIEW PercentPopulationInfected As
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%India%'
GROUP BY Location, population
--ORDER BY PercentPopulationInfected desc

SELECT * 
FROM PercentPopulationInfected


CREATE VIEW LOCTotalDeathCount AS
SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE loacation like = '%India%'
WHERE continent is  NOT NULL
GROUP BY Location
--ORDER BY TotalDeathCount desc

SELECT *
FROM LOCTotalDeathCount


CREATE VIEW CONTITotalDeathCount AS
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE loacation like = '%India%'
WHERE continent is NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount desc

SELECT *
FROM CONTITotalDeathCount