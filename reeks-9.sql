/**
  1
 */
 -- oracle
with z (x) as (
    select level x
    from dual
    connect by last_day(SYSDATE) != SYSDATE + level
)
SELECT to_char(SYSDATE + x, 'dd') AS day
FROM z;
-- ansi
with z (x) as (
    select 0 x
    from dual
        UNION ALL
    select x + 1
    from z
    WHERE last_day(SYSDATE) != SYSDATE + x
)
SELECT to_char(SYSDATE + x, 'dd') AS x
FROM z;

/**
  2
  Schrijf een recursieve query welke nagaat hoeveel zondagen er in elke maand van het jaar 2013 voorkomen.
  Met een recursieve query kunnen we een tabel creëren welke alle 365 dagen van het jaar 2013 bevat.
  En op basis daarvan kunnen we het gevraagde reproduceren.
 */
WITH z (x, datum) AS (
    SELECT level x, to_date('2012-12-31', 'yyyy-mm-dd') + level AS datum
    FROM DUAL
    CONNECT BY level <= 365
)
SELECT EXTRACT(YEAR FROM datum) AS jaar,
       EXTRACT(MONTH FROM datum) AS maand,
       COUNT(CASE WHEN TO_CHAR(datum, 'DY') = 'SUN' THEN 1 END) AS zondagen
FROM z
GROUP BY EXTRACT(YEAR FROM datum), EXTRACT(MONTH FROM datum)
ORDER BY jaar, maand;

-- ansi
WITH z (x, datum) AS (
    SELECT 1 x, to_date('2013-01-01', 'yyyy-mm-dd') AS datum
    FROM dual
        UNION ALL
    SELECT x + 1, datum + 1
    FROM z
    WHERE x < 365
)
SELECT EXTRACT(YEAR FROM datum) AS jaar,
       EXTRACT(MONTH FROM datum) AS maand,
       COUNT(CASE WHEN TO_CHAR(datum, 'DY') = 'SUN' THEN 1 END) AS zondagen
FROM z
WHERE EXTRACT(YEAR FROM datum) = 2013
GROUP BY EXTRACT(YEAR FROM datum), EXTRACT(MONTH FROM datum)
ORDER BY jaar, maand;

/**
  3
 */
-- oracle
-- WITH z (x) AS (
--    SELECT level x
--    FROM DUAL
--    CONNECT BY level <= 12
--)
-- of ansi
WITH z (x) AS (
    SELECT 1 x
    FROM DUAL
        UNION ALL
    SELECT x + 1
    FROM z
    WHERE x < 12
)
SELECT z.x AS maand, CASE WHEN COUNT(1) = 1 THEN 0 ELSE count(1) END AS aant
FROM z
LEFT JOIN races r ON EXTRACT(MONTH FROM r.racedate) = z.x
GROUP BY z.x
ORDER BY z.x;

/**
  4 Toon alle Europese landen en, per land, op één enkele rij, de diverse namen voor hun hoofdsteden:
 */
with x as (
    select Regios.name land,Synoniemen.name
          ,row_number() over (partition by eid order by dup) aantal
          ,count(1) over (partition by eid) totaal
    from Synoniemen
    join Regios on eid=cid and parent='EUR'
)
Select land,ltrim(sys_connect_by_path(name,';'),';') namen
from   x
WHERE level = totaal
start with aantal = 1
connect by prior land = land
       and prior aantal = aantal - 1;

-- ansi
with x as (
    select Regios.name land,Synoniemen.name
          ,row_number() over (partition by eid order by dup) aantal
          ,count(1) over (partition by eid) totaal
    from Synoniemen
    join Regios on eid=cid and parent='EUR'
),
z (land, path, aantal, totaal) AS  (
    SELECT land, name AS path, aantal, totaal
    FROM x
    WHERE aantal = 1
        UNION ALL
    SELECT x2.land, z.path || ';' || x2.name AS path, x2.aantal, x2.totaal
    FROM x x2
    JOIN z ON z.land = x2.land AND x2.aantal = z.aantal + 1
)
SELECT land, path
FROM z
WHERE aantal = totaal
ORDER BY land;

/**
  5
  Toon alle Europese landen en, per land, op één enkele rij,
  de diverse talen die er gesproken worden, in volgorde van het gebruik ervan in dat land:
 */
WITH x AS (
    select Regios.name land, talen.TAAL taal,
           row_number() OVER (PARTITION BY regios.name ORDER BY talen.taal) AS aantal,
           COUNT(1) OVER (PARTITION BY regios.name) AS totaal
        from taalgebruik
        join talen on talen.ISO = taalgebruik.ISO
        join Regios on TAALGEBRUIK.HASC= REGIOS.HASC and parent='EUR'
), z (land, talen, aantal, totaal) AS (
    SELECT land, taal AS talen, aantal, totaal
    FROM x
    WHERE aantal = 1
        UNION ALL
    SELECT x2.land, z.talen || ';' || x2.taal AS talen, x2.aantal, x2.totaal
    FROM x x2
    JOIN z ON x2.aantal = z.aantal + 1 AND x2.land = z.land
)
SELECT land, talen
FROM z
WHERE aantal = totaal
ORDER BY land;

/**
  6
 */
SELECT hasc, name, niveau, level
FROM regios
START WITH name = 'Gent'
CONNECT BY prior hasc = parent
ORDER BY parent, name;

-- ANSI
WITH z (hasc, name, niveau, "LEVEL") AS (
    SELECT hasc, name, niveau, 1 "LEVEL"
    FROM regios r
    WHERE name = 'Gent'
        UNION ALL
    SELECT r2.hasc, r2.name, r2.niveau, z."LEVEL" + 1
    FROM regios r2
    JOIN z ON z.hasc = r2.PARENT
)
SELECT *
FROM z
ORDER BY hasc, name;


/**
  7
 */
SELECT name, niveau, level
FROM regios
START WITH name = 'Melle'
CONNECT BY prior parent = hasc;

-- ansi
WITH z (parent, hasc, name, niveau, lvl) AS (
    SELECT parent, hasc, name, niveau, 1 lvl
    FROM regios r
    WHERE r.name = 'Melle'
        UNION ALL
    SELECT r2.parent, r2.hasc, r2.name, r2.niveau, lvl + 1
    FROM regios r2
    JOIN z ON z.PARENT = r2.HASC
)
SELECT name, niveau, lvl AS "LEVEL"
FROM z;

/**
  8
 */
SELECT hasc, niveau, level, CONNECT_BY_ISLEAF AS blad
FROM regios
START WITH regios.HASC = 'BE'
CONNECT BY PRIOR parent = hasc;

-- ansi
WITH z (parent, hasc, niveau, "LEVEL", blad) AS (
    SELECT parent, hasc, niveau, 1 "LEVEL", DECODE(parent, NULL, 1, 0) AS blad
    FROM regios
    WHERE HASC = 'BE'
        UNION ALL
    SELECT r2.parent, r2.hasc, r2.niveau, z."LEVEL" + 1, DECODE(r2.PARENT, NULL, 1, 0)
    FROM regios r2
    JOIN z ON z.parent = r2.hasc
)
SELECT hasc, niveau, "LEVEL", blad
FROM z
ORDER BY niveau DESC;

/**
  9
 */
SELECT hasc, name, niveau, level, CONNECT_BY_ISLEAF AS blad
FROM regios
START WITH hasc='BE.OV.GT'
CONNECT BY PRIOR hasc = parent;

-- ANSI
WITH x (hasc, name, niveau, "LEVEL", blad) AS (
    SELECT hasc, name, niveau, 1 "LEVEL",
           DECODE((SELECT count(1) FROM regios r2 WHERE r2.hasc = r1.parent), 1, 0, 1) AS blad
    FROM regios r1
    WHERE hasc = 'BE.OV.GT'
        UNION ALL
    SELECT r2.hasc, r2.name, r2.niveau, "LEVEL" + 1,
        DECODE((SELECT count(1) FROM regios r3 WHERE r3.hasc = r3.parent), 1, 0, 1) AS blad
    FROM regios r2
    JOIN x ON r2.PARENT = x.hasc
)
SELECT *
FROM x
ORDER BY "LEVEL", name;
