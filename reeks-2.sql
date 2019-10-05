SELECT MIN(birthdate) as oudste, MAX(birthdate) as jongste
FROM competitors;

SELECT round(avg(finishaltitude), 2) as gemhoogte
FROM resorts
WHERE nation = 'ITA';

SELECT count(1)
FROM races
WHERE modus IS NULL;

SELECT COUNT(DISTINCT nation) as "aantal landen"
FROM resorts;

SELECT nation, round(AVG(finishaltitude), 2) as gemhoogte
FROM resorts
WHERE nation in ('AUT', 'ITA', 'SUI')
GROUP BY nation;

SELECT nation, 
CASE 
    WHEN nation IN ('AUT', 'ITA', 'SUI')
      THEN round(AVG(finishaltitude), 2)
    ELSE NULL
END as gemhoogte
FROM resorts
GROUP BY nation;

SELECT cid, name, count(1) as aantalwinsten
FROM results
WHERE rank = 1
GROUP BY cid, name
ORDER BY aantalwinsten DESC;

SELECT resort, count(1) as aant
FROM races
WHERE EXTRACT(YEAR FROM racedate) = 2006
GROUP BY resort, gender
HAVING COUNT(DISTINCT discipline) >= 3 AND gender = 'L'
ORDER BY aant;

SELECT cid, name, COUNT(1) AS aantal
FROM results
WHERE rank BETWEEN 1 AND 2
GROUP BY cid, name
HAVING count(1) >= 2
ORDER BY aantal;

SELECT racedate, resort, count(1)
FROM Races
WHERE modus IS NOT NULL
GROUP BY racedate, resort, gender
HAVING count(1) = 2
ORDER BY racedate;

SELECT 
  extract(YEAR from racedate) AS racejaar, 
  discipline, 
  COUNT(1) AS aantal_wedstrijden
FROM races
WHERE EXTRACT(YEAR FROM racedate) > 1999 AND discipline IN ('SG', 'SL')
GROUP BY EXTRACT(YEAR FROM racedate), discipline
ORDER BY racejaar, discipline;

SELECT cid, name, 
  SUM(CASE season WHEN 2005 THEN points ELSE 0 END) AS P05,
  SUM(CASE season WHEN 2006 THEN points ELSE 0 END) AS P06
FROM ranking
WHERE season BETWEEN 2005 AND 2006
GROUP BY cid, name
HAVING SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) = 2
ORDER BY SUM(points);

SELECT
  CASE 
    WHEN finishaltitude BETWEEN 0 and 800 then 'laag'
    WHEN finishaltitude BETWEEN 800 and 1000 then 'normaal'
    WHEN finishaltitude > 1000 then 'hoog'
  END AS indeling,
 count(1) as aantal
FROM Resorts
where finishaltitude is not null
GROUP BY 
  CASE 
    WHEN finishaltitude BETWEEN 0 and 800 then 'laag'
    WHEN finishaltitude BETWEEN 800 and 1000 then 'normaal'
    WHEN finishaltitude > 1000 then 'hoog'
  END,
  CASE 
    WHEN finishaltitude BETWEEN 0 and 800 then 1
    WHEN finishaltitude BETWEEN 800 and 1000 then 2
    WHEN finishaltitude > 1000 then 3
  END
ORDER BY case
   when finishaltitude between 0 and 800 then 1
   when finishaltitude between 800 and 1000 then 2
   when finishaltitude >1000 then 3
 end;
 
SELECT cid, name,
  SUM(CASE WHEN rank between 1 and 3 then 1 else 0 end) as fantastisch,
  SUM(CASE WHEN rank between 4 and 6 then 1 else 0 end) as goed,
  SUM(CASE WHEN rank between 7 and 9 then 1 else 0 end) as bijnagoed,
  SUM(CASE WHEN rank between 10 and 12 then 1 else 0 end) as slecht,
  SUM(CASE WHEN rank > 12 then 1 else 0 end) as zeerslecht
FROM results
GROUP BY cid, name
ORDER BY cid, name;

-- 16.1
SELECT name,nation,
  CASE 
    WHEN finishaltitude < 1300 then 'laag'
    WHEN finishaltitude BETWEEN 1300 AND 2150 then 'middelmatig'
    WHEN finishaltitude > 2150 then 'hoog'
  END AS indeling
FROM  resorts
WHERE finishaltitude is not null
ORDER BY 
  CASE nation 
    WHEN 'ITA' THEN 1
    WHEN 'SUI' THEN 2
    WHEN 'AUT' THEN 3
    ELSE 4
  END;
  
-- 16.2
SELECT name,nation,
  CASE WHEN finishaltitude < 1300 then 'x' else NULL END AS laag,
  CASE WHEN finishaltitude BETWEEN 1200 AND 2150 then 'x' else NULL END AS middelmatig,
  CASE WHEN finishaltitude > 2150 then 'x' else NULL END AS hoog
FROM  resorts
WHERE finishaltitude is not null
ORDER BY 
  CASE nation 
    WHEN 'ITA' THEN 1
    WHEN 'SUI' THEN 2
    WHEN 'AUT' THEN 3
    ELSE 4
  END;

-- 16.3
SELECT name,nation,
  CASE WHEN finishaltitude < 1300 then 'x' else NULL END AS laag,
  CASE WHEN finishaltitude BETWEEN 1200 AND 2150 then 'x' else NULL END AS middelmatig,
  CASE WHEN finishaltitude > 2150 then 'x' else NULL END AS hoog
FROM  resorts
WHERE finishaltitude is not null
ORDER BY 
  CASE nation 
    WHEN 'ITA' THEN 1
    WHEN 'SUI' THEN 2
    WHEN 'AUT' THEN 3
    ELSE 4
  END;
  
-- 16.4
SELECT nation,
  SUM(CASE WHEN finishaltitude < 1300 THEN 1 ELSE 0 END) AS laag,
  SUM(CASE WHEN finishaltitude BETWEEN 1200 AND 2150 THEN 1 ELSE 0 END) AS middelmatig,
  SUM(CASE WHEN finishaltitude > 2150 THEN 1 ELSE 0 END) AS hoog
FROM  resorts
WHERE finishaltitude is not null
GROUP BY nation
ORDER BY 
  CASE nation 
    WHEN 'ITA' THEN 1
    WHEN 'SUI' THEN 2
    WHEN 'AUT' THEN 3
    ELSE 4
  END;

-- 16.5
SELECT nation, laag, middelmatig, hoog,
  (CASE WHEN laag != 0 THEN 1 ELSE 0 END +
   CASE WHEN middelmatig != 0 THEN 1 ELSE 0 END + 
   CASE WHEN hoog != 0 THEN 1 ELSE 0 END) as num_cats
FROM (
  SELECT nation,
    SUM(CASE WHEN finishaltitude < 1300 THEN 1 ELSE 0 END) AS laag,
    SUM(CASE WHEN finishaltitude BETWEEN 1200 AND 2150 THEN 1 ELSE 0 END) AS middelmatig,
    SUM(CASE WHEN finishaltitude > 2150 THEN 1 ELSE 0 END) AS hoog
  FROM  resorts
  WHERE finishaltitude is not null
  GROUP BY nation
  ORDER BY 
    CASE nation 
      WHEN 'ITA' THEN 1
      WHEN 'SUI' THEN 2
      WHEN 'AUT' THEN 3
    END,
    nation ASC
);
