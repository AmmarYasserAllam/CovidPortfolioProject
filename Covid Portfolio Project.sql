select * from Covid_Deaths$ 


--select Data that we are going to be using

select location , date, total_cases, new_cases, total_deaths, population 
from Covid_Deaths$
where continent is not null
order by 1,2

--looking at Total_Deaths vs Total_Cases
--shows Likelihood of dying if you contract covid in Egypt
select location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathspersentage  
from Covid_Deaths$
where location = 'egypt'
and continent is not null
order by 1,2



--looking at Total_cases vs Population
--shows what persentage of population got covid in Egypt
select location , date, total_cases, population, (total_cases/population)*100 as Casespersentage  
from Covid_Deaths$
where location = 'egypt'
and continent is not null
order by 1,2



--looking at Total_cases vs Population
--shows what persentage of population got covid
select location , date, total_cases, population, (total_cases/population)*100 as Casespersentage  
from Covid_Deaths$
--where location = 'egypt'
where continent is not null
order by 1,2



--looking at countries with highest Infiction Rate compared to population

select location , population, max(total_cases)as HighestCases, max((total_cases/population))*100 as PersentagePopulationInficted  
from Covid_Deaths$
where continent is not null
group by location ,population
order by PersentagePopulationInficted desc



--looking at countries with highest Death Count per population

select location , population, max(cast(total_deaths as int))as HighestDeaths, max((total_deaths/population))*100 as DeathsofPopulation 
from Covid_Deaths$
where continent is not null
group by location ,population
order by HighestDeaths desc


--CONTINTENS NUMBERS
--looking at Continents with highest Death Count per population

select location , population, max(cast(total_deaths as int))as HighestDeaths, max((total_deaths/population))*100 as DeathsofPopulation 
from Covid_Deaths$
where continent is  null
group by location ,population
order by HighestDeaths desc



--GLOBAL NUMBERS

select date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewcases,sum(cast(new_deaths as int))/sum(new_cases) as DeathPersentage
from Covid_Deaths$ 
where continent is not null
group by date
order by 1,2


select sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalNewDeaths,sum(cast(new_deaths as int))/sum(new_cases) as DeathPersentage
from Covid_Deaths$ 
where continent is not null
--group by date
order by 1,2


--looking at Total Population vs Total Vaccination
--Using CTE

with PopvsVac (continent,location,date,population,new_vaccinations,TotalPeoplevaccinated)
as 
(
select d.continent, d.location,d.date,d.population,v.new_vaccinations 
,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location ,d.date) as TotalPeoplevaccinated 
from Covid_Deaths$ d
join Covid_Vaccinations$ v on d.date = v.date and d.location = v.location
where d.continent is not null 
--and d.location = 'egypt'
--order by 2,3
)
select * , (TotalPeoplevaccinated/population) as PeoplevaccinatedPersentage
from PopvsVac




--TEMP TABLE

drop table if exists #PersentagePeoplevaccinated
create table #PersentagePeoplevaccinated
(
continent  nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeoplevaccinated numeric
)

insert into #PersentagePeoplevaccinated
select d.continent, d.location,d.date,d.population,v.new_vaccinations 
,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location ,d.date) as TotalPeoplevaccinated 
from Covid_Deaths$ d
join Covid_Vaccinations$ v
	on d.date = v.date 
	and d.location = v.location
where d.continent is not null 
--and d.location = 'egypt'
--order by 2,3

select * 
, (TotalPeoplevaccinated/population) as PeoplevaccinatedPersentage
from #PersentagePeoplevaccinated






create view PersentagePeoplevaccinated as
select d.continent, d.location,d.date,d.population,v.new_vaccinations 
,sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location ,d.date) as TotalPeoplevaccinated 
, (sum(convert(float,v.new_vaccinations)) over (partition by d.location order by d.location ,d.date)/population) as PeoplevaccinatedPersentage 
from Covid_Deaths$ d
join Covid_Vaccinations$ v
	on d.date = v.date 
	and d.location = v.location
where d.continent is not null 
--and d.location = 'egypt'
--order by 2,3


select * 
from PersentagePeoplevaccinated