CREATE TYPE actor_scd_type AS (
                    quality_class quality_class,
                    is_active boolean,
                    start_year INTEGER,
                    end_year INTEGER
                        );


		
-- increntally adding data to SCD
-- get last year data
with last_year_scd as(
	select * from actors_scd_table
	where year=2020
	AND end_year=2020
),
-- get historical data up until last year
historical_scd as(
	select 
	   actor,
	   actorid,
	   quality_class,
	   is_active,
	   start_year,
	   end_year
	from actors_scd_table
	WHERE year = 2020
	AND end_year < 2020
),
-- this year data from actors to incrementally add to scd table
this_year_data as(
	select * from actors
		where year=2021
),
-- get the unchanged records by comparing last year and this year data
unchanged_records as (
	select
		ty.actor,
		ty.actorid,
		ty.quality_class,
		ty.is_active,
		ly.start_year,
		ty.year as end_year
	from this_year_data ty
	left join last_year_scd ly
	on ty.actorid = ly.actorid
	where ty.quality_class = ly.quality_class
	and ty.is_active = ly.is_active
),
-- get the changed records
changed_records as(
	select 
		ty.actor,
		ty.actorid,
		UNNEST(ARRAY[
	                    ROW(
	                        ly.quality_class,
	                        ly.is_active,
	                        ly.start_year,
	                        ly.end_year
	
	                        )::actor_scd_type,
	                    ROW(
	                        ty.quality_class,
	                        ty.is_active,
	                        ty.year,
	                        ty.year
	                        )::actor_scd_type
	                ]) as records 
	from this_year_data ty
	left join last_year_scd ly
	on ty.actorid=ly.actorid
	where (ty.quality_class<>ly.quality_class
	or ty.is_active <> ly.is_active)
),
-- unnest the changed records to union
unnested_changed_records AS (
         SELECT actor,actorid,
                (records::actor_scd_type).quality_class,
                (records::actor_scd_type).is_active,
                (records::actor_scd_type).start_year,
                (records::actor_scd_type).end_year
                FROM changed_records
         ),	 
-- get the new actors thats been added newly
new_records as (
	select 
		 ty.actor,
		 ty.actorid,
		ty.quality_class,
		ty.is_active,
		ty.year AS start_end,
		ty.year AS end_year
	from this_year_data ty
	left join last_year_scd ly
	on ty.actorid = ly.actorid
	where ly.actorid is null
)
-- now union all 
SELECT *
FROM historical_scd

UNION ALL

SELECT *
FROM unchanged_records

UNION ALL

SELECT *
FROM unnested_changed_records

UNION ALL

SELECT *
FROM new_records

