-- 1. Total number of active actors by year
SELECT year, COUNT(*) AS active_actor_count
FROM actors
WHERE is_active = true
GROUP BY year
ORDER BY year;

-- 2. Distribution of quality classes by year
SELECT year, quality_class, COUNT(*) AS count
FROM actors
GROUP BY year, quality_class
ORDER BY year, quality_class;

-- 3. Actors who improved from 'average' to 'star'
WITH changes AS (
  SELECT
    actorid,
    actor,
    year,
    quality_class,
    LAG(quality_class) OVER (PARTITION BY actorid ORDER BY year) AS prev_class
  FROM actors
)
SELECT actorid, actor, year, prev_class, quality_class
FROM changes
WHERE prev_class = 'average' AND quality_class = 'star';

-- 4. Longest continuous active streak per actor
WITH streaks AS (
  SELECT *,
    ROW_NUMBER() OVER (PARTITION BY actorid ORDER BY year) -
    ROW_NUMBER() OVER (PARTITION BY actorid, is_active ORDER BY year) AS grp
  FROM actors
  WHERE is_active = true
),
grouped AS (
  SELECT actorid, actor, COUNT(*) AS active_years
  FROM streaks
  GROUP BY actorid, actor, grp
)
SELECT actorid, actor, MAX(active_years) AS longest_active_streak
FROM grouped
GROUP BY actorid, actor
ORDER BY longest_active_streak DESC
LIMIT 10;

-- 5. Quality improvement trends
SELECT actorid, actor, MIN(year) AS first_star_year
FROM actors
WHERE quality_class = 'star'
GROUP BY actorid, actor
ORDER BY first_star_year;

-- 6. Comeback actors: inactive then became active again
WITH activeness AS (
  SELECT *,
    LAG(is_active) OVER (PARTITION BY actorid ORDER BY year) AS prev_active
  FROM actors
)
SELECT actorid, actor, year
FROM activeness
WHERE prev_active = false AND is_active = true;

---7. Find top 10 actors who sustained star quality the longest across their career.

SELECT actorid, actor, SUM(end_year - start_year + 1) AS total_star_years
FROM actors_scd_table
WHERE quality_class = 'star'
GROUP BY actorid, actor
ORDER BY total_star_years DESC
LIMIT 10;


---8.Identifies actors whose final known career segment was as a star

with rn as(
    SELECT *, ROW_NUMBER() OVER (PARTITION BY actorid ORDER BY end_year DESC) AS rn
    FROM actors_scd_table
)
SELECT actorid, actor, quality_class, end_year
FROM rn
WHERE rn = 1 AND quality_class = 'star';
