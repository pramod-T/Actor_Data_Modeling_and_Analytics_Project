
create type films as(
	films text,
	votes integer,
	rating real,
	filmid text	
);

create type quality_class as 
enum ('star','good','average','bad');

create table actors(
	actor text,
	actorid text,
	films films[],
	quality_class quality_class,
	year integer,
	is_active Boolean,
	primary key(actorid,year)
);


