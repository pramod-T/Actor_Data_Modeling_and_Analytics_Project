DO $$
DECLARE
    yr INT;
BEGIN
    FOR yr IN 1969..2021 LOOP
        WITH last_year AS (
            SELECT * FROM actors WHERE year = yr - 1
        ),
        this_year AS (
            SELECT * FROM actor_films WHERE year = yr
        ),
        joined_data AS (
            SELECT
                COALESCE(ly.actor, ty.actor) AS actor,
                COALESCE(ly.actorid, ty.actorid) AS actorid,
                COALESCE(ty.year, ly.year + 1) AS year,
                ty.rating,
                ty.year IS NOT NULL AS is_active,
                COALESCE(ly.films, ARRAY[]::films[]) AS previous_films,
                ty.film,
                ty.votes,
                ty.filmid,
                ly.quality_class
            FROM last_year ly
            FULL OUTER JOIN this_year ty ON ly.actorid = ty.actorid
        )
        INSERT INTO actors (actor, actorid, films, quality_class, year, is_active)
        SELECT
            actor,
            actorid,
            COALESCE(
                ARRAY_AGG(
                    ROW(film, votes, rating, filmid)::films
                ) FILTER (WHERE film IS NOT NULL),
                ARRAY[]::films[]
            ) || previous_films AS films,
            CASE 
                WHEN AVG(rating) > 8 THEN 'star'
                WHEN AVG(rating) > 7 THEN 'good'
                WHEN AVG(rating) > 6 THEN 'average'
                ELSE 'bad'
            END::quality_class,
            year,
            MAX(is_active::INT)::BOOLEAN AS is_active
        FROM joined_data
        GROUP BY actor, actorid, year, previous_films;
    END LOOP;
END $$;


