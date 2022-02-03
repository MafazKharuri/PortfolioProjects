Select *
From [Portfolio Project 1]..[CovidDeaths]
where continent is not null
order by 3,4

Select *
From [Portfolio Project 1]..[CovidVaccinations]
order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project 1]..[CovidDeaths]
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project 1]..[CovidDeaths]
Where location = 'United States'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid


Select Location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From [Portfolio Project 1]..[CovidDeaths]
Where location = 'United States'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as PercentPopulationInfected
From [Portfolio Project 1]..[CovidDeaths]
--Where location = 'United States'
Group by Location, Population
order by 4 desc

--Showing Countries with Highest Death Count per Population

Select Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1]..[CovidDeaths]
--Where location = 'United States'
where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1]..[CovidDeaths]
--Where location = 'United States'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1]..[CovidDeaths]
--Where location = 'United States'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From [Portfolio Project 1]..[CovidDeaths]
--Where location = 'United States'
Where continent is not null
Group by date
order by 1,2 

--GLOBAL NUMBERS total

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From [Portfolio Project 1]..[CovidDeaths]
--Where location = 'United States'
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3

  --USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as 
 (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   --where dea.continent is not null
   --order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From [Portfolio Project 1]..CovidDeaths dea
Join [Portfolio Project 1]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   --order by 2,3

Select *
From PercentPopulationVaccinated