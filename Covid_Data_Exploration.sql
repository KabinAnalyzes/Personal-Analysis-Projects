/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
FROM Porfolio_Project_1..CovidDeaths
WHERE continent is NOT null
order by 3,4

--Select Data that we are going to be using

Select Location,
date,
total_cases,
new_cases,
total_deaths,
population
From Porfolio_Project_1..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select 
Location, 
Date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From Porfolio_Project_1..CovidDeaths
WHERE continent is NOT null
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select 
Location, 
Date,
total_cases,
population,
(total_cases/population)*100 as Percent_Contracted 
From Porfolio_Project_1..CovidDeaths
WHERE continent is NOT null
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select 
Location, 
MAX(total_cases) as HighestInfectionCount,
population,
Max((total_cases/population))*100 as 'PercentPopulationInfected'
From Porfolio_Project_1..CovidDeaths
WHERE continent is NOT null
GROUP BY Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
Select 
Location, 
MAX(cast(total_deaths as int)) as TotalDeathCount
From Porfolio_Project_1..CovidDeaths
WHERE continent is NOT null
GROUP BY Location
order by TotalDeathCount desc

--Breaking down by Continent

--Showing continents with the highest death count per population
Select 
location, 
MAX(cast(total_deaths as int)) as TotalDeathCount
From Porfolio_Project_1..CovidDeaths
WHERE continent is null
GROUP BY location
order by TotalDeathCount desc

-- Continents with highest infection rates
Select 
location, 
MAX(total_cases) as HighestInfectionCount,
population,
Max((total_cases/population))*100 as 'PercentPopulationInfected'
From Porfolio_Project_1..CovidDeaths
WHERE continent is null
GROUP BY location, Population
order by PercentPopulationInfected desc

--GLOBAL NUMBERS

--Total Death Percentage Globally
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Porfolio_Project_1..CovidDeaths
where continent is not null 
order by 1,2

--Looking at Total Population vs Vaccinations
-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Vacctionations)
as
(Select dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER (Partition by  dea.location Order by dea.location, dea.date) as Rolling_Vacctionations
FROM Porfolio_Project_1..CovidDeaths dea
JOIN  Porfolio_Project_1..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT null
--order by 2,3
)
Select *, (Rolling_Vacctionations/Population)*100 as PercentVaccinated
FROM PopvsVac

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
From Porfolio_Project_1..CovidDeaths dea
Join Porfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Porfolio_Project_1..CovidDeaths dea
Join Porfolio_Project_1..CovidVaccinations vac
	On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
