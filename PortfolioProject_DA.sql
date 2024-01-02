Select * 
From CovidDeaths 
Where continent is not null
order by 3,4


Select location, date, total_cases, total_deaths, 
(cast(total_cases as int)/cast(total_deaths as int)) * 100 as DeathPercentage
from CovidDeaths
where location like '%america%'
order by 1,2



Select location, date, total_cases, population_density, 
(cast(total_cases as int)/population_density) * 100 as DeathPercentage
from CovidDeaths
--where location like '%america%'
order by 1,2

---Looking at countries with highest infection rate compared to population
Select location,Population_density, Max(total_cases) as HighestInfectionCount,
Max(cast(total_cases as int)/population_density) * 100 as PercentPopulationInfected
from CovidDeaths
Group by location,population_density
--where location like '%america%'
order by PercentPopulationInfected


--Showing countries with Highest Death Count per population

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is not null
Group by location
--where location like '%america%'
order by TotalDeathCount desc

--BY CONTINENT

Select location,Max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
Where continent is NOT  null
Group by location
--where location like '%america%'
order by TotalDeathCount desc

--Global Numbers

Select date,total_deaths,total_cases,(cast(total_cases as int)/cast(total_deaths as int))
* 100 as DeathPercentage
from CovidDeaths
Where continent is NOT  null
order by 1,2 

Select * from CovidDeaths order by 3,4

--Select * from CovidVaccinations order by 3,4

--Select Data that awe are going to be using

Select  location,date,total_cases,new_cases,total_deaths,population_density
from PortfolioProject..CovidDeaths order by 1,2


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercetage
from CovidDeaths where continent is not null
Group By date 
order by 1,2

--Lookinf at total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopVsVac (Continent,Location,Date,population_density,new_vaccinations,RollingPeoplevaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2,3
)
Select * ,(RollingPeoplevaccinated/population_density)*100
From PopVsVac


_--Temp Table
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population_density numeric,
New_Vaciinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2,3

Select * ,(RollingPeoplevaccinated/population_density)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualization
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population_density,vac.new_vaccinations,
Sum(convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.Location, dea.Date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--Order by 2,3
