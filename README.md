# Spotify Advanced SQL Project and Query Optimization

![Spotify_Data_Analysis Dashboard](spotify_logo.jpg)

## Dataset Source
The dataset used in this project is publicly available on Kaggle:

🔗 **Spotify Dataset on Kaggle**  
https://www.kaggle.com/datasets/sanjanchaudhari/spotify-dataset

**Project Category:** Advanced  
**Dataset:** Spotify Track & Streaming Dataset (Kaggle)

---

## Overview
This project focuses on in-depth analysis of a Spotify dataset containing detailed information about tracks, albums, artists, and streaming performance. Using **PostgreSQL**, the project demonstrates an end-to-end analytical workflow—from understanding a denormalized dataset to writing optimized SQL queries across multiple difficulty levels. The primary objective is to strengthen advanced SQL concepts while extracting meaningful, business-relevant insights from real-world music data.

---

## Database Schema
The dataset is stored in a single table designed to capture both audio features and engagement metrics. Below is the schema used for analysis:

```sql
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```

---

## Project Workflow

### 1. Data Exploration
Before performing any analysis, the dataset was explored to understand its structure, distributions, and key attributes. The data includes artist and album metadata along with multiple audio features such as danceability, energy, tempo, and liveness, making it suitable for both descriptive and advanced analytical queries.

### 2. Querying the Data
Once the data was loaded, a wide range of SQL queries were written and categorized by complexity to gradually build proficiency.

#### Easy Queries
- Basic filtering and selection
- Simple aggregations using `COUNT`, `SUM`, and `AVG`

#### Medium Queries
- Grouped aggregations by artist and album
- Conditional aggregations using `CASE`
- Comparison-based filtering

#### Advanced Queries
- Window functions for ranking and cumulative metrics
- Common Table Expressions (CTEs)
- Subqueries and analytical comparisons

---

## Query Optimization Technique

To enhance query performance, we followed a structured query optimization approach using PostgreSQL’s execution analysis tools.

### Initial Query Performance Analysis using `EXPLAIN`
- The performance of a query filtering data based on the `artist` column was first analyzed using the `EXPLAIN` command.
- Observed performance metrics before optimization:
  - **Execution Time (E.T.)**: 7 ms  
  - **Planning Time (P.T.)**: 0.17 ms
- Below is the screenshot of the execution plan **before index creation**:
  - *EXPLAIN Before Index*

---

### Index Creation on the `artist` Column
- To optimize query performance, an index was created on the `artist` column to speed up lookup operations.
- SQL command used:
  ```sql
  CREATE INDEX idx_artist ON spotify(artist);

---

## Practice Questions

### Easy Level
1. Retrieve tracks with more than 1 billion streams.
```sql
  SELECT track, stream FROM SPOTIFY
  where stream > 1000000000;
  ```
2. List all albums along with their respective artists.
```sql
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
  ```
3. Calculate the total number of comments for licensed tracks.
```sql
  select sum(comments) as Total_Comments
  from spotify
  where licensed = 'true'; -- simply licensed = true can also work
  ```
4. Identify tracks that belong to the `single` album type.
```sql
 select * from spotify 
 where album_type ilike 'single'  -- used ilike because we don't know that whether anywhere single is present in upper and lower case also

  ```
5. Count the total number of tracks released by each artist.
```sql
  select artist, count(distinct track) as Total_No_of_Tracks
  from spotify
  group by artist  
  order by 2 DESC;
  ```

### Medium Level
1. Compute the average danceability for each album.
```sql
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
  ```
2. Find the top 5 tracks with the highest energy values.
```sql
  select track,
  max(energy) 
  from spotify
  group by track
  order by max(energy) desc
  limit 5;
  ```
3. List tracks with their views and likes where an official video is available.
```sql
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
  ```
4. Calculate total views aggregated at the album level.
```sql
  select 
  album, 
  track, 
  sum(views) as Total_Views
  from spotify
  group by album, track
  order by 3 desc;
  ```
5. Identify tracks streamed more on Spotify than on YouTube.
```sql
  select track, 
  COALESCE(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
  COALESCE(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
  from spotify 
  group by 1;
  -- We are also getting NULL values, so for dealing with that we use COALESCE
  -- NOTE: We can't use the above query directly because we have used case in the coalesce lines....
  -- we will save the above fulll query in subquery format.

  -- Method - 2
  select * from 
  (select track, 
  COALESCE(sum(case when most_played_on = 'Youtube' then stream end),0) as streamed_on_youtube,
  COALESCE(sum(case when most_played_on = 'Spotify' then stream end),0) as streamed_on_spotify
  from spotify 
  group by 1) as t1
  where streamed_on_youtube < streamed_on_spotify
  and streamed_on_youtube <> 0;  -- != 0 can also be used 
  ```
### Advanced Level
1. Determine the top 3 most-viewed tracks per artist using window functions.
```sql
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
  ```
2. Find tracks where the liveness score exceeds the overall average.
```sql
  SELECT 	
  track, 
  artist,
  liveness
  FROM spotify
  where liveness > (select avg(liveness) from spotify);
  ```
3. Use a CTE to calculate the difference between maximum and minimum energy levels per album.
```sql
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
  ```
4. Identify tracks with an energy-to-liveness ratio greater than 1.2.
```sql
  SELECT
  track,
  energy / liveness AS liveness_ratio
  FROM spotify
  WHERE liveness > 0
  AND energy IS NOT NULL
  AND liveness IS NOT NULL
  AND energy / liveness > 1.2
  ORDER BY liveness_ratio DESC;
  ```
5. Compute the cumulative sum of likes ordered by total views using window functions.
```sql
  SELECT
  track,
  views,
  likes,
  SUM(likes) OVER (ORDER BY views desc) AS cumulative_likes
  FROM spotify
  ORDER BY views desc;
  ```
---

## Technology Stack
- **Database:** PostgreSQL  
- **SQL Concepts:** DDL, DML, Aggregations, Joins, CTEs, Window Functions, Indexing  
- **Tools:** pgAdmin 4 / PostgreSQL CLI

---

## How to Run the Project
1. Install PostgreSQL and a SQL client such as pgAdmin.
2. Create the database and table using the provided schema.
3. Import the dataset into PostgreSQL.
4. Execute the SQL queries to explore insights and solve the practice problems.
5. Use `EXPLAIN ANALYZE` to experiment with query optimization techniques.

---

## Future Enhancements
- Build dashboards using **Power BI** or **Tableau** based on query outputs.
- Expand the dataset to test scalability and performance.
- Explore advanced indexing and partitioning strategies.

---

## License
This project is licensed under the **MIT License** and is intended for learning and portfolio purposes.

