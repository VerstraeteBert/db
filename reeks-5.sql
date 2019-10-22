/**
  Geef alle races welke doorgegaan zijn in een resort gelegen in Frankrijk (nation='FRA') geordend volgens racedate.
 */
 SELECT * FROM races ra
JOIN resorts re ON re.NAME = ra.RESORT
WHERE nation = 'FRA'
ORDER BY ra.RACEDATE;

/**
  Geef per discipline het aantal verschillende resorts in Frankrijk (nation='FRA') welke een wedstrijd (tabel Races) hebben georganiseerd.
  Geef ook het totale aantal verschillende resorts over alle disciplines heen.
  Geef twee oplossingen: enerzijds met rollup, anderzijds met de set-operator (union).
 */

SELECT
       CASE GROUPING(discipline)
            WHEN 1 THEN 'totaal aantal resorts'
            ELSE discipline
        END AS discipline,
       COUNT(DISTINCT resort) AS aantresorts FROM races
JOIN resorts ON resorts.name = races.resort
WHERE resorts.nation = 'FRA'
GROUP BY ROLLUP(discipline);

(
    SELECT discipline,
           COUNT(DISTINCT resort) AS aantresorts
    FROM races
             JOIN resorts ON resorts.name = races.resort
    WHERE resorts.nation = 'FRA'
    GROUP BY discipline
            UNION
    SELECT 'totaal aantal resorts', count(DISTINCT resort)
    FROM races
             JOIN resorts ON resorts.name = races.resort
    WHERE resorts.nation = 'FRA'
);

/**
  Tel, voor alle nations, het aantal verschillende resorts waar ooit een afdaling(discipline 'DH') heeft plaatsgevonden en finishaltitude niet null is.
    Beperk vervolgens het resultaat tot het aantal verschillende resorts waarvan de finishaltitude minstens 1500 is.
 */
SELECT nation,count(distinct resort) aantresorts
   ,count( distinct (case when finishaltitude >1500  then resort else null end)) aant_1500
FROM Races
      JOIN Resorts ON Races.resort=Resorts.name
where discipline='DH' and finishaltitude is not null
group by nation;

/**
  Geef van de competitors het gemiddeld behaalde punten(tabel Ranking) per leeftijdscategorie.
    Voorzie een kolom voor het gemiddelde van de vrouwen en een voor het gemiddelde van de mannen.
    Voorbeeld uitvoer met beperking seASon=2007 en leeftijd op bASis van trunc( months_between(to_date('01/01/2007','dd/mm/yyyy'),birthdate) /12).
 */
SELECT trunc( months_between(to_date('01/01/2007','dd/mm/yyyy'),birthdate) /12) AS leeftijd,
       ROUND(SUM(CASE WHEN COMPETITORS.gender = 'M' THEN ranking.points ELSE 0 END) / COUNT(CASE WHEN COMPETITORS.GENDER = 'M' THEN 1 ELSE 0 END), 1) AS man,
       ROUND(SUM(CASE WHEN COMPETITORS.gender = 'L' THEN ranking.points ELSE 0 END) / COUNT(CASE WHEN COMPETITORS.GENDER = 'L' THEN 1 ELSE 0 END), 1) AS vrouw
FROM competitors
    JOIN RANKING on ranking.CID = COMPETITORS.cid
WHERE ranking.SEASON = 2007
GROUP BY trunc(months_between(to_date('01/01/2007','dd/mm/yyyy'),birthdate) /12)
ORDER BY 1;

/**
  Geef van elk resort hoeveel andere resorts er zijn binnen hetzelfde land en met een zelfde of een hogere hoogte.
  Gebruik GEEN rankingfunctie ! Sorteer op land en aantal.
 */
SELECT r1.name, r1.NATION, count(1) - 1 AS aantalanderen
FROM resorts r1
JOIN resorts r2 ON r2.NATION = r1.NATION AND r1.FINISHALTITUDE <= r2.FINISHALTITUDE
GROUP BY r1.name, r1.nation
ORDER BY 2, 3;

/**
  SELECT x.discipline,x.gender,x.racedate,x.resort,y.racedate,y.resort
FROM     Races x
    JOIN Races y ON ( x.discipline=y.discipline
                      and       x.gender=y.gender
                      and       x.rid <> y.rid
                      and      x.resort<>y.resort
                      and    y.racedate between x.racedate and x.racedate +1)
   ORDER BY x.racedate,x.discipline

  Deze auto-join races samen met races die op dezelfde dag of de volgende dag gebeuren;
  Binnen dezelfde discipline en voor hetzelfde geslacht, maar in een verschillend resort.
  Geordend per racedatum en discipline
 */

/**
  Zoek in Regios Belgische gemeenten in hetzelfde arrondissement (niveau en parent)
  met een population tussen population en population+5 (grenzen inbegrepen).
 */
SELECT r1.name, r2.name
FROM REGIOS r1
JOIN REGIOS r2
        ON r2.PARENT = r1.PARENT
        AND r1.name < r2.name
        AND r2.NIVEAU = R1.NIVEAU
        AND r2.POPULATION BETWEEN r1.POPULATION AND r1.POPULATION + 5
WHERE substr(r1.hASc,1,2)='BE' AND r1.NIVEAU = 4;

/**
  We zoeken koppels competitors, man en vrouw, uit de tabel Ranking.
  Beiden moeten punten verzameld hebben in een andere discipline en geboren zijn in hetzelfde jaar.
  We beperken de resultaten verder door een aantal extra voorwaarden:
    - hun leeftijdsverschil bedraagt niet meer dan 1 maand
    - ze zijn geboren voor 1974
    - hebben beiden een ranking in seASon 2006
 */
SELECT DISTINCT c1.name, to_char(c1.BIRTHDATE, 'DD-MON-YYYY') a, c2.name, to_char(c2.BIRTHDATE, 'DD-MON-YYYY')
FROM competitors c1
JOIN competitors c2 ON c1.CID < c2.CID
                        AND c1.gender != c2.gender
                        AND EXTRACT(YEAR FROM c2.BIRTHDATE) = EXTRACT(YEAR FROM c1.BIRTHDATE)
                        AND ABS(MONTHS_BETWEEN(c2.BIRTHDATE, c1.BIRTHDATE)) <= 1
JOIN ranking r1 ON c1.CID = r1.CID
JOIN ranking r2 ON c2.CID = r2.CID
WHERE EXTRACT(YEAR FROM c1.BIRTHDATE) < 1974
      AND r1.DISCIPLINE != r2.DISCIPLINE
      AND r1.SEASON = 2006
      AND r2.SEASON = 2006
ORDER BY 1;

/**
  Gebruik een auto-join query voor volgend top-N probleem:
  toon de vijf zwaarste gewichten voor mannen en de vijf zwaarste gewichten voor vrouwen onder de competitors.
  Toon de mannen en de vrouwen in aparte kolommen.
 */
SELECT c1.name,
    CASE WHEN c1.GENDER = 'M' THEN c1.weight END AS "man",
    CASE WHEN c1.GENDER = 'L' THEN c1.weight END AS "vrouw"
FROM COMPETITORS c1
JOIN COMPETITORS c2
    ON c1.GENDER = c2.GENDER
    AND c2.weight >= c1.weight
GROUP BY c1.gender, c1.name, c1.weight
HAVING SUM(CASE WHEN c1.weight <= c2.weight THEN 1 END) <= 5
ORDER BY c1.weight DESC;

/**
  Volgende query maakt geen onderscheid tussen mannen en vrouwen:
  Herschrijf de query met een join, en bekijk de vrouwen en de mannen apart (in één query !).
  Orden volgens geslacht en vervolgens aflopend op gewicht .
 */
SELECT   CASE WHEN c1.gender = 'M' THEN 'man' ELSE 'vrouw' END AS geslacht, c1.name,c1.weight
FROM     Competitors c1
JOIN competitors c2 ON c1.GENDER = c2.gender
GROUP BY c1.gender, c1.name, c1.weight
HAVING
       (MAX(c2.weight)- c1.weight) < 5
ORDER BY  c1.weight DESC, c1.name;

/**
  SELECT hASc,iso,gebruik
FROM Taalgebruik
          intersect
SELECT hASc,iso,MAX(gebruik) over (partition by hASc)
FROM Taalgebruik
ORDER BY hASc
  ???
 */
(
    SELECT t1.hASc, t1.iso, round(t1.gebruik, 4) AS gebruik
    FROM TAALGEBRUIK t1
             JOIN TAALGEBRUIK t2 ON t1.HASC = t2.hASc
    GROUP BY t1.hASc, t1.iso, t1.gebruik
    HAVING SUM(CASE WHEN t1.gebruik <= t2.gebruik THEN 1 ELSE 0 END) = 1
);

/**
  Geef de data waarop in verschillende resorts van hetzelfde land wedstrijden werden georganiseerd:
 */
SELECT DISTINCT r1.RACEDATE, re1.nation, r1.RESORT, r2.resort
FROM races r1
JOIN races r2 ON r1.resort < r2.resort AND r1.RACEDATE = r2.RACEDATE
JOIN resorts re1 ON r1.resort = re1.name
JOIN resorts re2
    ON r2.resort = re2.name
WHERE re1.nation = re2.nation
ORDER BY r1.RACEDATE DESC;

/**
  Toon voor de seizoenen tussen 1986 en 1990 per gender en discipline de top-3 rangschikking uit de ranking tabel.
  Hou rekening met de mogelijkheid dat dezelfde puntentotalen kunnen behaald worden door diverse ski &eumlrs/skiesters.
  Sorteer in volgorde op seASon, gender en discipline.
  Implementeer met behulp van joins, ZONDER gebruik te maken van analytische functies en/of set operatoren.
 */
SELECT r1.SEASON, r1.GENDER, r1.DISCIPLINE, r1.NAME, r1.POINTS,
       1+ COUNT(CASE WHEN r1.POINTS < r2.POINTS THEN 1 END) AS ranking
FROM ranking r1
JOIN ranking r2 on r1.SEASON = r2.SEASON
                AND r1.GENDER = r2.GENDER
                AND r1.DISCIPLINE = r2.DISCIPLINE
                AND r1.POINTS <= r2.POINTS
WHERE r1.SEASON BETWEEN 1986 AND 1990
GROUP BY r1.SEASON, r1.GENDER, r1.DISCIPLINE, r1.NAME, r1.POINTS
HAVING COUNT(CASE WHEN r1.POINTS < r2.POINTS THEN 1 END) < 3
ORDER BY r1.SEASON, r1.GENDER, r1.DISCIPLINE, r1.POINTS DESC;


/**
  Frankrijk wordt staatkundig onderverdeeld in regio's, departementen en arrondissementen.
  Elke regio bestaat uit meerdere departementen.
  Elk departement bestaat uit meerdere arrondissementen.
  Volgende query produceert een lijst van alle departementen:

  SELECT   name
     FROM     regios
     WHERE    parent like 'FR.%' and niveau=2

  Maak gebruik van de recursieve ouder/kind associatie in de regios tabel (met parent als verwijzing en hasc als sleutel)
  om een overzicht te produceren van de namen van alle arrondissementen en hun overkoepelende departementen en regio's
  (telkens geïdentificeerd door hun naam).
  Beperk vervolgens de resultaten door voor elke regio enkel de twee arrondissementen met het grootste bevolkingsaantal (population) te tonen,
  dit samen met het overeenstemmend departement.
  Toon tenslotte voor deze twee arrondissementen samen ook het procentuele bevolkingsaantal ten opzichte van de overkoepelende regio.
  Los dit probleem op zonder analytische functies en/of set-operatoren te gebruiken.
  Sorteer op de naam van de regio en toon 1 rij per regio. Je moet volgende uitvoer reproduceren:
 */
SELECT   r.name regio
         ,max(a2.population) "max1 pop arrond"
        ,(a1.population) "max 2 pop arrond"
        , cast((a1.population+max(a2.population))*100/ r.population AS NUMERIC(5, 1))    "% max1+max2 t.o.v. regio"
         ,max(d2.name) max1departement
         ,max(a2.name) max1arrond
         ,(d1.name)  max2departement
         ,(a1.name) max2arrond
 FROM     regios a1     --arrond
    JOIN regios d1 ON a1.parent = d1.hasc  --departement
    JOIN regios r ON d1.parent=r.hasc         --regio
    JOIN regios d2 ON d1.parent = d2.parent    --zelfde regio
    JOIN regios  a2 ON a2.parent = d2.hasc  and a2.population >a1.population --dep binnen zelfde regio
WHERE
  d1.parent like 'FR.%'
GROUP BY r.name,r.population,d1.name,a1.name,a1.population
HAVING
 count(case when a2.population >a1.population then 1 end)<2
 ORDER BY r.name
 
