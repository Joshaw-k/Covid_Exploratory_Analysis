-- 2020-01-01 00:00:00 2021-04-30 00:00:00
-- Let's load the interesting features of our exploratory analysis
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_deaths
ORDER BY 2
/* We have over 85k observations with 6 features, sorted by date to
 get the chronology of this case study. In 2020-01-22 China had
accumulated 548 total cases with 17 deaths, which was over 98% of 
the whole Asian continent*/

-- Let's look at Total Cases Vs Total Deaths based on location

-- ** Which countries had the highest number of covid cases**
SELECT location,MAX(total_cases) AS total_cases
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
/* United States had the highest number of cases of over 32 million
 and Germany had the least out of the top 10 of over 3 million cases.*/
 
 
-- ** Which countries had the highest number of covid deaths**
SELECT location,MAX(total_cases) AS total_cases,MAX(total_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 3 DESC
LIMIT 10
/* United States had the highest number of deaths of over 576k
 and Spain had the least out of the top 10 with over 78k deaths.*/ 


-- * Which countries had the highest infection rate
SELECT location,MAX(total_cases) AS total_cases,population,ROUND((MAX(total_cases)/MAX(population))*100,2) AS 'infection_rate(%)'
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10
/* Andorra had the highest infection rate of about 17% and Israel
 had the least infection rate of the top ten with close to 10% */

-- ** Which countries had the highest death rate of covid patients
SELECT location,MAX(total_cases),MAX(total_deaths),ROUND((MAX(total_deaths)/MAX(total_cases))*100,2) AS 'death_rate(%)'
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10
/* Vanuatu had the highest death rate of 25% and Afghanistan
 had the least death rate of the top ten with about to 4% */
 
-- ** Which countries had the highest death of covid patients per population
SELECT location,MAX(total_deaths),population,ROUND((MAX(total_deaths)/population)*100,2) AS 'death_per_pop'
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10
/* Hungary had the highest death of covid patients per population with 0.29% and Slovenia
 had the least death of covid patients per population of the top ten with 0.20% */
 
-- ** Which continent had the highest number of covid cases**
SELECT continent,SUM(new_cases) AS total_cases
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
/* Europe had the highest number of cases of over 44 million
 and Oceania had the least out of the top 10 of over 43k cases.*/
 
 -- ** Which continent had the highest number of covid deaths**
SELECT continent,SUM(new_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
/* Europe had the highest number of deaths of over 1 million
 and Oceania had the least out of the top 10 of over 1k deaths.*/
 
-- ** Which countries had the highest death rate of covid patients
SELECT continent,SUM(new_cases) AS total_cases,SUM(new_deaths) AS total_deaths,ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS 'death_rate(%)'
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY 4 DESC
LIMIT 10
/* South America had the highest death rate of close to 3% and Asia
 had the least death rate of the top ten with over to 1% */
 
-- ** What day had the highest number of covid cases and which country had the highest**
SELECT date,location,SUM(new_cases) AS total_cases
FROM covid_deaths
WHERE continent IS NOT NULL AND date = '2021-04-28 00:00:00'
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1
/* the highest number of cases was on the 28th of April 2021 with over
 900k cases and India was the country with the highest case with over 379k cases.*/

-- ** What day had the highest number of covid cases and which country had the highest**
SELECT date,location,SUM(new_deaths) AS total_deaths
FROM covid_deaths
WHERE continent IS NOT NULL AND date = '2021-01-20 00:00:00'
GROUP BY 1,2
ORDER BY 3 DESC
/* the highest number of cases was on the 20th of January 2021 with close to
 18k deaths and United States was the country with the highest case with over 4k deaths.*/

-- Let's see the growth of new tests taken compared to the total tests taken in the United States
SELECT location,date,new_tests,SUM(new_tests) OVER(PARTITION BY location ORDER BY location,DATE) AS total_tests
FROM covid_vaccinations
WHERE continent IS NOT NULL AND location = 'United States' AND new_tests IS NOT NULL
/* In the United States, there were 346 test taken on the 1st of March 2020. The maximum number
 of tests taken in a day was about 2.3 million which was on the 6th of January 2021 with a total 
 test taken of over 265 million.*/
 
-- Let's see the rise of new vaccinations collected compared to the total vaccinations collected in the United States
SELECT location,date,new_vaccinations,SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY location,DATE) AS total_vaccinations
FROM covid_vaccinations
WHERE continent IS NOT NULL AND location = 'United States' AND new_vaccinations IS NOT NULL
/* In the United States, there were close to 58k vaccinations collected on the 21st of December 2020.
  The total number of vaccinations collected was over 227 million which was on the 30th of April 2021.*/
  
-- Which countries had the highest number people vaccinated (not completely) and people fully vaccinated
SELECT location,MAX(people_vaccinated) AS people_vaccinated,MAX(people_fully_vaccinated) AS people_fully_vaccinated
FROM covid_vaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC
LIMIT 10
/* United States had the highest number of people who had taken the first dose of the vaccine
   with over 144 million people and over 101 million people were fully vaccinated. Mexico had
	the least number of people who had taken the first dose of the vaccine out of the top 10,
   with over 144 million people and over 7 million people were fully vaccinated.*/

-- Which continent had the highest number people vaccinated (not completely) and people fully vaccinated
WITH vaccinated AS
(SELECT continent,location,MAX(people_vaccinated) AS people_vaccinated,MAX(people_fully_vaccinated) AS people_fully_vaccinated
FROM covid_vaccinations
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 3 DESC)

SELECT continent,SUM(people_vaccinated) AS people_vaccinated,SUM(people_fully_vaccinated) AS people_fully_vaccinated
FROM vaccinated
GROUP BY continent
/* Asia had the highest number of people who had taken the first dose of the vaccine
   with over 197 million people and over 63 million people were fully vaccinated. Oceania had
	the least number of people who had taken the first dose of the vaccine, with over 401 thousand
	people and about 60 thousand people were fully vaccinated.*/

-- Let's create a temp table for the total vaccinations and people fully vaccinated

DROP TABLE IF EXISTS Vaccination_per_People;
CREATE TEMP TABLE Vaccination_per_People(
	location TEXT,
	date DATETIME,
	new_vaccinations DOUBLE,
	total_vaccinations DOUBLE,
	people_vaccinated DOUBLE,
	people_fully_vaccinated DOUBLE
); 

INSERT INTO Vaccination_per_People(
SELECT location,date,new_vaccinations,SUM(new_vaccinations) OVER(PARTITION BY location ORDER BY location,DATE) AS total_vaccinations,
		people_vaccinated,people_fully_vaccinated
FROM covid_vaccinations
WHERE continent IS NOT NULL AND new_vaccinations IS NOT NULL
);
SELECT *
FROM Vaccination_per_People