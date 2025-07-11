with streak as (
	select 
	actor,
	actorid,
	quality_class,
	is_active,
	year,
	lag(is_active,1) over (partition by actorid order by year) <> is_active
	or lag(is_active,1) over (partition by actorid order by year) is null 
	as did_change1,
	lag(quality_class,1) over (partition by actorid order by year) <> quality_class
	or lag(quality_class,1) over (partition by actorid order by year) is null 
	as did_change2
from actors
where year<=2020
),
streak_identifier as(
select * ,
	sum(case when did_change1 then 1 else 0 end)
	over (partition by actorid order by year) as streak_identifier1,
	sum(case when did_change2 then 1 else 0 end)
	over (partition by actorid order by year) as streak_identifier2	
From streak
),
aggregated as (
select 
	actor,
	actorid,
	quality_class,
	is_active,
	streak_identifier1,
	streak_identifier2,
	min(year) as start_year,
	max(year) as end_year,
	2020 as year
from streak_identifier
GROUP BY actor,actorid,quality_class,is_active,streak_identifier1,streak_identifier2
order by actorid,streak_identifier1,streak_identifier2
) 
insert into actors_scd_table(
select 
	actor,
	actorid,
	quality_class,
	is_active,
	start_year,
	end_year,
	year
from aggregated
)

