select *
from Portfolio_Project_1..covid_deaths
where continent is not null
order by 3,4

-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_per_case
from Portfolio_Project_1..covid_deaths
where location like '%kingdom%'
order by 1,2


-- total cases in population

select location, date, population, total_cases, (total_cases/population)*100 as percentage_population
from Portfolio_Project_1..covid_deaths
where location like '%kingdom%'
order by 1,2



-- countries with highest infection rate compared to population

select location, population, max(total_cases) as highest_cases_count, max((total_cases/population))*100 as highest_cases_rate
from Portfolio_Project_1..covid_deaths
group by location, population
order by highest_cases_rate desc



-- showing country with highest death rate

select location, max(total_deaths) as death_count
from Portfolio_Project_1..covid_deaths
where continent is not null
group by location
order by death_count desc

-- breaking things down by continent

select location, max(total_deaths) as death_count
from Portfolio_Project_1..covid_deaths
where continent is null
group by location
order by death_count desc


-- global numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as death_per_case
from Portfolio_Project_1..covid_deaths
-- where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2



-- total population vs vaccinations
-- how many people are vaccinated in the world

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as cumulative_vac
from Portfolio_Project_1..covid_deaths dea
join Portfolio_Project_1..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- cte to see total vaccines per population

with pop_vac (continent, location, date, population, new_vaccinations, cumulative_vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as cumulative_vac
from Portfolio_Project_1..covid_deaths dea
join Portfolio_Project_1..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (cumulative_vac/population)*100 
from pop_vac

-- temp table to see total vaccines per population

drop table if exists #percent_vaccinated
create table #percent_vaccinated
(
continent varchar(255),
location varchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
cumulative_vac numeric
)

insert into #percent_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as cumulative_vac
from Portfolio_Project_1..covid_deaths dea
join Portfolio_Project_1..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (cumulative_vac/population)*100 
from #percent_vaccinated



-- view to store data for later visualisations

create view percent_population_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location , dea.date) as cumulative_vac
from Portfolio_Project_1..covid_deaths dea
join Portfolio_Project_1..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

