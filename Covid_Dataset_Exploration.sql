SELECT *
FROM PortfolioProject.covid_deaths 
order by 3,4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.covid_deaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as Death_Percentage
FROM PortfolioProject.covid_deaths
WHERE location LIKE '%stated%' and continent != '' and continent is not null
order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of the population got covid

SELECT location, date, population, total_cases, (total_cases / population) * 100 as Population_Infected_Percent
FROM PortfolioProject.covid_deaths
WHERE location LIKE '%states%' and continent != '' and continent is not null
order by 1,2;


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases / population) * 100 as Population_Infected_Percent
FROM PortfolioProject.covid_deaths
where continent != '' and continent is not null
group by location, population
order by Population_Infected_Percent desc;


-- Showing countries with Highest Death Count per Population
-- Since total_deaths column has datatype TEXT(NVARCHAR) we need to perform the cast to get meaningful results.
-- Side Note: Although we have the datatype INT in myql, it is impossible to cast TEXT directly to INT. Instead, we cast it to SIGNED
SELECT location, MAX(cast(total_deaths as SIGNED)) as Total_Death_Count
FROM PortfolioProject.covid_deaths
where continent != '' and continent is not null
group by location
order by Total_Death_Count desc;

-- Now we break things down by Continent

-- Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as SIGNED)) as Total_Death_Count
FROM PortfolioProject.covid_deaths
where continent != '' and continent is not null
group by continent
order by Total_Death_Count desc;



-- GLOBAL NUMBERS

-- Column new_cases has type INT but new_deaths has type TEXT. Therefore, casting is required only for new_deaths column.
SELECT date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as signed)) as Total_Deaths, sum(cast(new_deaths as signed)) / sum(new_cases) * 100 
as Death_Percentage
FROM PortfolioProject.covid_deaths
-- WHERE location LIKE '%state%' 
where continent != '' and continent is not null
group by date
order by 1,2;


-- Total death percentage worldwide

SELECT sum(new_cases) as Total_Cases, sum(cast(new_deaths as signed)) as Total_Deaths, sum(cast(new_deaths as signed)) / sum(new_cases) * 100 
as Death_Percentage
FROM PortfolioProject.covid_deaths
-- WHERE location LIKE '%state%' 
where continent != '' and continent is not null
order by 1,2;


-- Looking at Total Population vs Vaccination

-- Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(	
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, sum(convert(vaccinations.new_vaccinations, SIGNED)) over (partition by deaths.location order by deaths.location, 
	deaths.date) as Rolling_People_Vaccinated
from PortfolioProject.covid_deaths deaths
join PortfolioProject.covid_vaccinations vaccinations
	on deaths.location = vaccinations.location
    and deaths.date = vaccinations.date
where deaths.continent != '' and deaths.continent is not null
-- order by 2, 3
)

select *, (Rolling_People_Vaccinated / Population) * 100 as Rolling_People_Vaccinated_Percentage
from PopvsVac;


DROP Table if exists PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent TEXT,
Location TEXT,
Date DATETIME,
Population INT,
New_Vaccinations TEXT,
RollingPeopleVaccinated INT
);

INSERT INTO PercentPopulationVaccinated
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, sum(cast(vaccinations.new_vaccinations as signed)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated / population) * 100

From PortfolioProject.covid_deaths deaths
Join PortfolioProject.covid_vaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent != '' and deaths.continent is not null
order by 2, 3;

Select *, (RollingPeopleVaccinated / Population)*100
From #PercentPopulationVaccinated



-- Creating a view to store data for later visualizations
Create View PercentPopulationVaccinated as
Select deaths.continent, deaths.location, deaths.date, deaths.population, vaccinations.new_vaccinations
, SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.CovidDeaths deaths
Join PortfolioProject.CovidVaccinations vaccinations
	On deaths.location = vaccinations.location
	and deaths.date = vaccinations.date
where deaths.continent is not null and deaths.continent != ''








