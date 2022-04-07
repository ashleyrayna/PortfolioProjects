Select * 
From portfolioproject..CovidDeaths
Order by 3,4

Select * 
From portfolioproject..CovidVaccinations
Order by 3,4

Select Location, Date, total_cases, new_cases, total_deaths, Population
From portfolioproject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in the United States
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where Location like '%states%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted COVID
Select Location, Date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From portfolioproject..CovidDeaths
Where Location like '%states%'
Order by 1,2

-- Showing Countries with Highest Infection Rate compared to Population
Select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From portfolioproject..CovidDeaths
Group by Location, Population
Order by PercentPopulationInfected desc	

--Showing Continents with Highest Death Count
Select Continent, Max(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
Where Continent is not null	
Group by Continent
Order by TotalDeathCount desc

-- Showing Countries with Highest Death Count per Population
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From portfolioproject..CovidDeaths
Where Continent is not null	
Group by Location
Order by TotalDeathCount desc	

--Global COVID Death Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where Continent is not null
Order by 1,2

--Global COVID Death Percentage by Date
Select Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From portfolioproject..CovidDeaths
Where Continent is not null
Group by Date
Order by 1,2


--COVID Vaccination Data
--Looking at Total Population vs New Vaccinations Per Day
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE, Rolling Count of New Vaccinations by Location
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
)
Select *
From PopvsVac

--Rolling Percentage of New Vaccinations by Location
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date)
From portfolioproject..CovidDeaths dea
Join portfolioproject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


