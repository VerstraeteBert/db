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

SELECT hasc,
    CASE WHEN COUNT(CASE WHEN iso = 'ned' THEN 1 END) = 1 THEN 1 ELSE 0 END AS nederlands,
    CASE WHEN COUNT(CASE WHEN iso = 'fra' THEN 1 END) = 1 THEN 1 ELSE 0 END AS frans,
    CASE WHEN COUNT(CASE WHEN iso = 'dui' THEN 1 END) = 1 THEN 1 ELSE 0 END AS duits,
    CASE WHEN COUNT(1) = 3 THEN 'x' ELSE ' ' END AS aa    
FROM taalgebruik
WHERE iso IN ('dui', 'fra', 'ned')
GROUP BY hasc;

SELECT hasc
FROM taalgebruik
WHERE iso IN ('eng', 'fra', 'spa')
GROUP BY hasc
HAVING 
    COUNT(CASE WHEN iso = 'eng' THEN 1 END) >= 1
    AND COUNT(CASE WHEN iso= 'fra' THEN 1 END) >= 1
    AND COUNT (CASE WHEN iso = 'dui' THEN 1 END) >= 1;
    
SELECT CASE 
            WHEN iso = 'ned' THEN 'nederlands'
            WHEN iso = 'fra' THEN 'frans'
            WHEN iso = 'dui' THEN 'duits'
        END AS taal, 
        count(1) as aantal
FROM taalgebruik
WHERE iso IN ('ned', 'fra', 'dui')
GROUP BY iso
ORDER BY 
    CASE 
        WHEN taal = 'nederlands' THEN 1
        WHEN taal = 'frans' THEN 2
        WHEN taal = 'duits' THEN 3
        ELSE 4
    END;
    
/**
  Toon de taal iso en de som van het gebruik uit de tabel Taalgebruik voor hasc='BE','FR' of 'NL'.
 */
SELECT hasc, iso, ROUND(SUM(gebruik), 4)
FROM taalgebruik
WHERE hasc IN ('BE', 'FR', 'NL')
GROUP BY ROLLUP(hasc, iso)
HAVING GROUPING(hasc) + GROUPING(iso) != 2;

/**
  Bepaal uit de tabel Cities voor iso='DE of iso='FR' het aantal records per iso en lev1. Verzorg de uitvoer !
  DE Bayern                                   21763
DE Berlin                                     148
DE Bremen                                      70
DE Hessen                                    3242
DE Hamburg                                    211
DE Sachsen                                   2214
...
   totaal land  DE                          65233
FR Corse                                      798
FR Alsace                                    1002
FR Centre                                    4423
FR Auvergne                                  3775
...
FR Provence-Alpes-Côte d'Azur                2291
   totaal land  FR                          57884
   **totaal**                              123117
 */
SELECT
     CASE WHEN grouping(lev1) = 0 THEN iso ELSE '' END AS iso,
     CASE grouping_id(iso) + grouping_id(lev1)
            WHEN 3 THEN '**totaal**'
            WHEN 1 THEN 'totaal land ' || iso
            ELSE lev1
     END AS lev1,
     count(1) as totaal
FROM cities
WHERE iso IN ('DE', 'FR') AND lev1 IS NOT NULL
GROUP BY ROLLUP(iso, lev1);

/**
  Toon met één enkele query uit de tabel Taalgebruik zowel die landen (hasc) waar men minstens 10 talen (iso) spreekt,
  als die talen die in minstens tien landen gesproken worden.
  Beperk je hierbij tot talen waarvan het relatieve gebruik minstens 2% is.
   ---------------------------------
         in UG spreekt men 12 talen
         in TZ spreekt men 12 talen
         in TG spreekt men 12 talen
         . . .
         eng wordt gesproken in 48 landen
         ara wordt gesproken in 25 landen
         spa wordt gesproken in 25 landen
         . . .
 */
SELECT
    CASE GROUPING_ID(hasc) * 2  + GROUPING_ID(ISO)
        WHEN 2 THEN iso || ' wordt in ' || count(1) || ' landen gesproken'
        WHEN 1 THEN 'In ' || hasc || ' spreekt men ' || count(1) || ' talen'
    END
FROM Taalgebruik
WHERE gebruik > 0.02 AND hasc IS NOT NULL
GROUP BY cube(hasc,iso)
HAVING count(1) > 10 AND (GROUPING_ID(hasc) + GROUPING_ID(iso) != 2)
ORDER BY GROUPING_ID(hasc), count(1) DESC

/**
  Volgende SQL query produceert een lijst van alle Belgische gemeenten, met hun orientatie t.o.v. Brussel en hun elevation (hoogteligging).

  Men kan een gemeente classificeren volgens het criterium orientatie t.o.v. Brussel. Een gemeente ligt:
    ten noorden van Brussel indien ligging<45 of ligging>315
    ten oosten van Brussel indien 45<ligging<135
    ten zuiden van Brussel indien 135<ligging<225
    ten westen van Brussel indien 225<ligging<315

  in laag-Belgie indien elevation<50
in midden-Belgie indien 50<=elevation<200
in hoog-Belgie indien elevation>=200

Ontwikkel STAPSGEWIJS een query die een tweedimensionale overzichtstabel produceert van het aantal gemeenten in de diverse categorieën en hun combinaties. Je moet bijgevolg volgend resultaat bekomen:
              LAAG   MIDDEN     HOOG
     -----  ------   ------   ------   ------
     noord      92        1        0       93
     oost       53      106       59      218
     west      127       22        0      149
     zuid        8       69       52      129
               280      198      111      589
 */
SELECT
    CASE
        WHEN richting(50.830, 4.330, latitude, longitude) < 45 OR richting(50.830, 4.330, latitude, longitude) >= 315 THEN 'noorden'
        WHEN richting(50.830, 4.330, latitude, longitude) BETWEEN 45 AND 134.999 THEN 'oosten'
        WHEN richting(50.830, 4.330, latitude, longitude) BETWEEN 135 AND 224.999 THEN 'zuiden'
        WHEN richting(50.830, 4.330, latitude, longitude) BETWEEN 225 AND 314.999 THEN 'westen'
    END,
    SUM(CASE WHEN elevation < 50 THEN 1 ELSE 0 END) as laag,
    SUM(CASE WHEN elevation BETWEEN 50 AND 199.999 THEN 1 ELSE 0 END) as midden,
    SUM(CASE WHEN elevation >= 200 THEN 1 ELSE 0 END) as hoog,
    count(*)
FROM regios
WHERE parent like 'BE.__.__'
GROUP BY
    ROLLUP(CASE
        WHEN richting(50.830, 4.330, latitude, longitude) < 45 OR richting(50.830, 4.330, latitude, longitude) >= 315 THEN 'noorden'
        WHEN richting(50.830, 4.330, latitude, longitude) BETWEEN 45 AND 134.999 THEN 'oosten'
        WHEN richting(50.830, 4.330, latitude, longitude) BETWEEN 135 AND 224.999 THEN 'zuiden'
        WHEN richting(50.830, 4.330, latitude, longitude) BETWEEN 225 AND 314.999 THEN 'westen'
    END);

/*
 Ontwikkel STAPSGEWIJS één enkele query die uit de Ranking tabel een tweedimensionale overzichtstabel produceert
 (voor elk seizoen een rij en voor elke discipline een kolom) van het aantal skiërs of skiesters
 die tijdens een specifiek seizoen in een specifieke discipline punten behaald hebben.
 Produceer eveneens een afsluitende rij, die de overeenkomstige gegevens genereert, samengevat over alle seizoenen heen.
 Voeg vervolgens drie kolommen toe die de aantallen per rij sommeert:
    één waarbij enkel met skiërs wordt rekening gehouden,
    één enkel met skiesters, en één waarbij geen onderscheid gemaakt wordt tussen beiden. Voeg tenslotte een kolom toe met de over de disciplines uitgemiddelde aantallen, hierbij enkel rekening houdend met effectief ingerichte disciplines. Je moet bijgevolg volgend resultaat bekomen:
 */
SELECT CASE WHEN GROUPING(season) = 1 THEN 'Total' ELSE 'Season ' || season END AS result,
       SUM(CASE WHEN discipline = 'DH' THEN 1 ELSE 0 END) as dh,
       SUM(CASE WHEN discipline = 'SG' THEN 1 ELSE 0 END) as sg,
       SUM(CASE WHEN discipline = 'GS' THEN 1 ELSE 0 END) as gs,
       SUM(CASE WHEN discipline = 'SL' THEN 1 ELSE 0 END) as sl,
       SUM(CASE WHEN discipline = 'KB' THEN 1 ELSE 0 END) as kb,
       SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS M,
       SUM(CASE WHEN gender = 'L' THEN 1 ELSE 0 END) AS L,
       COUNT(1) AS totaal,
       ROUND(count(1) / COUNT(DISTINCT discipline), 2) AS gemperdisc
FROM ranking
WHERE season <= 2016
GROUP BY ROLLUP(season)
ORDER BY season
