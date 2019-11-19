/**
  1 sub select - inline view
 */
 WITH x AS (
    SELECT name, nation,
        (SELECT COUNT(1) FROM ranking r WHERE r.NAME = c.NAME) AS aantranking,
        (SELECT COUNT(1) FROM ranking r WHERE r.NAME = c.NAME AND r.DISCIPLINE = 'SL') AS aantsl
    FROM competitors c
 )
SELECT *
FROM x
WHERE aantranking >= 40 AND aantsl >= 10
ORDER BY nation, aantranking, aantsl;

/**
  1 sub select & where
 */
SELECT name,nation,(select count(1) from Ranking where cid=c.cid) aantranking,
(select sum(case when discipline ='SL' then 1 else 0  end)  aantslalom
                       from Ranking where cid=c.cid) aantSL
FROM Competitors c
where (select count(1) from Ranking where cid=c.cid) >=40
and
(select sum(case when discipline ='SL' then 1 else 0  end)  aantslalom
                       from Ranking where cid=c.cid) >=10
order by 2,3;

/**
  1 oplossing met joins
 */
select * from
(
SELECT c.name, nation,count(1) aantranking,
 sum(case when discipline ='SL' then 1 else 0  end)  aantslalom
FROM Competitors c
join Ranking r on c.cid=r.cid
group by c.name,nation
having count(1)>=40)  x
where aantslalom>=10
order by 2,3

/**

 */
SELECT name, nation, (select count(1) from Ranking where cid=c.cid) aantranking,
(select sum(case when discipline ='SL' then 1 else 0  end)  aantslalom
                       from Ranking where cid=c.cid) aantSL
FROM Competitors c
where (select count(1) from Ranking where cid=c.cid) >=40
and
(select sum(case when discipline ='SL' then 1 else 0  end)  aantslalom
                       from Ranking where cid=c.cid) >=10
order by 2,3;


/**
  2
 */
SELECT  parent, name, capital, population,
    CAST(100.*population/
         (
            SELECT SUM(population)
            FROM regios r2
            WHERE r2.parent = r.parent
          )
        AS NUMERIC(5,2)) "t.o.v.regio"
    ,CAST(100.*population/
          (
              SELECT SUM(l.POPULATION)
              FROM regios r2
              JOIN regios l ON l.hasc = r2.PARENT
              WHERE r2.HASC = r.PARENT
              GROUP BY l.NAME

          ) AS NUMERIC(5,2)) "t.o.v.land"
    ,CAST(area AS INT) area, elevation
FROM    regios r
WHERE   parent LIKE 'FR._'
ORDER BY parent, name;

/**
  3
 */
SELECT name, nation, finishaltitude
FROM resorts r1
WHERE FINISHALTITUDE >= (
        SELECT AVG(FINISHALTITUDE)
        FROM resorts r2
        WHERE r1.NATION = r2.NATION
)
ORDER BY nation, finishaltitude;

/**
  4.1 scalar sub
 */
SELECT name, weight
FROM competitors c
WHERE c.GENDER = 'M'
  AND weight IS NOT NULL
  AND 5 > (
    SELECT COUNT(1)
    FROM competitors cp
    WHERE cp.GENDER = c.GENDER
        AND c.WEIGHT < cp.WEIGHT
)
ORDER BY weight DESC;

/**
  4.2 join
 */
SELECT name, weight
FROM competitors c
WHERE c.GENDER = 'M'
  AND weight IS NOT NULL
  AND 5 > (
    SELECT COUNT(1)
    FROM competitors cp
    WHERE cp.GENDER = c.GENDER
        AND c.WEIGHT < cp.WEIGHT
)
ORDER BY weight DESC;

 /**
  4.3 inline view
 */
WITH x AS (
    SELECT name, weight, rank() OVER (ORDER BY WEIGHT DESC) AS rank
    FROM competitors c
    WHERE gender = 'M' AND weight IS NOT NULL
)
SELECT name, weight
FROM x
WHERE rank <= 5;

/**
  5
 */
WITH x AS (
    SELECT (
           SELECT (
              SELECT name
              FROM regios l
              WHERE r.PARENT = l.hasc
            )
           FROM regios r
           WHERE r.HASC = t.HASC
    )  AS continent,
    count(1) as aant
    FROM taalgebruik t
    GROUP BY hasc
),
y AS (
    SELECT continent, SUM(aant) AS aant
    FROM x
    GROUP BY continent
    ORDER BY aant DESC
)
SELECT *
FROM y
WHERE (SELECT MAX(aant) FROM y) = aant
        OR
      (SELECT MIN(aant) FROM y) = aant;

/**
  6
 */
WITH x AS (
    SELECT hasc1, hasc2, length
    FROM grenzen
        UNION
    SELECT hasc2, hasc1, length
    FROM grenzen
), y AS (
    SELECT *
    FROM x
    WHERE x.HASC1 IN (
        SELECT hasc
        FROM REGIOS
        WHERE parent = 'EUR'
    )
), z AS (
    SELECT hasc1, hasc2, length,
           (SELECT COUNT(1)
            FROM y cp
            WHERE cp.HASC1 = y.HASC1
              AND cp.length >= y.length) as rang
    FROM y
)
SELECT
    (SELECT name FROM regios WHERE z.HASC1 = regios.HASC) AS hasc1,
    (SELECT name FROM regios WHERE z.HASC2 = regios.HASC) AS hasc2,
    length,
    length - (SELECT MAX(length) FROM z cmp WHERE z.hasc1 = cmp.hasc1) AS verschil
FROM z
WHERE rang <= 3
ORDER BY hasc1, length DESC;

/**
  7
 */
WITH x AS (
    SELECT
       (SELECT name FROM regios c WHERE c.hasc = (SELECT parent FROM regios l WHERE l.hasc = t.HASC)) AS continent,
       iso,
       CAST(gebruik *
            COALESCE((SELECT population FROM regios r WHERE r.HASC = t.hasc), 0)
            AS INT)
        AS sprekers
    FROM taalgebruik t
)
SELECT continent,
       (SELECT taal FROM talen c WHERE c.ISO = x.ISO) AS taal,
       SUM(sprekers) as aant
FROM x
GROUP BY continent, iso
HAVING SUM(sprekers) > 9999999
ORDER BY continent, aant DESC;

/**
  8
 */
SELECT   p.name,
         (SELECT COUNT(1) FROM regios a WHERE a.parent = p.HASC) AS "#k",
         (SELECT COUNT(1)
            FROM regios g
            WHERE p.hasc = (SELECT parent FROM regios a WHERE a.hasc = g.parent)
         ) AS "#kk"
FROM     regios p
WHERE (SELECT parent FROM regios q WHERE q.HASC = p.PARENT) = 'BE'
ORDER BY p.name;

/**
  9
 */
WITH  x AS ( SELECT  name, nation, round(months_between(sysdate,birthdate)/12) leeftijd, weight
              ,rank() over(partition by round(months_between(sysdate,birthdate)/12) order by weight) as rank
            FROM    Competitors
            WHERE   gender = 'L' AND weight IS NOT NULL
)
SELECT name,nation, leeftijd as jaar, weight,
       (SELECT MIN(name) FROM x xx WHERE x.leeftijd = xx.leeftijd AND rank = 1) AS smallname,
       (SELECT nation FROM x xx WHERE name = (SELECT MIN(name) FROM x xx WHERE rank = 1 AND x.leeftijd = xx.leeftijd) )AS smallnation
       FROM x
       WHERE rank<=5
       ORDER BY leeftijd,weight;

/**
  10.1
 */
WITH x as (SELECT racedate,resort,discipline,name
           FROM   Races
           JOIN   Results ON Races.rid=Results.rid and rank=1
           WHERE  gender='M'
        ),
y AS (
    SELECT resort, name, discipline, racedate,
       (SELECT MAX(z.racedate)
        FROM x z
        WHERE z.RESORT = x.RESORT
           AND z.NAME = x.NAME
           AND z.DISCIPLINE = x.DISCIPLINE
           AND z.RACEDATE < x.RACEDATE
        ) AS laatste
    FROM x
    WHERE racedate IS NOT NULL
),
z AS (
    SELECT resort, name, discipline,
        racedate,
        laatste,
        (SELECT MAX(z.racedate)
        FROM x z
        WHERE z.RESORT = y.RESORT
           AND z.NAME = y.NAME
           AND z.DISCIPLINE = y.DISCIPLINE
           AND z.RACEDATE < y.laatste
        ) AS voorlaatste
    FROM y
    WHERE y.laatste IS NOT NULL
)
SELECT resort, name, discipline DI,
       TO_CHAR(racedate, 'DD-MM-YY') AS racedate,
       TO_CHAR(laatste, 'DD-MM-YY') AS laatste,
       TO_CHAR(laatste, 'DD-MM-YY') AS voorlaatste
FROM z
WHERE z.voorlaatste IS NOT NULL
ORDER BY resort, name, discipline;

/**
  10.2
 */
WITH x as (SELECT racedate,resort,discipline,name
           FROM   Races
           JOIN   Results ON Races.rid=Results.rid and rank=1
           WHERE  gender='M'
        ),
y AS (
    SELECT resort, name, discipline, racedate,
       (SELECT MAX(z.racedate)
        FROM x z
        WHERE z.RESORT = x.RESORT
           AND z.NAME = x.NAME
           AND z.DISCIPLINE = x.DISCIPLINE
           AND z.RACEDATE < x.RACEDATE
        ) AS laatste
    FROM x
    WHERE racedate IS NOT NULL
),
z AS (
    SELECT resort, name, discipline,
        racedate,
        laatste,
        (SELECT MAX(z.racedate)
        FROM x z
        WHERE z.RESORT = y.RESORT
           AND z.NAME = y.NAME
           AND z.DISCIPLINE = y.DISCIPLINE
           AND z.RACEDATE < y.laatste
        ) AS voorlaatste
    FROM y
    WHERE y.laatste IS NOT NULL
)
SELECT resort, name, discipline DI,
       TO_CHAR(racedate, 'DD-MM-YY') AS racedate,
       TO_CHAR(laatste, 'DD-MM-YY') AS laatste,
       TO_CHAR(voorlaatste, 'DD-MM-YY') AS voorlaatste
FROM z
WHERE z.voorlaatste IS NOT NULL
      AND 0 = (SELECT COUNT(1)
               FROM x
               WHERE z.RACEDATE < x.RACEDATE
                AND z.RESORT = x.RESORT
                AND z.NAME = x.NAME
                AND z.DISCIPLINE = x.DISCIPLINE
          )
ORDER BY resort, name, discipline;
