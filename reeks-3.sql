SELECT hasc,iso,
    sum(cast(gebruik*case when hasc = 'BE' then 10413759
                          when hasc = 'DE' then 82503000 end as int)) over (PARTITION BY hasc) as somhasc,
    sum(cast(gebruik*case when hasc = 'BE' then 10413759
                          when hasc = 'DE' then 82503000 end as int)) over (PARTITION BY iso) as somiso,
    sum(cast(gebruik*case when hasc = 'BE' then 10413759
                         when hasc = 'DE' then 82503000 end as int)) over () as somtot
FROM  Taalgebruik
where hasc in('BE','DE');


/**
  Toon de velden hasc, iso en gebruik uit de Taalgebruik tabel.
  Beperk de uitvoer tot rijen van landen met hasc ingesteld op 'BE', 'NL' of 'FR'.
  Markeer voor elk land (hasc) de rij met het hoogste taalgebruik door in een toegevoegde kolom de kodering max te noteren.
 */
SELECT hasc, iso, gebruik,
       CASE WHEN gebruik = MAX(gebruik) OVER (PARTITION BY hasc) THEN 'MAX' ELSE '' END AS max
FROM taalgebruik
WHERE hasc IN ('BE', 'NL', 'FR');

/**
  Tel per resort, discipline en gender het aantal races uit de tabel Races.
  Markeer deze resorts en disciplines waarvoor er geen wedstrijden zijn voor mannen EN vrouwen.
 */
SELECT resort, discipline, gender,
       count(1),
       CASE WHEN COUNT(1) OVER (PARTITION BY resort, discipline) = 1
            THEN 'x' ELSE '' END AS c
FROM races
WHERE resort LIKE 'W%'
GROUP BY resort, discipline, gender
ORDER BY resort;

/**
  Toon per taal (iso) het maximale gebruik ervan in één of ander land (beperk je hierbij tot enkele europese landen vb. BE en DE),
  en markeer vervolgens deze taal welke het kleinste maximale gebruik vertoont.
 */
SELECT iso,
       ROUND(MAX(gebruik) * 100, 2),
       CASE WHEN MAX(gebruik) = MIN(MAX(gebruik)) OVER ( )  THEN 'min' ELSE '' END as min
FROM taalgebruik
WHERE HASC IN ('BE', 'DE')
GROUP BY iso
ORDER BY iso;

/**
SELECT resort,discipline,count(1)
FROM Races
GROUP BY resort,discipline
ORDER BY resort,discipline
  Verander de query en voeg er een kolom aan toe met het aantal verschillende disciplines per resort,
  alsook een kolom met het aantal resorts per discipline
 */
SELECT resort,discipline,count(1),
       count(1) OVER (PARTITION BY resort),
       count(1) OVER (PARTITION BY discipline)
FROM Races
GROUP BY resort, discipline
ORDER BY resort DESC,discipline;

/**
SELECT rid,name,rank,points
FROM Results
where rid between 180 and 182 and points >0
order by rid,points desc
Nummer de rijen (NR) per wedstrijd volgens het aantal punten met de functie rank() en row_number().
  Merk het verschil tussen rank en NR in volgend deel van de uitvoer:
 */
SELECT rid,name,rank,points,
       rank() OVER (ORDER BY rid, points DESC),
       row_number() OVER (ORDER BY rid, points DESC)
FROM Results
where rid between 180 and 182 and points >0
order by rid,points desc;

/**
Toon uit de tabel Cities de niveaus lev1 en lev2, en de maximum population,
  gegroepeerd per lev1 en lev2.
  Breng vervolgens een nummering en een ordening aan:
een ranking NR, aflopend geordend volgens population, over alle rijen
een analoge ranking NRLEV1, binnen lev1
 */
SELECT lev1, lev2,
       MAX(POPULATION) AS population,
       rank() OVER (ORDER BY MAX(population) DESC, lev1) as nr,
       CONCAT(INITCAP(SUBSTR(lev1, 1, 2)), rank() OVER (PARTITION BY lev1 ORDER BY MAX(population) DESC)) as nrev1
FROM cities
WHERE lev1 IS NOT NULL AND lev2 IS NOT NULL AND ISO = 'BE'
GROUP BY lev1, lev2
ORDER BY population DESC, lev1;

/**
  Volgende query toont de naam, het inwonersaantal, de oppervlakte en de hoogteligging van elk europees land.
  SELECT   name, population, area, elevation
FROM     regios
WHERE    parent = 'EUR'
         AND area IS NOT NULL
         AND elevation IS NOT NULL
ORDER BY name;
  Vervang de laatste kolom door de hoogteligging,
  relatief ten opzichte van de met de oppervlakte gewogen gemiddelde hoogteligging van Europa,
  afgerond zonder cijfers na het decimaal punt.
  Voeg tenslotte een nieuwe laatste kolom toe,
  die de rangorde van het land volgens bevolkingsdichtheid aangeeft (rangorde 1 voor het land met de grootste bevolkingsdichtheid).
 */
SELECT   name, population, ROUND(area, 0) as area,
         elevation,
         ROUND(elevation - (SUM(elevation*area) OVER ( ) / SUM(area) OVER ())) as "rel elevation",
         rank() OVER (ORDER BY population/area) as "rank density"
FROM     regios
WHERE    parent = 'EUR'
         AND area IS NOT NULL
         AND elevation IS NOT NULL
ORDER BY name;

/**
  Toon uit de tabel Races de verschillende resorts en de wedstrijddagen(racedate) van 2008.
  Breng vervolgens een nummering en een ordening aan:
  een ranking rijnr per resort,geordend volgens racedate, binnen resort
  een ranking rijnr volgens resort/datum, geordend volgens resort,racedate over alle rijen
  een ranking rijnr volgens datum, geordend volgens racedate over alle rijen
 */
SELECT resort, to_char(racedate, 'dd/mm/yy') datum,
       rank() OVER (PARTITION BY resort ORDER BY resort, racedate),
       rank() OVER (ORDER BY resort, racedate),
       rank() OVER (ORDER BY racedate)
FROM races
WHERE EXTRACT(YEAR FROM racedate) = 2008
ORDER BY resort, racedate;

/**
Vervolledig de query zodat voor dezelfde landen niet enkel die som getoond wordt maar ook volgende kolommen:
    de som van het gebruik voor de talengroep('ned','fr','dui')
    een rangorde voor de som van het gebruik voor de talengroep('ned','fr','dui')
    een kolom welke de grootste som voor die talengroep('ned','fr','dui') weergeeft met 'max'
    de som van het gebruik voor de groep bestaande uit de andere talen ('tur','spa','ita','ara')
    Verzorg de uitvoer en geef het gebruik weer als percenten met 2 beduidende cijfers
 */
SELECT hasc, ROUND(sum(gebruik) * 100, 2) som ,
       ROUND(SUM(CASE WHEN iso IN ('ned', 'fra', 'dui') THEN gebruik ELSE 0 END) * 100, 2) as "NED/FR/DUI",
       rank() OVER (ORDER BY SUM(CASE WHEN iso IN ('ned', 'fra', 'dui') THEN gebruik ELSE 0 END)) AS rank,
       CASE WHEN MAX(SUM(CASE WHEN iso IN ('ned', 'fra', 'dui') THEN gebruik ELSE 0 END)) OVER ()
                     = SUM(CASE WHEN iso IN ('ned', 'fra', 'dui') THEN gebruik ELSE 0 END)
                THEN 'max' ELSE '' END AS max,
       ROUND(SUM(CASE WHEN iso IN ('tur', 'spa', 'ita', 'ara') THEN gebruik ELSE 0 END) * 100, 2) as "tur/spa/ita/ara"
FROM  taalgebruik
WHERE
       iso in ('ned','fra','dui','tur','spa','ita','ara')
       and hasc in ('BE','NL','FR','DE')
GROUP BY hasc
ORDER BY som DESC
