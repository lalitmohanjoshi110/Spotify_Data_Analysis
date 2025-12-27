# Spotify Advanced SQL Project and Query Optimization

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

## Query Optimization
To improve query efficiency, performance tuning techniques were applied on frequently queried columns.

- **Initial Performance Analysis**  
  Query execution was first analyzed using `EXPLAIN ANALYZE`, which revealed higher execution and planning times when filtering on non-indexed columns.

- **Index Creation**  
  An index was created on the `artist` column to speed up lookups and reduce scan time:
  ```sql
  CREATE INDEX idx_artist ON spotify(artist);
  ```

- **Post-Optimization Results**  
  After indexing, the same query showed a significant reduction in execution time, demonstrating how indexing can drastically improve query performance on large datasets.

This section highlights the importance of understanding execution plans and applying indexing strategically in analytical SQL projects.

---

## Practice Questions

### Easy Level
1. Retrieve tracks with more than 1 billion streams.
2. List all albums along with their respective artists.
3. Calculate the total number of comments for licensed tracks.
4. Identify tracks that belong to the `single` album type.
5. Count the total number of tracks released by each artist.

### Medium Level
1. Compute the average danceability for each album.
2. Find the top 5 tracks with the highest energy values.
3. List tracks with their views and likes where an official video is available.
4. Calculate total views aggregated at the album level.
5. Identify tracks streamed more on Spotify than on YouTube.

### Advanced Level
1. Determine the top 3 most-viewed tracks per artist using window functions.
2. Find tracks where the liveness score exceeds the overall average.
3. Use a CTE to calculate the difference between maximum and minimum energy levels per album.
4. Identify tracks with an energy-to-liveness ratio greater than 1.2.
5. Compute the cumulative sum of likes ordered by total views using window functions.

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

