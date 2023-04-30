
--Selecting data I'll be working with (Covid-muertes, covid-vacunas in this case)
--COVID-vaccinations data:

SELECT *
FROM [portfolio projects]..[COVID-vacunas]
WHERE continent != ' '

--South America Vaccinations Data
SELECT 
location, 
date, 
NULLIF(CONVERT(REAL, total_vaccinations), 0)AS TotalVaccinations,
NULLIF(CONVERT(REAL,new_vaccinations), 0) AS NewVaccinations
FROM [portfolio projects]..[COVID-vacunas]
WHERE location like '%Venezuela%'
ORDER BY 1,2

/*COVID-deaths data:*/

SELECT 
location, 
date, 
total_cases AS TotalCases, 
new_cases AS NewCases, 
total_deaths as TotalDeaths, 
new_deaths as NewDeaths, 
population
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '


/*total_cases vs total_deaths in targeted countries*/
--DeathPercentage by covid in South America
SELECT
location, 
date, 
total_cases,
total_deaths, 
(CONVERT(real, total_deaths)/NULLIF(CONVERT(real, total_cases),0))*100 as DeathsPorcentage 
FROM [portfolio projects]..[COVID-muertes]
where location like '%Venezuela%'
order by 1,2

-- llooking total_cases vs Population in Venezuela

SELECT
location, 
date, 
total_cases, 
population, 
(CONVERT(real, total_cases)/CONVERT(real, population))*100 as PopulationPercentage
FROM [portfolio projects]..[COVID-muertes]
where location like '%Venezuela%'
order by 1,2

--

/*Age average of people with covid test by continet*/

SELECT 
continent, 
round(AVG(CONVERT(REAL, total_tests)), 0) AS TotalTest,
ROUND(NULLIF(AVG(CONVERT(REAL, median_age)), 0),0) AS MedianAge
FROM [portfolio projects]..[COVID-vacunas]
where continent  != ' '
GROUP BY continent

/*Countries with the highest infectacion rates*/
SELECT
location as Countries,   
population,
MAX(total_cases) as InfectationCount,
MAX((CONVERT(real, total_cases) / CONVERT(real, population)))*100 as HighestPopulationPercentage
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
GROUP BY location, population
order by HighestPopulationPercentage desc



/*Countries with highest deaths count per population*/

SELECT
location as Countries,   
MAX(cast(total_deaths as real)) as TotalDeathCount
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
GROUP BY location
ORDER BY TotalDeathCount Desc


/*BREAKING OUT BY CONTINENT*/

SELECT
location,   
MAX(cast(total_deaths as real)) as TotalDeathCount
FROM [portfolio projects]..[COVID-muertes]
WHERE 
	(continent = ' ')
	and 
	(location not in('world','High income','Upper middle income','Lower middle income','Low income'))
GROUP BY location
ORDER BY TotalDeathCount Desc


/*The continet with the highest deaths count*/
SELECT
	continent,   
MAX(cast(total_deaths as real)) as TotalDeathCount
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
GROUP BY continent
ORDER BY TotalDeathCount Desc


/*GLOBAL RECORDS*/
--DIVIDED BY TIME
SELECT
date, 
SUM(CONVERT(REAL,new_cases)) NewCases,
SUM(CONVERT(REAL,new_deaths)) as NewDeaths,
SUM(CONVERT(real, new_deaths)) / NULLIF(SUM(CONVERT(real, new_cases)),0)*100 as DeathsPorcentage
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
GROUP BY date
order by 1,2

--TOTAL
SELECT 
SUM(CONVERT(REAL,new_cases)) NewCases,
SUM(CONVERT(REAL,new_deaths)) as NewDeaths,
SUM(CONVERT(real, new_deaths)) / NULLIF(SUM(CONVERT(real, new_cases)),0)*100 as DeathsPorcentage
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
--GROUP BY date
order by 1,2

/*Population Deaths VS Vaccinations*/
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(NULLIF(cast(new_vaccinations as real),0)) over (PARTITION BY CD.location ORDER BY CD.location , CD.date) as PeopleVaccinated
FROM [portfolio projects]..[COVID-muertes] CD
JOIN [portfolio projects]..[COVID-vacunas] CV
 on CD.location = CV.location
 and CD.date = CV.date
 WHERE CD.continent != ' '
 ORDER BY 2,3

 --Total Population vs Vaccinations
WITH COMP_POPVACs (Continent, Location,date, Population,new_vaccinations, PeopleVaccinated)
as
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(NULLIF(cast(new_vaccinations as real),0)) over (PARTITION BY CD.location ORDER BY CD.location , CD.date) as PeopleVaccinated
FROM [portfolio projects]..[COVID-muertes] CD
JOIN [portfolio projects]..[COVID-vacunas] CV
 on CD.location = CV.location
 and CD.date = CV.date
 WHERE CD.continent != ' '
)

SELECT *, (PeopleVaccinated / CAST(Population as real))*100 as VaccinationsPercentage
FROM COMP_POPVACs



--**VIEWS for visualizations**
--Percentage of people vaccinated
CREATE VIEW Percent_People_Vaccinated AS
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(NULLIF(cast(new_vaccinations as real),0)) over (PARTITION BY CD.location ORDER BY CD.location , CD.date) as PeopleVaccinated
FROM [portfolio projects]..[COVID-muertes] CD
JOIN [portfolio projects]..[COVID-vacunas] CV
 on CD.location = CV.location
 and CD.date = CV.date
 WHERE CD.continent != ' '

 --GLOBAL RECORDS: divided by time
 CREATE VIEW Global_time_DeathPercentage AS
 SELECT
date, 
SUM(CONVERT(REAL,new_cases)) NewCases,
SUM(CONVERT(REAL,new_deaths)) as NewDeaths,
SUM(CONVERT(real, new_deaths)) / NULLIF(SUM(CONVERT(real, new_cases)),0)*100 as DeathsPorcentage
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
GROUP BY date

--GLOBAL RECORDS:total
CREATE VIEW Global_DeathPercentage AS
SELECT 
SUM(CONVERT(REAL,new_cases)) NewCases,
SUM(CONVERT(REAL,new_deaths)) as NewDeaths,
SUM(CONVERT(real, new_deaths)) / NULLIF(SUM(CONVERT(real, new_cases)),0)*100 as DeathsPorcentage
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
--GROUP BY date

--Continent with the highest deaths count
CREATE VIEW Cotinent_DeathsCount AS
SELECT
	continent,   
MAX(cast(total_deaths as real)) as TotalDeathCount
FROM [portfolio projects]..[COVID-muertes]
WHERE continent != ' '
GROUP BY continent

--Total deaths by continent
CREATE VIEW Continent_TotalDeaths AS
SELECT
location,   
MAX(cast(total_deaths as real)) as TotalDeathCount
FROM [portfolio projects]..[COVID-muertes]
WHERE 
	(continent = ' ')
	and 
	(location not in('world','High income','Upper middle income','Lower middle income','Low income'))
GROUP BY location




