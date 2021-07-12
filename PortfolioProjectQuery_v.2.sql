
--Selecting Data from all Tables
Select * from PortfolioProject.dbo.CovidDeaths
Select * from PortfolioProject.dbo.CovidVaccinations

--Covid Death Info from United States
Select * from PortfolioProject.dbo.CovidDeaths
where location = 'United States'

--Population of Each Location (in alphabetical order).
Select location, MAX(population) AS Population
from PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
Group by location
Order by location

--Global Population Death Rate Using Subquery and CTE. Used CAST to convert column from varchar to integer.
With GlobalPopulation_CTE
AS(
Select MAX(population) AS LocationPopulation, MAX(cast(total_deaths as INT)) AS LocationDeaths from PortfolioProject.[dbo].[CovidDeaths]
Where continent IS NOT NULL
Group By location)

Select SUM(LocationPopulation) As GlobalPopulation, SUM(LocationDeaths) As GlobalDeaths, 
(Select Sum(LocationDeaths)/Sum(LocationPopulation) AS GlobalDeathRate from GlobalPopulation_CTE) As GlobalDeathRate
from GlobalPopulation_CTE

--Death Rate by Location Using a JOIN and CTE.
WITH DeathRate_CTE (location, Population, TotalDeaths)
AS (
Select location, max(population) as Population, max(cast(total_deaths as int)) as TotalDeaths
from PortfolioProject.dbo.CovidDeaths
Where continent IS NOT NULL
Group by location)

Select *, (TotalDeaths/Population)as DeathRate
From DeathRate_CTE
Order by DeathRate DESC

--Full Vaccination Rate by Location using a JOIN and CTE. 
With VaccinationRate_CTE (location, population, PeopleFullyVaccinated)
AS (
Select cd.location, max(population) as Population, max(cast(people_fully_vaccinated as int)) as PeopleFullyVaccinated
from PortfolioProject.dbo.CovidDeaths cd
	Join PortfolioProject.dbo.CovidVaccinations cv
	ON cd.location = cv.location
Where cd.continent IS NOT NULL
Group by cd.location)

Select *, (PeopleFullyVaccinated/population) as FullVaccinationRate
From VaccinationRate_CTE
Where PeopleFullyVaccinated IS NOT NULL
AND population IS NOT NULL
Order by FullVaccinationRate DESC

-- Location Total Deaths by Day using PARTITION BY
Select location, date, population, new_deaths, SUM(cast(new_deaths as INT)) OVER (Partition by location order by location, date) AS TotalDeathsByDate
from PortfolioProject.[dbo].[CovidDeaths]
Where continent IS NOT NULL
