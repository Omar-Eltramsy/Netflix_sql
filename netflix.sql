DROP TABLE IF EXISTS netflix;
create table netflix (
	show_id	varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(208),
	cast_ varchar(1000),
	country	varchar(150),
	date_added varchar(50),
	release_year int,
	rating	varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
);

select * from netflix; 

--number of movie and number of tv
select 
	type,
	count(*)
from netflix
group by type;

-- what is the most rating in movies and tv
select
	type,
	rating
from 
(
	select 
		type,
		rating,
		count(*),
		rank()over(partition by type order by count(*) desc ) as ranking
		-- max(rating)
	from netflix
	group by 1,2
) as t1
where 
	ranking = 1;
	
-- the list of all movies released in a specific year (i.e 2021)

select 
	release_year,
	title
from 
	netflix
where 
	release_year='2021' 
	and 
	type='Movie'
order by 
	title ;

--find the most top 5 country with the most content on Netflix
select 
	unnest(string_to_array(country,',')) as new_country,
	count(*)
from 
	netflix
where 
	country is not null
group by 
	country
order by 
	count desc
limit 5;

--find the most top 5 country in each content on Netflix

select 
	new_country,
	type,
	count
from 
(	select 
		unnest(string_to_array(country,',')) as new_country,
		type,
		count(*),
		rank()over(partition by type order by  count(*) desc)
	from 
		netflix
	where 
		country is not null
	group by 
		country,type
) as t2
where 
	rank in (1,2,3,4,5) ;

--identify the longest movie

select *
from 
	netflix
where 
	type ='Movie'
	and duration is not null
order by 
	cast(replace(duration,'min','') as int) desc
limit 1;

-- find content added in the last 5 years
select *
from netflix 
where date_added::date >= current_date - interval '5 years' and date_added is not null;

--find all the movies/TV shows by director 'Kirsten Johnson'
select *
from netflix
where director ilike '%Rajiv Chilaka%';

--all tv shows with more than 5 seasons
select * 
from 
	netflix
where 
	type ='TV Show' 
	and
	left(duration,1)::int > 5 ;

-- find the number of content items in each genre

select 
	unnest(string_to_array(listed_in,', '))as genre,
	count(show_id) as total_content
from 
	netflix
group by genre
order by total_content desc;

-- find each year and the average number of content release by germany on netflix
--return top 5 years with highest avg content release

select 
	extract(year FROM to_date(date_added,'Month DD,YYYY'))as year,
	count(*) as yearly_content,
	round(count(*)::numeric/(select count(8) from netflix where country ilike '%Germany%')::numeric*100,2) as avg_per_year
from netflix
where country ilike '%Germany%' 
group by 1
order by year desc
limit 5;

--list all the movie tha are document
select *
from netflix
where 
	type='Movie' 
	and 
	listed_in ilike '%Documentaries%';
-- Find All Content Without a Director
select *
from netflix
where director is null;
--Find How Many Movies Actor 'Jack Black' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE cast_ ilike '%Jack Black%';

--Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in germany


SELECT 
    UNNEST(STRING_TO_ARRAY(cast_, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country ilike '%Germany%'
GROUP BY actor
ORDER BY COUNT(*) DESC;

--Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category
LIMIT 10;