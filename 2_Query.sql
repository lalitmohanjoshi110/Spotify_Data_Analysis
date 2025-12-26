-- EDA
select count(*) from spotify;

-- Total distinct count of artist 
select count(distinct artist) from spotify;

-- Total distinct artist 
select distinct artist from spotify;

-- Max duration

-- select max(duration_min),  round(avg(duration_min), 2) from spotify;
-- the above query was not giving me the desired output because the column data type is in varchar/text format 

-- # NOTE: Explicit type Casting 
SELECT
  MAX(duration_min),
  ROUND(AVG(duration_min::numeric), 2)
FROM spotify;

/*Why this happens (PostgreSQL quirk)
In PostgreSQL:
AVG(double precision) → returns double precision
ROUND(double precision, 2) ❌ does NOT exist*/

select * from spotify
where duration_min=0;

-- since it is not possible for any song to have duration = 0, so we will remove these 2 rows

delete from spotify where duration_min = 0; -- successfully deleted 2 rows having duration min = 0 
-- now total count changed from 20594 to 20592

/*
-------------------------------------------------------
-- DATA ANALYSIS - EASY CATEGORY
-------------------------------------------------------

Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
2. List all albums along with their respective artists.
3. Get the total number of comments for tracks where licensed = TRUE.
4. Find all tracks that belong to the album type single.
5. Count the total number of tracks by each artist.
select * 
group by artist
*/

-- 1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT track, stream FROM SPOTIFY
where stream > 1000000000;

-- 2. List all albums along with their respective artists.
select distinct album, artist 
from spotify
order by 1;

SELECT
  album,
  STRING_AGG(distinct artist, ', ' ORDER BY artist) AS artists
FROM spotify
GROUP BY album
ORDER BY album;

/*-----------NOTE: Why CONCAT() does NOT work
CONCAT() works row by row, not across rows.
Example:
SELECT CONCAT(album, artist) FROM spotify;
*/

-- 3. Get the total number of comments for tracks where licensed = TRUE.

select sum(comments) as Total_Comments
from spotify
where licensed = 'true'; -- simply licensed = true can also work

-- 4. Find all tracks that belong to the album type single.

select * from spotify 
where album_type ilike 'single'  -- used ilike because we don't know that whether anywhere single is present in upper and lower case also

-- 5. Count the total number of tracks by each artist.

select artist, count(distinct track) as Total_No_of_Tracks
from spotify
group by artist  
order by 2 DESC;


/* -------------------------------------------------------
Medium Level
1. Calculate the average danceability of tracks in each album.
2. Find the top 5 tracks with the highest energy values.
3. List all tracks along with their views and likes where official_video = TRUE.
4. For each album, calculate the total views of all associated tracks.
5. Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- 6. Calculate the average danceability of tracks in each album.

SELECT album, AVG(danceability) as Avg_Dance 
from spotify
group by album
order by 2 desc; --Explicit Typecasting can use: round(AVG(danceability)::numeric,2) but answer is roundedoff 
/* 
NOTE: if we would have column daatype as numeric then we can directly write: TRUNC(AVG(danceability), 2) AS avg_dance 
One more method: 
SELECT
  album,
  TRUNC(AVG(danceability)::numeric, 2) AS avg_dance
FROM spotify
GROUP BY album
ORDER BY avg_dance DESC;
*/
-- 7. Find the top 5 tracks with the highest energy values.

select track,
	max(energy) 
from spotify
group by track
order by max(energy) desc
limit 5;


-- 8. List all tracks along with their total views and likes where official_video = TRUE.
/* # NOTE: Key rule (remember this)
WHERE → filters rows before aggregation
HAVING → filters groups after aggregation
*/

select track,    
sum(views) as Total_Views, 
sum(likes) as Total_Likes
from spotify
where official_video = 'true'
group by track
order by 2 DESC;
/* Explanation: 
GROUP BY track; -- This collapses many rows into one row per track.
After this point: Row-level columns (like official_video) no longer exist

Only:
grouped columns (track)
aggregated values (SUM(), COUNT(), etc.)
are valid
*/

/* Method-2
SELECT
  track,
  SUM(views) AS total_views,
  SUM(likes) AS total_likes
FROM spotify
GROUP BY track
HAVING BOOL_OR(official_video = 'true')
ORDER BY total_views DESC;
*/

-- 9. For each album, calculate the total views of all associated tracks.
 
 select 
 	album, 
 	track, 
 	sum(views) as Total_Views
 from spotify
 group by album, track
 order by 3 desc;

-- 10. Retrieve the track names that have been streamed on Spotify more than YouTube.

select track, 
COALESCE(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
COALESCE(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
from spotify 
group by 1;
-- We are also getting NULL values, so for dealing with that we use COALESCE
-- NOTE: We can't use the above query directly because we have used case in the coalesce lines....
-- we will save the above fulll query in subquery format.

select * from 
(select track, 
COALESCE(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
COALESCE(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
from spotify 
group by 1) as t1
where streamed_on_youtube < streamed_on_spotify
and streamed_on_youtube <> 0;  -- != 0 can also be used 
 

/* -------------------------------------------------------
Advanced Level
11. Find the top 3 most-viewed tracks for each artist using window functions.
12. Write a query to find tracks where the liveness score is above the average.
13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
14. Find tracks where the energy-to-liveness ratio is greater than 1.2.
15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.
*/

-- 11. Find the top 3 most-viewed tracks for each artist using window functions.

WITH ranking_artist
AS
(SELECT
artist,
track,
SUM (views) as total_view,
DENSE_RANK() OVER(PARTITION BY artist ORDER BY SUM(views) DESC) as Rank
FROM spotify
GROUP BY 1, 2
ORDER BY 1, 3 DESC
)
SELECT * FROM ranking_artist
WHERE rank <= 3;


-- 12. Write a query to find tracks where the liveness score is above the average.

SELECT 	
	track, 
	artist,
	liveness
	FROM spotify
where liveness > (select avg(liveness) from spotify);


-- 13. Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

with CTE as
( 
select album, 
max(energy) as Max_Value,
min(energy) as Min_Value
from spotify
group by album)

select album, Max_Value - Min_Value as Difference 
from cte 
order by 2 DESC;

-- 14. Find tracks where the energy-to-liveness ratio is greater than 1.2. 

SELECT
  track,
  energy / liveness AS liveness_ratio
FROM spotify
WHERE liveness > 0
  AND energy IS NOT NULL
  AND liveness IS NOT NULL
  AND energy / liveness > 1.2
ORDER BY liveness_ratio DESC;

-- 15. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.

SELECT
  track,
  views,
  likes,
  SUM(likes) OVER (ORDER BY views desc) AS cumulative_likes
FROM spotify
ORDER BY views desc;
------------------------------------------------------------------------------------------------------

-- Query Optimisation 

explain analyze   --Execution Time: 27.296 ms & Planning Time: 3.454 ms
-- without index_artist, it is doing sequence scan. i.e. it is searching from top to bottom all rows
SELECT
artist,
track,
views
FROM spotify
WHERE artist = 'Gorillaz'
AND
most_played_on = 'Youtube'
ORDER BY stream DESC LIMIT 25;  
-- after creating index, it has directly grouped up the artists and it will directly jump to the selected artist 
create index artist_index on spotify(artist)
-- after indexing; Execution Time: 0.69 ms & Planning Time: 0.142 ms