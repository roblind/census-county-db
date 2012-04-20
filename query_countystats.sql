select state, county, popu_pct_chg_10yr 
from fips_st_cnty a, countystats b 
where a.fipscd = b.fipscd 
order by 3 desc limit 20;

select state, county, popu_pct_female, popu_2010
from fips_st_cnty a, countystats b 
where a.fipscd = b.fipscd 
and persons_per_sq_mi > 800
order by 3 desc limit 20;

select avg(persons_per_sq_mi) from countystats;

select sum(popu_2010)/sum(area_sq_mi) from countystats;

select state, county from fips_st_cnty where fipscd in (select fipscd from countystats where persons_per_sq_mi = (select min(persons_per_sq_mi) from countystats where persons_per_sq_mi > 0));


select state, county, asian_owned_firms_pct from fips_st_cnty a, countystats b where a.fipscd = b.fipscd and a.fipscd in 
(select fipscd from countystats where asian_owned_firms_pct > (select max(asian_owned_firms_pct) - 30 from countystats)) order by 3 desc;
+----------+----------+-----------------------+
| state    | county   | asian_owned_firms_pct |
+----------+----------+-----------------------+
| Hawaii   | Honolulu |                  56.6 |
| Hawaii   | Kauai    |                  35.5 |
| Hawaii   | Hawaii   |                  31.9 |
| Hawaii   | Maui     |                  30.3 |
| New York | Queens   |                  29.0 |
+----------+----------+-----------------------+
5 rows in set (0.06 sec)


-- query to find missing countystats rows by FIPS code
select fipscd from fips_st_cnty a where not exists (select fipscd from countystats b where a.fipscd = b.fipscd);