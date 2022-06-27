
--We query the covid_deaths table to look into it's various columns
select * from COVID19_PROJECT.dbo.['COVID_DEATHS'];

--We query the columns which are required in out project
select t.location, t.date, t.total_cases,t.new_cases, t.total_deaths,t.population
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
order by 1,2;

--DEATH PERCENT CALCULATION

select t.location, t.date, t.total_cases, t.total_deaths,(t.total_deaths/t.total_cases)*100 Death_Percentage
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
--where t.location = 'India'
order by 1,2;

--MAX DEATH PERCENT CALCULATION(we omit North Korea as it shows weird results)

select top 1 location, max(Death_Percentage) as Max_Death_percent
from (select t.location, t.date, t.total_cases, t.total_deaths,(t.total_deaths/t.total_cases)*100 Death_Percentage
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t) p where location != 'North Korea '  group by location order by max(Death_Percentage) desc ;

--Percent Population Infected
select t.location, t.date, t.population, t.total_cases,(t.total_cases/t.population)*100 Percent_Infected
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
--where t.location = 'India'
order by 1,2;

--Max Infection Rate(here we find out the location where Percentage of people infected is highest per capita)
select t.location, t.population, max(t.total_cases) as max_cases ,max((t.total_cases/t.population))*100 Percent_Infected
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
group by t.location, t.population
order by 4 desc;

--Highest death count 
select  t.location, max(cast(t.total_deaths as int)) as Death_count
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
where t.continent is not null 
group by t.location
order by 2 desc;

--Breaking down by continents

select  t.location, max(cast(t.total_deaths as int)) as Death_count
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
where t.continent is  null 
group by t.location
order by 2 desc;

--World View
select t.date,  sum(t.new_cases) as total_cases, sum(cast(t.new_deaths as int)) as total_deaths, sum(cast(t.new_deaths as int))/sum(t.new_cases)*100 as Global_Death_percent
from 
COVID19_PROJECT.dbo.['COVID_DEATHS'] t
where t.continent is not null 
group by t.date
order by 2 desc;

--Population vs Vaccinations(we look at new vaccinations for every date and the total vaccinations till date(rolling_vaccinations))
select t1.continent, t1.date,t1.location,t1.population, t2.new_vaccinations,
sum(cast(t2.new_vaccinations as bigint)) over(partition by t1.location order by t1.location,t1.date) as rolling_vaccinations
from COVID19_PROJECT.dbo.['COVID_DEATHS'] t1 join COVID19_PROJECT.dbo.['VACCINATION_DATA'] t2
ON t1.location = t2.location
where t1.continent is not null
and t1.date = t2.date
order by 3,2;

--Population vs vaccinations & percent of population vaccinated vaccinated ( here we calculate the percent of people vaccinated till date)
select a.continent, a.date,a.location,a.population, a.new_vaccinations,
a.rolling_vaccinations,(a.rolling_vaccinations/a.population)*100 as percent_vaccinated from
(select t1.continent, t1.date,t1.location,t1.population, t2.new_vaccinations,
sum(cast(t2.new_vaccinations as bigint)) over(partition by t1.location order by t1.location,t1.date) as rolling_vaccinations
from COVID19_PROJECT.dbo.['COVID_DEATHS'] t1 join COVID19_PROJECT.dbo.['VACCINATION_DATA'] t2
ON t1.location = t2.location
where t1.continent is not null
and t1.date = t2.date) as a
order by 3,2;

--creating view of percentvaccinated
create view Percent_Vaccinated as
select a.continent, a.date,a.location,a.population, a.new_vaccinations,
a.rolling_vaccinations,(a.rolling_vaccinations/a.population)*100 as percent_vaccinated from
(select t1.continent, t1.date,t1.location,t1.population, t2.new_vaccinations,
sum(cast(t2.new_vaccinations as bigint)) over(partition by t1.location order by t1.location,t1.date) as rolling_vaccinations
from COVID19_PROJECT.dbo.['COVID_DEATHS'] t1 join COVID19_PROJECT.dbo.['VACCINATION_DATA'] t2
ON t1.location = t2.location
where t1.continent is not null
and t1.date = t2.date) as a;

select * from Percent_Vaccinated;
