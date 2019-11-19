/**
  1.a
 */
WITH x as (
    SELECT   nation,weight,count(*) aantal
    FROM     Competitors c
    WHERE    weight is not null
    group by nation,weight
)
SELECT *
FROM x
WHERE x.aantal >= ALL (SELECT aantal FROM x xx WHERE xx.nation = x.nation)
ORDER BY aantal DESC;

/**
  1.b
 */
WITH x as (
    SELECT   nation,weight,count(*) aantal
    FROM     Competitors c
    WHERE    weight is not null
    group by nation,weight
)
SELECT *
FROM x
WHERE NOT x.aantal < ANY (SELECT aantal FROM x xx WHERE xx.nation = x.nation)
ORDER BY aantal DESC;

/**
  1.FILTER
 */
 WITH x as (
    SELECT   nation,weight,count(*) aantal
    FROM     Competitors c
    WHERE    weight is not null
    group by nation,weight
), y AS (
    SELECT nation, weight, aantal
    FROM x
    WHERE x.aantal >= ALL (SELECT aantal FROM x xx WHERE xx.nation = x.nation)
)
SELECT *
FROM y
WHERE 5 >= (
        SELECT COUNT(1)
        FROM y yy
        WHERE y.aantal < yy.aantal
    )
ORDER BY aantal DESC;

/**
  2.1
 */
WITH x AS (
     SELECT name, weight
    FROM competitors c
    WHERE weight IS NOT NULL AND gender = 'M'
)
SELECT *
FROM x
WHERE name NOT IN (
    SELECT x1.name
    FROM x x1
    JOIN x x2 ON x2.WEIGHT > x1.WEIGHT
    JOIN x x3 ON x3.WEIGHT > x2.WEIGHT
)
ORDER BY weight DESC;

/**
  2.2
 */
WITH x AS (
    SELECT name, weight
    FROM competitors c
    WHERE weight IS NOT NULL AND gender = 'M'
)
SELECT x.name, x.WEIGHT
FROM x
JOIN x x2 ON x.WEIGHT < x2.WEIGHT
WHERE x.name NOT IN (
    SELECT x1.name
    FROM x x1
    JOIN x x2 ON x2.WEIGHT > x1.WEIGHT
    JOIN x x3 ON x3.WEIGHT > x2.WEIGHT
)
ORDER BY x.weight DESC;

/**
  3
 */
WITH  u AS ( SELECT   EXTRACT(YEAR FROM racedate + 183) season, discipline, name
             FROM     results r
                 JOIN races w ON r.rid = w.rid
             WHERE    rank = 1 AND discipline NOT IN ( 'P', 'KB' )
                          AND   EXTRACT(YEAR FROM racedate + 183) < 2011 )
    , v AS ( SELECT   w.*, COUNT(1) - 1 overwinningen
             FROM     ( SELECT season, discipline, name
                        FROM   u
                           UNION ALL
                        SELECT *
                        FROM   ( SELECT DISTINCT season     FROM   u ) x
                              ,( SELECT DISTINCT discipline FROM   u ) y
                              ,( SELECT DISTINCT name       FROM   u ) z
                      ) w
             GROUP BY season, discipline, name)
SELECT name, season
FROM v
GROUP BY name, season
HAVING 0 < ALL(
        SELECT v2.overwinningen
        FROM v v2
        WHERE v2.name = v.name
            AND v2.season = v.season
    )
ORDER BY season DESC;
