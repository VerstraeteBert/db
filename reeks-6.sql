/**
  1
 */
WITH  p AS ( SELECT DISTINCT EXTRACT(YEAR FROM racedate) jaar
             FROM Races ),
      q AS ( SELECT  jaar, jaar - 1900 j, mod(jaar - 1900, 19) a, FLOOR(( 7 * mod(jaar - 1900, 19) + 1 ) / 19) b
             FROM    p ),
      r AS ( SELECT  jaar, j, a, b, mod(11 * a + 4 - b, 29) c
             FROM    q ),
      s AS ( SELECT  jaar, 25 - c - mod(j + FLOOR(j / 4) + 31 - c, 7) pasen
             FROM    r )
SELECT   jaar, TO_CHAR(TO_TIMESTAMP('01-04' || CAST(jaar AS CHAR(4)), 'DD-MM-RRRR') + pasen - 1, 'DD-MM-YYYY') pasen
FROM     s
ORDER BY jaar;

/**
  2
 */
WITH x AS (
   SELECT
       lev2,
       MAX(elevation) AS maxhoogte,
       MIN(elevation) AS minhoogte,
       MAX(elevation) - MIN(elevation) AS hoogteverschil,
       RANK() OVER (ORDER BY MAX(elevation) - MIN(ELEVATION)) AS rank
    FROM cities
    WHERE iso = 'BE' AND LEV2 IS NOT NULL
    GROUP BY lev2
)
SELECT *
FROM x
WHERE rank <= 4;

/**
  3.1
 */
 WITH x AS (
     SELECT hasc1 AS hasc
    FROM grenzen
    WHERE hasc1 LIKE 'BE.%' AND hasc2 LIKE 'BE.%'
         UNION ALL
    SELECT hasc2 AS hasc
    FROM grenzen
    WHERE hasc1 LIKE 'BE.%' AND hasc2 LIKE 'BE.%'
 )
SELECT REGIOS.NAME, COUNT(1) AS aant
FROM x
JOIN regios ON regios.HASC = x.HASC
GROUP BY REGIOS.NAME
HAVING COUNT(1) >= 10
ORDER BY aant DESC;

/**
  3.2
 */
 WITH x AS (
     SELECT hasc1, hasc2
    FROM grenzen
    WHERE hasc1 LIKE 'BE.%' AND hasc2 LIKE 'BE.%'
         UNION ALL
    SELECT hasc2, hasc1
    FROM grenzen
    WHERE hasc1 LIKE 'BE.%' AND hasc2 LIKE 'BE.%'
 ),
y AS (
    SELECT x.HASC1, x.HASC2, COUNT(1) OVER(PARTITION BY x.HASC1) AS aant
    FROM x
),
z AS (
    SELECT y.HASC1, y.HASC2
    FROM y
    WHERE aant >= 10
)
SELECT r1.NAME, r2.NAME, RANK() OVER (PARTITION BY r1.NAME ORDER BY r2.NAME) AS rang
FROM y
 JOIN regios r1 ON r1.HASC = y.HASC1
 JOIN regios r2 ON r2.HASC = y.HASC2
WHERE aant >= 10
ORDER BY r1.NAME, rang;

/**
  4
 */
 WITH x AS (
     SELECT gender,
       discipline,
       name,
       rank() over (partition by gender, discipline order by points DESC) as rang
    FROM ranking
    WHERE SEASON = 2007
 )
SELECT gender, discipline,
       MAX(CASE WHEN rang = 1 THEN name ELSE '' END) AS "1",
       MAX(CASE WHEN rang = 2 THEN name ELSE '' END) AS "2",
       MAX(CASE WHEN rang = 3 THEN name ELSE '' END) AS "3"
FROM x
WHERE rang <= 3
GROUP BY gender, discipline
ORDER BY gender, discipline;

/**
  5
 */
 WITH x AS (
     SELECT
       EXTRACT(YEAR FROM racedate + 183) AS seizoen,
       DISCIPLINE,
       COUNT(1) AS aant
    FROM races
    WHERE DISCIPLINE IN ('DH', 'SG', 'GS', 'SL')
        AND EXTRACT(YEAR FROM racedate + 183) > 1999
    GROUP BY CUBE(EXTRACT(YEAR FROM RACEDATE + 183), DISCIPLINE)
 )
SELECT coalesce(CAST(seizoen AS char(4)), 'totaal') AS seizoen,
       MAX(CASE WHEN DISCIPLINE = 'DH' THEN aant ELSE 0 END) AS DH,
       MAX(CASE WHEN DISCIPLINE = 'SG' THEN aant ELSE 0 END) AS SG,
       MAX(CASE WHEN DISCIPLINE = 'GS' THEN aant ELSE 0 END) AS GS,
       MAX(CASE WHEN DISCIPLINE = 'SL' THEN aant ELSE 0 END) AS SL,
       MAX(aant) AS totaal
FROM x
GROUP BY seizoen
ORDER BY seizoen;

/**
  6
 */
 WITH x AS (
     SELECT 1 AS maand
 FROM DUAL
     UNION
 SELECT 2 AS maand
 FROM DUAL
     UNION
SELECT 3 AS maand
 FROM DUAL
     UNION
SELECT 4 AS maand
 FROM DUAL
     UNION
SELECT 5 AS maand
 FROM DUAL
     UNION
SELECT 6 AS maand
 FROM DUAL
     UNION
SELECT 7 AS maand
 FROM DUAL
     UNION
SELECT 8 AS maand
 FROM DUAL
     UNION
 SELECT 9 AS maand
 FROM DUAL
     UNION
 SELECT 10 AS maand
 FROM DUAL
     UNION
 SELECT 11 AS maand
 FROM DUAL
     UNION
 SELECT 12 AS maand
 FROM DUAL
 ),
y AS (
    SELECT 'L' AS gender
    FROM DUAL
        UNION ALL
    SELECT 'M'
    FROM DUAL
),
z AS (
    SELECT
    CAST(EXTRACT(MONTH FROM racedate) AS int) AS maand,
    ra.GENDER
    FROM races ra
        JOIN results re ON re.RID = ra.RID
            UNION ALL
    SELECT *
    FROM x,y
)
SELECT maand,
       COUNT(CASE WHEN gender = 'L' THEN 1 END) - 1 AS "L",
       COUNT(CASE WHEN gender = 'M' THEN 1 END) - 1 AS "M",
       COUNT(1) - 2 AS "#"
 FROM z
GROUP BY maand
ORDER BY maand;


/**
  7
 */
WITH x AS (
   SELECT coalesce(lev2, lev1) AS provincie,
       elevation
    FROM cities
    WHERE ISO = 'BE' AND elevation IS NOT NULL AND LEV1 IS NOT NULL
),
Y AS (
    SELECT provincie,
       elevation,
       ROUND(AVG(elevation) OVER (PARTITION BY provincie), 2) AS gemiddelde,
       2 * ROW_NUMBER() OVER (PARTITION BY provincie ORDER BY ELEVATION)
        - 1 - COUNT(1) OVER (PARTITION BY provincie) AS rang
    FROM x
)
SELECT
       provincie,
       MAX(gemiddelde) AS gemiddelde,
       AVG(ELEVATION) AS mediaan
FROM y
WHERE rang BETWEEN -1 AND 1
GROUP BY provincie
ORDER BY gemiddelde;

/**
  8
 */
 WITH x AS (
     SELECT elevation,
       dense_rank()  OVER (ORDER BY elevation) - elevation as groep
    FROM cities
    WHERE ISO = 'IS' AND elevation IS NOT NULL AND LEV1 IS NOT NULL
)
SELECT
       MIN(ELEVATION) AS elevation,
       CASE WHEN MAX(elevation) != MIN(ELEVATION) THEN MAX(ELEVATION) END " "
FROM x
GROUP BY groep
ORDER BY elevation;

/**
  9
 */
WITH x AS (
    SELECT lev1, lev2, MAX(elevation) AS max
    FROM cities
    WHERE ISO = 'BE'
      AND lev2 IS NOT NULL
      AND LEV1 IS NOT NULL
    GROUP BY lev1, lev2
    ORDER BY lev1, lev2
),
y AS (
    SELECT lev1, lev2,
       MIN(max) OVER (PARTITION BY lev1) AS min,
       max
    FROM x
),
Z AS (
    SELECT lev1, lev2,
       max - min AS verschil
    FROM y
)
SELECT
    CASE WHEN verschil = 0 THEN lev1 ELSE ' ' END AS gewest,
    lev2 AS provincie,
    verschil
FROM z
ORDER BY lev1, verschil;

/**
  10
 */
 WITH x AS (
    SELECT r.parent,r.hasc,r.name,r.area ,m.afkorting
        FROM regios  r
       JOIN members m ON r.hasc=m.hasc
    WHERE m.afkorting IN ( 'G-3','G-5','G-6','G-7','G-8')
),
y AS (
    SELECT parent,
       name,
       ROUND(area, 0) AS area,
       RANK() OVER (PARTITION BY parent ORDER BY area DESC) AS rang,
       COUNT(AFKORTING) AS "#G",
       MAX(CASE WHEN afkorting = 'G-3' THEN 'x' ELSE '' END) AS "G-3",
       MAX(CASE WHEN afkorting = 'G-5' THEN 'x' ELSE '' END) AS "G-5",
       MAX(CASE WHEN afkorting = 'G-6' THEN 'x' ELSE '' END) AS "G-6",
       MAX(CASE WHEN afkorting = 'G-7' THEN 'x' ELSE '' END) AS "G-7",
       MAX(CASE WHEN afkorting = 'G-8' THEN 'x' ELSE '' END) AS "G-8"
    FROM x
    GROUP BY parent, name, area
)
SELECT
       CASE WHEN rang = 1 THEN to_char(parent) ELSE '' END AS "parent",
       name,
       area
       "#G",
       "G-3",
       "G-5",
       "G-6",
       "G-7",
       "G-8"
 FROM y
ORDER BY parent, area DESC;

/**
  11
 */
WITH x AS (
    SELECT p.name provincie,
       a.name arrondissement,
       c.POPULATION stadpop,
       c.ELEVATION stadelev,
       CASE WHEN c.POPULATION = MAX(c.POPULATION) OVER (PARTITION BY a.PARENT) THEN c.ELEVATION END maxelev,
       a.parent,
       a.name
    FROM regios a
        JOIN cities c ON c.id = a.cid
    JOIN regios p ON a.PARENT = p.HASC
    WHERE p.PARENT = 'BE.VL'
),
y AS (
    SELECT provincie, arrondissement,
       stadpop, stadelev,
       MAX(maxelev) OVER (PARTITION BY parent) AS maxelev
    FROM x
),
z AS (
    SELECT
        provincie, arrondissement, stadpop, stadelev,
        rank() OVER (PARTITION BY provincie ORDER BY stadpop DESC) AS rang,
        stadelev - maxelev AS verschil
    FROM y
)
SELECT
       CASE WHEN rang = 1 THEN provincie END AS provincie,
       arrondissement,
       stadpop,
       stadelev,
       verschil
FROM z
WHERE rang <= 3;

/**
  12
 */
WITH x AS (
    SELECT hasc1, hasc2, length
    FROM grenzen
    WHERE hasc1 IN ('BE','NL','FR','DE','LU')
        UNION ALL
    SELECT hasc2, hasc1, length
    FROM grenzen
    WHERE hasc2 IN ('BE','NL','FR','DE','LU')
),
y AS (
    SELECT hasc1, r.NAME, length,
           row_number() OVER(PARTITION BY hasc1 ORDER BY length DESC) AS rang
    FROM x
    JOIN regios r ON x.HASC2 = r.HASC
)
SELECT
    CASE WHEN MAX(CASE WHEN hasc1 = 'BE' THEN name END) IS NOT NULL THEN
                TO_CHAR(MAX(CASE WHEN hasc1 = 'BE' THEN name END) || '('
                            || MAX(CASE WHEN hasc1 = 'BE' THEN length END) || ')' )
        END as BE,
     CASE WHEN MAX(CASE WHEN hasc1 = 'NL' THEN name END) IS NOT NULL THEN
                TO_CHAR(MAX(CASE WHEN hasc1 = 'NL' THEN name END) || '('
                            || MAX(CASE WHEN hasc1 = 'NL' THEN length END) || ')' )
        END as NL,
    CASE WHEN MAX(CASE WHEN hasc1 = 'FR' THEN name END) IS NOT NULL THEN
                TO_CHAR(MAX(CASE WHEN hasc1 = 'FR' THEN name END) || '('
                            || MAX(CASE WHEN hasc1 = 'FR' THEN length END) || ')' )
        END as FR,
    CASE WHEN MAX(CASE WHEN hasc1 = 'DE' THEN name END) IS NOT NULL THEN
                TO_CHAR(MAX(CASE WHEN hasc1 = 'DE' THEN name END) || '('
                            || MAX(CASE WHEN hasc1 = 'DE' THEN length END) || ')' )
        END as DE,
     CASE WHEN MAX(CASE WHEN hasc1 = 'LU' THEN name END) IS NOT NULL THEN
                TO_CHAR(MAX(CASE WHEN hasc1 = 'LU' THEN name END) || '('
                            || MAX(CASE WHEN hasc1 = 'LU' THEN length END) || ')' )
        END as LU
FROM y
GROUP BY rang
ORDER BY rang;

/*
 13.1
 */
WITH x AS (
    SELECT gender,
        discipline,
        name,
        ROW_NUMBER() OVER (PARTITION BY gender, discipline ORDER BY points DESC) AS rang
    FROM ranking
    WHERE season = 2007
)
SELECT gender,
       discipline,
       MAX(CASE WHEN rang = 1 THEN name ELSE '' END) AS "1",
       MAX(CASE WHEN rang = 2 THEN name ELSE '' END) AS "2",
       MAX(CASE WHEN rang = 3 THEN name ELSE '' END) AS "3"
FROM x
WHERE rang <= 3
GROUP BY gender, discipline;

/*
 13.2
 */
 WITH x AS (
    SELECT
        season,
        gender,
        discipline,
        name,
        ROW_NUMBER() OVER (PARTITION BY season ORDER BY gender, discipline) AS rangseas,
        ROW_NUMBER() OVER (PARTITION BY season, gender, discipline ORDER BY points DESC) AS ranggendisc
    FROM ranking
)
SELECT
       MAX(CASE WHEN rangseas = 1 THEN TO_CHAR(SEASON) ELSE '' END) AS seas,
       gender,
       discipline,
       MAX(CASE WHEN ranggendisc = 1 THEN name ELSE '' END) AS "1",
       MAX(CASE WHEN ranggendisc = 2 THEN name ELSE '' END) AS "2",
       MAX(CASE WHEN ranggendisc = 3 THEN name ELSE '' END) AS "3"
FROM x
WHERE ranggendisc <= 3
GROUP BY season, gender, discipline;

/**
  14
 */
WITH x AS (
    SELECT
        gender,
        discipline,
        name,
        ROW_NUMBER() OVER (PARTITION BY gender ORDER BY gender) AS ranggender,
        ROW_NUMBER() OVER (PARTITION BY gender, discipline ORDER BY points DESC) AS rang
    FROM ranking
    WHERE season = 2007
)
SELECT
    MAX(CASE WHEN ranggender = 1 THEN gender ELSE '' END) AS gen,
    MAX(CASE WHEN rang = 1 THEN discipline ELSE '' END) AS discip,
    rang,
    name
FROM x
WHERE rang <= 3
GROUP BY gender, discipline, rang, name
ORDER BY gender, discipline, rang;
                     
WITH x AS (
    SELECT distinct iso
    FROM cities
    join members on iso=hasc and afkorting='EU'
    WHERE elevation >= 500
), y AS (
    SELECT 'Laaggebergte' hoogtegroep FROM DUAL
    UNION ALL
    SELECT 'Middelgebergte' hoogtegroep FROM DUAL
        UNION ALL
    SELECT 'Hooggebergte' hoogtegroep FROM DUAL
), xy AS (
   SELECT iso, hoogtegroep
    FROM x,y
), Z AS (
    SELECT   iso, case when elevation between 500 and  749 then 'Laaggebergte'
                   when elevation between 750 and 1499 then 'Middelgebergte'
                   when elevation     >= 1500          then 'Hooggebergte'
              end  hoogtegroep
        ,COUNT(1) aantal
FROM     cities join members on iso=hasc and afkorting='EU'
WHERE    elevation >= 500
GROUP BY iso, case when elevation between 500 and  749 then 'Laaggebergte'
                   when elevation between 750 and 1499 then 'Middelgebergte'
                   when elevation     >= 1500          then 'Hooggebergte'
              end

), zxy AS (
    SELECT
        xy.iso,
        xy.hoogtegroep,
        coalesce(z.aantal, 0) as aantal
    FROM xy
    LEFT JOIN z ON xy.iso = z.iso AND xy.hoogtegroep = z.hoogtegroep
), fin AS (
    SELECT name,
       hoogtegroep,
       zxy.aantal,
       row_number() over (PARTITION BY hoogtegroep ORDER BY zxy.aantal DESC, name) as rang
    FROM zxy
    JOIN regios r ON r.HASC = zxy.iso
    GROUP BY name, hoogtegroep, zxy.aantal
)
SELECT
    MAX(CASE WHEN hoogtegroep = 'Laaggebergte' THEN name END) || '('
        || TO_CHAR(MAX(CASE WHEN hoogtegroep = 'Laaggebergte' THEN aantal END)) || ')' AS "Laaggebergte",
    MAX(CASE WHEN hoogtegroep = 'Middelgebergte' THEN name END) || '('
        || TO_CHAR(MAX(CASE WHEN hoogtegroep = 'Middelgebergte' THEN aantal END)) || ')' AS "Middelgebergte",
    MAX(CASE WHEN hoogtegroep = 'Hooggebergte' THEN name END) || '('
        || TO_CHAR(MAX(CASE WHEN hoogtegroep = 'Hooggebergte' THEN aantal END)) || ')' AS "Hooggebergte"
FROM fin
GROUP BY rang
ORDER BY rang
                       
