select * from PortfolioProject..CovidDeaths;

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

   --alter table PortfolioProject..CovidDeaths 
   --  alter column total_cases nvarchar(200);


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4;


-- Select Data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%' and continent is not null
order by 1,2;

-- Looking at Total Deaths vs Population
-- Shows what percentage of population got covid

select location, date,population,  total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%India%' and continent is not null
order by 1,2;


-- Looking at countries with Highest Infection Rate compared to Population
Select location, population , max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc;

-- Showing countries with Highest Death Count per Population

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Showing the continents with the highest death count per population

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(new_deaths)/ nullif( sum(new_cases),0))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
-- group by date
order by 1,2;

select *
from PortfolioProject..CovidVaccinations;

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date;

-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as bigint))
over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
( 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac;

-- TEMP TABLE
drop table if exists #PercentPopulationVaccinated

create table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null


select * from #PercentPopulationVaccinated;

-- creating view to store data for later visualizations
drop view if exists PercentPopulationVaccinated
go
create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *
from PercentPopulationVaccinated;














--select location,  sum(total_cases), sum(total_deaths)
--from PortfolioProject..CovidDeaths
--group by location;