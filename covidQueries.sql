SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4


-- select data which will be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at the Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,  cast(total_deaths as int) / cast(total_cases as int)*100 AS death_rate
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2

-- Looking at the Total Cases VS Population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like '%united kingdom%'
AND continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing countries with highest death count

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Showing continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers

SELECT SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at the Total Population VS Vaccinations
-- USE CTE

WITH PopvsVac(Continnent, location, date, population, new_vaccinations, cumulative_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
CAST(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS bigint) AS cumulative_vaccinations
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..TotalVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (cumulative_vaccinations/population)*100 AS Vacinated_Rate
FROM PopvsVac


-- TEMP TABLE

create table #PercentPopulationVaccinated
(
    continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_vaccinations numeric,
    cumulative_vaccinations numeric
)

;WITH PopvsVac(continent, location, date, population, new_vaccinations, cumulative_vaccinations)
AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    CAST(SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS bigint) AS cumulative_vaccinations
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..TotalVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    WHERE dea.continent is not null
)
INSERT INTO #PercentPopulationVaccinated
SELECT *
FROM PopvsVac;

SELECT *, (cumulative_vaccinations/population)*100 AS Vacinated_Rate
FROM #PercentPopulationVaccinated

