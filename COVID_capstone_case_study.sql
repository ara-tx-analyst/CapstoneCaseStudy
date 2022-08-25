Select *
From Portfolio_Project..covid_deaths1$
Where continent is not null
Order by 3,4

----Select *
----From Portfolio_Project..covid_vaccinations1$
----Order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..covid_deaths1$
Order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From Portfolio_Project..covid_deaths1$
Where location like '%states%'
Order by 1,2

-- Looking at Total Cases by Population
-- Shows percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as percent_population_infected
From Portfolio_Project..covid_deaths1$
Where location like '%states%'
Order by 1,2

-- Looking at Countries w/ highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
From Portfolio_Project..covid_deaths1$
--Where location like '%states%'
Group by location, population
Order by percent_population_infected desc

-- Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..covid_deaths1$
--Where location like '%states%'
Where continent is not null
Group by location
Order by total_death_count desc

-- NOW ORGANIZING DATA BY CONTINENT
-- North America didnt include Canada when continent is not NULL

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..covid_deaths1$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by total_death_count desc

-- When continent is null, data includes other identifiers and also includes Canada in N. America
-- This will affect visuals.. boo :( thumbs down!

Select location, MAX(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..covid_deaths1$
--Where location like '%states%'
Where continent is null
Group by location
Order by total_death_count desc

-- Showing continents w/ highest death count per population

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From Portfolio_Project..covid_deaths1$
Where continent is not null
Group by continent
Order by total_death_count desc


-- NOW ORGANIZING DATA GLOBALY 

Select date, SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases) *100 as global_death_percentage
From Portfolio_Project..covid_deaths1$
Where continent is not null
Group by date
Order by 1,2


-- Total population vs. vaccinations

select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, Sum(convert(bigint,vac.new_vaccinations)) Over (partition by death.location Order by death.location,
death.date) as rolling_people_vaccinated
--, (rolling_people_vaccinated/population)*100
From Portfolio_Project..covid_deaths1$ death
Join Portfolio_Project..covid_vaccinations1$ vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
Order by 2,3



-- USING CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (partition by death.location Order by death.location,
death.date) as rolling_people_vaccinated
From Portfolio_Project..covid_deaths1$ death
Join Portfolio_Project..covid_vaccinations1$ vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null
)

Select *, (rolling_people_vaccinated/population)*100
From pop_vs_vac



--Using Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert Into #PercentPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (partition by death.location Order by death.location, death.date) as rolling_people_vaccinated
From Portfolio_Project..covid_deaths1$ death
Join Portfolio_Project..covid_vaccinations1$ vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null

Select *, (rolling_people_vaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for visualization later


Create View PercentPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, Sum(Convert(bigint,vac.new_vaccinations)) Over (partition by death.location Order by death.location,
death.date) as rolling_people_vaccinated
From Portfolio_Project..covid_deaths1$ death
Join Portfolio_Project..covid_vaccinations1$ vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is not null


Select*
From PercentPopulationVaccinated-