# Netflix Movies and TV Shows Data Analysis by  SQL
![logo](https://github.com/user-attachments/assets/ba1e3483-a16b-4456-8290-d404eafeebe0)
# Overview
This project involves an analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various questions based on the dataset.
# Skills showcased in this Project
* Database Management and Schema Design
* Data Aggregation and Grouping
* Advanced Querying with Window Functions and CTE
* Filtering and Sorting Data
* String Manipulation and Array Handling
* Data Transformation and Cleaning
* Handling NULLs and Missing Data
# Dataset
The dataset can be found [here](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)
## Schema
```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	cast_ VARCHAR(1000),
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);
```
### Count the number of Movies and TV Shows
```sql
SELECT 
    type,
    COUNT(*) AS content_count
FROM netflix
GROUP BY type;
```
### Find the most common rating in Movies and TV Shows
```sql
WITH rating_rank AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
)
SELECT 
    type,
    rating
FROM rating_rank
WHERE ranking = 1;
```
### List all movies released in a specific year (e.g., 2021)
```sql
SELECT 
    release_year,
    title
FROM netflix
WHERE release_year = 2021 
    AND type = 'Movie'
ORDER BY title;
```
### Find the top 5 countries with the most content on Netflix

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
    COUNT(*) AS content_count
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY content_count DESC
LIMIT 5;
```
### Find the top 5 countries by content type on Netflix
```sql
WITH country_rank AS (
    SELECT 
        UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country,
        type,
        COUNT(*) AS country_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    WHERE country IS NOT NULL
    GROUP BY new_country, type
)
SELECT 
    new_country,
    type,
    country_count
FROM country_rank
WHERE ranking <= 5;
```
### Identify the longest movie by duration
```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
    AND duration IS NOT NULL
ORDER BY CAST(REPLACE(duration, 'min', '') AS INT) DESC
LIMIT 1;
```
### Find all content added in the last 5 years
```sql
SELECT *
FROM netflix 
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years' 
    AND date_added IS NOT NULL;
```
### Find all Movies/TV Shows by director 'Kirsten Johnson'
```sql
SELECT *
FROM netflix
WHERE director ILIKE '%Kirsten Johnson%';
```
### List all TV shows with more than 5 seasons
```sql
SELECT * 
FROM netflix
WHERE type = 'TV Show' 
    AND LEFT(duration, 1)::INT > 5;
```
### Find the number of content items in each genre
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY genre
ORDER BY total_content DESC;
```
### Find top 5 years with the highest average content release by Germany
```sql
WITH yearly_content AS (
    SELECT 
        EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
        COUNT(*) AS yearly_content_count
    FROM netflix
    WHERE country ILIKE '%Germany%'
    GROUP BY year
)
SELECT 
    year,
    yearly_content_count,
    ROUND(yearly_content_count::NUMERIC / (SELECT COUNT(*) FROM netflix WHERE country ILIKE '%Germany%')::NUMERIC * 100, 2) AS avg_per_year
FROM yearly_content
ORDER BY year DESC
LIMIT 5;
```
### List all Movies that are Documentaries
```sql
SELECT *
FROM netflix
WHERE type = 'Movie' 
    AND listed_in ILIKE '%Documentaries%';

-- Find all content without a Director
SELECT *
FROM netflix
WHERE director IS NULL;
```
### Find how many Movies actor 'Jack Black' appeared in
```sql
SELECT * 
FROM netflix
WHERE cast_ ILIKE '%Jack Black%';
```
### Find the top 10 actors who appeared in the highest number of Movies produced in Germany
```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(cast_, ',')) AS actor,
    COUNT(*) AS movie_count
FROM netflix
WHERE country ILIKE '%Germany%'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;
```
### Categorize content based on the presence of 'Kill' and 'Violence' keywords
```sql
SELECT 
    CASE 
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
        ELSE 'Good'
    END AS category,
    COUNT(*) AS content_count
FROM netflix
GROUP BY category;
```

