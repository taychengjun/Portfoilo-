Select * 
From PortfolioE..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioE..CovidVaccination
--order by 3,4 

--Select Data that I am using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioE..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths 

Select Location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioE..CovidDeaths
Where location like 'Singapore'
order by 1,2


--Looking at Total Cases vs Population
--Percentage of population that got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
From PortfolioE..CovidDeaths
Where location like 'Singapore'
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioE..CovidDeaths
--Where location like 'Singapore'
Group by Location, Population
order by PercentPopulationInfected desc


--Looking at Countries with Highest Death Count Per Population 
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioE..CovidDeaths
Where continent is not null
--Where location like 'Singapore'
Group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT

--Showing continent with the highest death count per population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioE..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers 

Select date, Sum(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as TotalDeathCount, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioE..CovidDeaths
where continent is not null 
Group by date
order by 1,2 



--Looking at Total Population Vs Vaccinations 

--USE CTE (To add a current variable you just created)

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioE..CovidDeaths dea 
Join PortfolioE..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100 as PercentageOfPopulationVaccinated
From PopvsVac



--Temp Table

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
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioE..CovidDeaths dea 
Join PortfolioE..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100 as PercentageOfPopulationVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visualization 

Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioE..CovidDeaths dea 
Join PortfolioE..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3