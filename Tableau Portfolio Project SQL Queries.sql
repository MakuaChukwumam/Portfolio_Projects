/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--SELECT * FROM CovidDeaths;


Select *
From Covid19Project..CovidDeaths
--Where continent is not null 
Where continent is null 
order by 3,4;

UPDATE CovidDeaths 
SET continent = NULL 
WHERE continent = '';

-- Select Data that I am interested in "USING"

Select Location, date, total_cases, new_cases, total_deaths
From Covid19Project..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if one contract covid in Nigeria as at April 2021.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19Project..CovidDeaths
Where location like '%nigeria%'
and continent is not null
order by 1,2 asc;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if one contract covid in the World as at April 2021.

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid19Project..CovidDeaths
Where continent is not null 
order by location, total_cases;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in Nigeria

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Covid19Project..CovidDeaths
Where location like 'nigeria%'
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid in the World.

Select Location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Covid19Project..CovidDeaths
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Covid19Project..CovidDeaths
--Where location like '%nigeria%'
Group by Location, Population
order by PercentPopulationInfected desc;



-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population


Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
--Where location like '%nigeria%'
Where continent is not null 
Group by continent
Order by TotalDeathCount desc


Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Covid19Project..CovidDeaths
--Where location like '%nigeria%'
Where continent is null 
Group by location
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as numeric(18,10))) as total_deaths, (SUM(cast(new_deaths as numeric(18,10)))/SUM(New_Cases)*100) AS DeathPercentage
From Covid19Project..CovidDeaths
--Where location like '%nigeria%'
where continent is not null 
--Group By date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths))/SUM(new_cases)*100  as DeathPercentage
From Covid19Project..CovidDeaths
--Where location like '%nigeria%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

;With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project..CovidDeaths dea
Join Covid19Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;







