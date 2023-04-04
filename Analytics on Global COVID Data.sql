--LOOKING AT THE COMPLETE DATA FROM THE TABLE [I use order by just to keep it more organized]

select * 
from PortfolioProject..CovidDeaths
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--LOOKING AT THE TOTALCASES PER TOTALDEATHS 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
order by 1,2

--In the United States Specifically
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--LOOKING AT THE TOTALCASES VS THE POPULATION

--This code shows what "%" of population got infected

select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--LOOKING AT THE COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfection
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by 1,2

-- Now ordering the data by Percent of Population Infection 

select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentofPopulationInfection
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentofPopulationInfection desc


--LOOKING AT THE COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc


--LOOKING AT THE CONTINENTS WITH HIGHEST DEATH COUNT 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


--LOOKING AT THE GLOBAL NUMBERS NOW USING AGGREGATE FUNCTIONA

select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths) as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
Group by date
Order by 1,2

--OVERALL DEATH PERCENTAGE ACROSS THE WORLD

select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths) as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group by date
Order by 1,2


-- JOINING TWO TABLES (COVID VACCINATIONS AND DEATHS)

select * 
from
PortfolioProject..CovidDeaths dea
Join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date


--LOOKING AT TOTAL POPULATION VS TOTAL VACCINATIONS DONE

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from
PortfolioProject..CovidDeaths dea
Join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--LOOKING AT THE COUNT OF ROLLING VACCINATIONS 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from
PortfolioProject..CovidDeaths dea
Join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--USAGE OF CTE

with PopvsVac (continent, location, date, population, RollingVaccinations
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccinations
from
PortfolioProject..CovidDeaths dea
Join
PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
)
select *,(RollingVaccinations/Population)*100
from PopvsVac


--USAGE OF TEMP TABLE


Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingVaccinations/Population)*100
From #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR VISUALIZATIONS 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingVaccinations
--, (RollingVaccinations/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 