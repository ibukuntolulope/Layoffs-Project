-- Exploratory Data Analysis

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT * 
FROM world_layoffs.layoffs_staging2;

-- EASIER QUERIES

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;

SELECT CASE WHEN funds_raised_millions IS NOT NULL THEN CAST(funds_raised_millions AS SIGNED INTEGER)
   ELSE NULL
      END AS converted_int
FROM world_layoffs.layoffs_staging2;

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN funds_raised_millions INT;

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN total_laid_off INT;

SELECT MAX(total_laid_off)
FROM world_layoffs.layoffs_staging2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time

SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch



-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- LIMIT 10;

SELECT MIN(date), MAX(date)
FROM world_layoffs.layoffs_staging2;

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT *
FROM world_layoffs.layoffs_staging2;

-- by location
SELECT location, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 DESC;


SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;






-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------


-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) AS MONTH, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY MONTH ASC;

SELECT *
FROM world_layoffs.layoffs_staging2;

-- now use it in a CTE so we can query off of it
WITH Rolling_Total AS 
(
SELECT SUBSTRING(date,1,7) as MONTH, SUM(total_laid_off) AS total_laid_off
FROM world_layoffs.layoffs_staging2
WHERE SUBSTRING(date,1,7) IS NOT NULL
GROUP BY MONTH
ORDER BY 1 ASC
)
SELECT MONTH, total_laid_off, SUM(total_laid_off) 
OVER (ORDER BY MONTH ) as Rolling_total
FROM Rolling_Total;



-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at

SELECT company, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(date) AS Years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
  ORDER BY company ASC;

WITH Company_Year (Company, Years, Total_laid_off) AS
(
  SELECT company, YEAR(date) AS Years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
  ), Company_Year_Rank AS
  (SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
  FROM Company_Year
  WHERE Years IS NOT NULL 
  )
 SELECT *
 FROM Company_Year_Rank
 WHERE Ranking <= 5;
  


















































