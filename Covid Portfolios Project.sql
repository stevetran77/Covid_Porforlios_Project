-- Show all infor related to Covid_Deaths table
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4 

-- Select Data that we are going to be using
Select  Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Change the data type of column Total Deaths to numberic
ALTER TABLE PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths INT

-- Looking at Total Deaths vs Total Cases in Vietnam
Select  Location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPercentage
From PortfolioProject..CovidDeaths
where Location = 'Vietnam' and continent is not null
order by 1,2

--Looking at Total Cases vs Population in Vietnam
Select Location, date,total_cases, population, ((total_cases/population)*100) as CasesPercentage
From PortfolioProject..CovidDeaths
Where Location ='Vietnam' and continent is not null
Order by 1,2

-- Looking at Countries with the highest infection Rate compared to population

Select Location, Population, Max(total_cases) as Highest_infection_country, max((total_cases/population))*100 as Percentage_Country_Infected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by 4 desc

-- Looking at Countries with the highest Death Count per Population

Select Location, Population, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
Order by 3 desc

-- Let's break things down by continent

Select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc

-- Showing continent with the highest death cout per population

Select continent, Max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by 2 desc

--Global number
Select SUM(new_cases) as Total_cases, SUM(new_deaths) as Total_deaths, SUM(new_deaths) / sum(new_cases) * 100 as Death_percentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

-- JOIN 2 tables Covid Death and Covid Vaccination together

Select *
From PortfolioProject..CovidDeaths de
Join PortfolioProject..CovidVaccination vac
	ON de.location = vac.location
	AND	de.date = vac.date

-- Looking at the Total Population vs Vaccinations

Select de.continent, de.location, de.date, de.population, vac.new_vaccinations
	, sum(CONVERT(int,vac.new_vaccinations)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths de
Join PortfolioProject..CovidVaccination vac
	ON de.location = vac.location
	AND	de.date = vac.date
Where de.continent is not null 
Order by 2,3

--USE CTE
With PopvsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select de.continent, de.location, de.date, de.population, vac.new_vaccinations
	, sum(CONVERT(int,vac.new_vaccinations)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
From PortfolioProject..CovidDeaths de
Join PortfolioProject..CovidVaccination vac
	ON de.location = vac.location
	AND	de.date = vac.date
Where de.continent is not null 
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select de.continent, de.location, de.date, de.population, vac.new_vaccinations
	, sum(CONVERT(int,vac.new_vaccinations)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
From PortfolioProject..CovidDeaths de
Join PortfolioProject..CovidVaccination vac
	ON de.location = vac.location
	AND	de.date = vac.date
--Where de.continent is not null 
-- Order by 2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

--Creating View to Store data for later visualizations
Create View PercentPopulationVaccinated as
Select de.continent, de.location, de.date, de.population, vac.new_vaccinations
	, sum(CONVERT(int,vac.new_vaccinations)) over (partition by de.location order by de.location, de.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population) * 100
From PortfolioProject..CovidDeaths de
Join PortfolioProject..CovidVaccination vac
	ON de.location = vac.location
	AND	de.date = vac.date
Where de.continent is not null 
--Order by 2,3
