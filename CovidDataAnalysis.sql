Select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVacine
--order by 3,4

-- Select data that we are using

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases VS total deaths
-- Shows likelyhood of dying if infected w/ COVID
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecent
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at total cases VS population
-- Shows % of population that got COIVD
Select location, date, population, total_cases, (total_cases/population)*100 as CasePercent
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfecCount, MAX((total_cases/population))*100 as CasePopPercent
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by 4 desc

-- Showing countries w/ highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc


-- By continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at total pop vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PopvsVac

-- Temp table

DROP table if exists #PercentPopVaccinated
Create Table #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacine vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopVaccinated

-- Creating view for tableau 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacine vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
