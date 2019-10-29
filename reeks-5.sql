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
 
 /**
  Toon uit de tabel Regios de parent,name en population gegevens voor parent ='BE', 'DE' of 'GB'
  .Orden volgens parent,name. Voeg aan de uitvoer een aantal kolommen toe:
   een eerste extra kolom, die het procentuele bevolkingsaantal berekent,
  ten opzichte van het totale bevolkingsaantal van het land(parent),
    een tweede extra kolom, die de rangorde van het bevolkingsaantal
    in het land aangeeft(rangorde 1 voor het grootste aantal) ,
    een laatste extra kolom, die een analoge rangorde aangeeft,
   maar nu ten opzichte van het bevolkingsaantal over alle beschouwde landen heen.
 */
SELECT r1.PARENT, r1.NAME, r1.POPULATION,
       ROUND(r1.POPULATION / SUM(CASE WHEN r1.PARENT = r2.PARENT THEN r2.POPULATION ELSE 0 END) * 100, 2) AS "bevolking%",
       1 + COUNT(CASE WHEN r1.PARENT = r2.PARENT AND r1.POPULATION < r2.POPULATION THEN 1 END) AS "rank pop per land",
       1 + COUNT(CASE WHEN r1.POPULATION < r2.POPULATION THEN 1 END) AS "rank pop"
FROM REGIOS r1, REGIOS r2
WHERE r1.PARENT IN ('DE', 'BE', 'GB') AND r2.PARENT IN ('DE', 'BE', 'GB') AND r1.POPULATION IS NOT NULL AND r2.POPULATION IS NOT NULL
GROUP BY r1.PARENT, r1.NAME, r1.POPULATION
HAVING COUNT(CASE WHEN r1.PARENT = r2.PARENT AND r1.POPULATION < r2.POPULATION THEN 1 END)
           IN (0, COUNT(CASE WHEN r1.PARENT = r2.PARENT THEN 1 END) - 1)
ORDER BY r1.PARENT, r1.NAME;

/**
  Beschouw de resultaten (Results tabel) van alle wedstrijden (Races tabel) die doorgegaan zijn in 2016.
  Bereken voor elke skiër/skiester, die zowel minstens éénmaal heeft deelgenomen aan een wedstrijd in zijn/haar geboorteland,
  als minstens éénmaal een podiumplaats heeft behaald (om het even waar):

  het aantal behaalde podiumplaatsen (rank<=3) in zijn/haar geboorteland,
    het aantal deelgenomen wedstrijden in zijn/haar geboorteland,
    het totale aantal behaalde podiumplaatsen,
    het totale aantal deelgenomen wedstrijden.

  Bereken vervolgens een indicatie die weergeeft in hoeverre de skiër/skiester
  beter blijkt te presteren indien de wedstrijd in het geboorteland plaatsvindt.
  Bereken deze indicatie door middel van het verschil van het quotient
  van de eerste twee hierboven vermelde cijfers
  en het quotient van de laatste twee hierboven vermelde cijfers.
  Druk dit thuisvoordeel uit als een percentage, met één beduidend cijfer na de komma.
  Geef tenslotte een rangschikking weer volgens het grootste thuisvoordeel.
  Hierbij mogen enkel de skiër/skiesters die thuisvoordeel vertonen,
  in de rangschikking worden opgenomen.
  Sorteer de resultaten volgens het totale aantal behaalde podiumplaatsen.
 */
SELECT c.NAME, c.NATION,
       COUNT(CASE WHEN res.NATION = c.NATION AND re.RANK <= 3 THEN 1 END)
           || ' / ' ||
       COUNT(CASE WHEN res.NATION = c.NATION THEN 1 END) AS "thuis",
       COUNT(CASE WHEN re.rank <= 3 THEN 1 END)
            || ' / ' ||
       COUNT(1) AS "globaal",
       ROUND( 100 * (COUNT(CASE WHEN res.NATION = c.NATION AND re.RANK <= 3 THEN 1 END) / COUNT(CASE WHEN res.NATION = c.NATION THEN 1 END)
        - COUNT(CASE WHEN re.rank <= 3 THEN 1 END) / COUNT(1)), 2) AS "thuisvoordeel",
      CASE WHEN
         (COUNT(CASE WHEN res.NATION = c.NATION AND re.RANK <= 3 THEN 1 END)
              / COUNT(CASE WHEN res.NATION = c.NATION THEN 1 END)
        > COUNT(CASE WHEN re.rank <= 3 THEN 1 END)
              / COUNT(1))
     THEN RANK() OVER(ORDER BY
          (COUNT(CASE WHEN res.NATION = c.NATION AND re.RANK <= 3 THEN 1 END)
              / COUNT(CASE WHEN res.NATION = c.NATION THEN 1 END)
          - COUNT(CASE WHEN re.rank <= 3 THEN 1 END)
              / COUNT(1))
    DESC ) END AS "ranking"
FROM RESULTS re
JOIN RACES ra on re.RID = ra.RID
JOIN RESORTS res on res.NAME = ra.RESORT
JOIN COMPETITORS c ON re.CID = c.CID
WHERE EXTRACT(YEAR FROM ra.RACEDATE) = 2016
GROUP BY c.CID, c.NAME, c.NATION
HAVING
    COUNT(CASE WHEN res.NATION = c.NATION THEN 1 END) > 0
    AND COUNT(CASE WHEN re.RANK <= 3 THEN 1 END) > 0
ORDER BY COUNT(CASE WHEN re.rank <= 3 THEN 1 END) DESC;

/**
  Geef, zonder analytische functies (reporting-, ranking- of window-functies) te gebruiken,
  een oplossing voor volgend probleem: toon voor de wedstrijddagen
  van het laatste kwartaal van 2005 hoeveel wedstrijden er zijn doorgegaan
  gedurende de laatste 10 dagen tot en met die wedstrijddag. Toon ook telkens de begindatum van deze periode.
 */
SELECT TO_CHAR(r1.RACEDATE, 'DD-MM-YY') AS RACEDATE,
       TO_CHAR(r1.RACEDATE - 10, 'DD-MM-YY') AS "begin periode",
       COUNT(CASE WHEN r1.RACEDATE - r2.RACEDATE BETWEEN 0 AND 10 THEN 1 END)
           / SQRT(COUNT(CASE WHEN r1.RACEDATE = r2.RACEDATE THEN 1 END)) AS TEL
FROM RACES r1
JOIN RACES r2 ON r1.RACEDATE - r2.RACEDATE <= 10
WHERE EXTRACT(YEAR FROM r1.RACEDATE) = 2005
  AND EXTRACT(MONTH FROM r1.RACEDATE) >= 10
GROUP BY r1.RACEDATE
HAVING COUNT(1) > 1
ORDER BY r1.RACEDATE;

/**
  Geef, zonder hierbij analytische functies (reporting-, ranking- of window-functies) te gebruiken,
  een gesorteerd overzicht van de dagen vanaf seizoen 2000 waarop wedstrijd(en),
  voor vrouwen en/of voor mannen, werden georganiseerd
  Toon de begindatum van die periode en het aantal wedstrijden in die voorbije 30 dagen.
  Voorzie ook twee aanvullende kolommen die de aantallen wedstrijden in die periode,
  apart voor vrouwen en mannen, weergeven.
 */
SELECT TO_CHAR(x.RACEDATE - 30, 'DD-MM-YY') AS "begin",
       TO_CHAR(x.RACEDATE, 'DD-MM-YY') AS RACEDATE,
       COUNT(1) / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END)) AS "#",
       COUNT(CASE WHEN y.GENDER = 'L' THEN 1 END)
           / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END)) AS "#L",
       COUNT(CASE WHEN y.GENDER = 'M' THEN 1 END)
           / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END)) AS "#M"
FROM RACES x
JOIN RACES y ON y.RACEDATE BETWEEN x.RACEDATE - 30 AND x.RACEDATE
WHERE EXTRACT(YEAR FROM x.RACEDATE + 183) = 2016
GROUP BY x.RACEDATE;

/**
  Voeg, zonder analytische functies (reporting-, ranking- of window-functies) te gebruiken,
  aan de globale wereldbekerresultaten (tabel Ranking) de som van de behaalde punten,
  over alle disciplines heen per competitor volgende gegevens toe:
    een rijnummer, oplopend per season
    de cumultatief behaalde punten
 */
SELECT x.NAME,
       x.SEASON,
       COUNT(DISTINCT y.SEASON) AS nr,
       SUM(CASE WHEN x.SEASON = y.SEASON THEN x.POINTS ELSE 0 END)
           / SQRT(COUNT(CASE WHEN x.SEASON = y.SEASON THEN 1 END)) AS punten,
       SUM(y.POINTS) / SQRT(COUNT(CASE WHEN x.SEASON = y.SEASON THEN 1 END)) AS totaal
FROM RANKING x
JOIN RANKING y ON y.NAME = x.NAME
            AND y.SEASON <= x.SEASON
GROUP BY x.NAME, x.SEASON
ORDER BY x.NAME, x.SEASON;

/**
  Bereken de mediaan van het gewicht van de competitors, en dit per nation.
  Voor elke nation mag je ofwel èèn rij (de mediaan), ofwel twee rijen overhouden.
  In het laatste geval moet je de uitmiddeling (tot de financiële mediaan) niet uitvoeren.
 */
SELECT c1.NATION, c1.WEIGHT
FROM COMPETITORS c1, COMPETITORS c2
WHERE c1.WEIGHT IS NOT NULL AND c2.WEIGHT IS NOT NULL AND c1.NATION = c2.NATION
GROUP BY c1.NATION, c1.WEIGHT
HAVING
    ABS(COUNT(CASE WHEN c1.WEIGHT < c2.WEIGHT THEN 1 END) - COUNT(CASE WHEN c1.WEIGHT > c2.WEIGHT THEN 1 END))
        <= COUNT(CASE WHEN c1.WEIGHT = c2.WEIGHT THEN 1 END)
ORDER BY c1.NATION;

/**
  Geef alle namen van de resorts in Japan en eventueel
  de gegevens van de wedstrijden die er zijn doorgegaan vanaf 2004.
 */
SELECT res.NAME, ra.RACEDATE, ra.DISCIPLINE, res.NATION, ra.RID
FROM RESORTS res
LEFT JOIN RACES ra ON ra.RESORT = res.NAME AND EXTRACT(YEAR FROM ra.RACEDATE) >= 2004
WHERE res.NATION = 'JPN'
ORDER BY res.NAME;

/**
  Stel dat een RDBMS niet beschikt over de max en de countfunctie.
  Hoe kunnen we dan toch hetzelfde resultaat bekomen als volgende query ?
  Geef een oplossing met outer join!!
 */
SELECT t1.HASC, t1.ISO, t1.GEBRUIK
FROM TAALGEBRUIK t1
LEFT JOIN taalgebruik t2 ON t1.HASC = t2.HASC AND t1.GEBRUIK < t2.GEBRUIK
WHERE t2.GEBRUIK IS NULL
ORDER BY t1.HASC;

/**
  Toon de landen (tabel Regios NIVEAU 0) welke niet zijn aangesloten
  bij een internationale organisatie (tabellen Org en Members).
 */
SELECT regios.name
FROM regios
LEFT JOIN members ON REGIOS.HASC = members.HASC
WHERE niveau = 0 AND members.hasc IS NULL
ORDER BY regios.name;

/**
  Zoek die periodes waarin het datumverschil tussen opeenvolgende afdalingen voor mannen meer dan 1 maand
  , maar minder dan 2 maanden was.
 */
SELECT TO_CHAR(x.RACEDATE, 'DD/MM/YY') AS "X.RACEDATE",
       TO_CHAR(y.RACEDATE, 'DD/MM/YY') AS "Y.RACEDATE"
FROM RACES x
JOIN RACES y ON
    y.GENDER = x.GENDER
    AND y.DISCIPLINE = x.DISCIPLINE
    AND y.RACEDATE BETWEEN X.RACEDATE + 30 AND X.RACEDATE + 60
LEFT JOIN RACES z ON z.GENDER = x.GENDER
                AND x.DISCIPLINE = y.DISCIPLINE
                AND y.RACEDATE < z.RACEDATE
                AND z.RACEDATE BETWEEN X.RACEDATE + 30 AND X.RACEDATE + 60
WHERE x.DISCIPLINE = 'DH' AND x.GENDER = 'M' AND z.RACEDATE IS NULL
ORDER BY x.RACEDATE, Y.RACEDATE;

/**
  Omschrijf de ontbrekende elevations in de Cities tabel voor iso='IS' (IJsland)
  zo veel mogelijk als intervallen, waarin alle elevations ontbreken.
  Opgelet voor dubbels !
 */
SELECT x.ELEVATION, y.ELEVATION
FROM CITIES x
JOIN CITIES y ON x.ISO = y.ISO AND y.ELEVATION = x.ELEVATION + 1
WHERE x.ISO = 'IS' AND x.ELEVATION IS NOT NULL;


/**
  Geef, zonder analytische functies (reporting-, ranking- of window-functies) te gebruiken,
  een oplossing voor volgend probleem: toon voor de wedstrijddagen van het laatste kwartaal van 2005 hoeveel wedstrijden
  er zijn doorgegaan gedurende de laatste 10 dagen tot en met die wedstrijddag. Toon ook telkens de begindatum van deze periode.
 */
SELECT TO_CHAR(x.RACEDATE, 'DD-MM-YY') AS RACEDATE,
       TO_CHAR(x.RACEDATE - 10, 'DD-MM-YY') AS "begin periode",
       COUNT(1) / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END))
FROM RACES x
JOIN RACES y ON x.RACEDATE - y.RACEDATE BETWEEN 0 AND 10
WHERE EXTRACT(YEAR FROM x.RACEDATE) = 2005 AND EXTRACT(MONTH FROM x.RACEDATE) >= 10
GROUP BY x.RACEDATE
ORDER BY x.RACEDATE;

/**
Geef, zonder hierbij analytische functies (reporting-, ranking- of window-functies) te gebruiken,
  een gesorteerd overzicht van de dagen vanaf seizoen 2000 waarop wedstrijd(en), voor vrouwen en/of voor mannen,
  werden georganiseerd Toon de begindatum van die periode en het aantal wedstrijden in die voorbije 30 dagen.
  Voorzie ook twee aanvullende kolommen die de aantallen wedstrijden in die periode,
  apart voor vrouwen en mannen, weergeven.
 */
SELECT TO_CHAR(x.RACEDATE - 30, 'DD-MM-YY') AS "BEGIN",
       TO_CHAR(x.RACEDATE, 'DD-MM-YY') AS RACEDATE,
       COUNT(1) / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END)) AS "#",
       COUNT(CASE WHEN y.GENDER = 'L' THEN 1 END)
       / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END)) AS "#L",
       COUNT(CASE WHEN y.GENDER = 'M' THEN 1 END)
       / SQRT(COUNT(CASE WHEN x.RACEDATE = y.RACEDATE THEN 1 END)) AS "#M"
FROM RACES x
JOIN RACES y ON x.RACEDATE - y.RACEDATE BETWEEN 0 AND 30
WHERE EXTRACT(YEAR FROM x.RACEDATE + 183) >= 2010
GROUP BY x.RACEDATE
ORDER BY x.RACEDATE;

/**
  Voeg, zonder analytische functies (reporting-, ranking- of window-functies) te gebruiken,
  aan de globale wereldbekerresultaten(tabel Ranking) de som van de behaalde punten,
  over alle disciplines heen per competitor volgende gegevens toe:
    - een rijnummer, oplopend per season
    - de cumultatief behaalde punten
 */
SELECT x.NAME, x.SEASON,
       COUNT(DISTINCT y.SEASON) AS SEASON,
       SUM(CASE WHEN x.SEASON = y.SEASON THEN x.POINTS ELSE 0 END)
           / SQRT(COUNT(CASE WHEN x.SEASON = y.SEASON THEN 1 END)) AS PUNTEN,
       SUM(y.POINTS) / SQRT(COUNT(CASE WHEN x.SEASON = Y.SEASON THEN 1 END)) AS TOTAAL
FROM RANKING x
JOIN RANKING y ON x.NAME = y.NAME AND y.SEASON <= x.SEASON
GROUP BY x.NAME, x.SEASON
ORDER BY x.NAME, x.SEASON;


/**
  Bereken de mediaan van het gewicht van de competitors, en dit per nation.
  Voor elke nation mag je ofwel èèn rij (de mediaan), ofwel twee rijen overhouden.
  In het laatste geval moet je de uitmiddeling (tot de financiële mediaan) niet uitvoeren.
 */
SELECT x.NATION, x.WEIGHT
FROM COMPETITORS x
JOIN COMPETITORS y ON x.NATION = y.NATION
WHERE x.WEIGHT IS NOT NULL AND y.WEIGHT IS NOT NULL
GROUP BY x.NATION, x.WEIGHT
HAVING ABS(COUNT(CASE WHEN x.WEIGHT < y.WEIGHT THEN 1 END)
        - COUNT(CASE WHEN x.WEIGHT > y.WEIGHT THEN 1 END))
       <= COUNT(CASE WHEN x.WEIGHT = y.WEIGHT THEN 1 END)
ORDER BY x.NATION, x.WEIGHT;

/**
  Geef alle namen van de resorts in Japan
  en eventueel de gegevens van de wedstrijden die er zijn doorgegaan vanaf 2004.
 */
SELECT re.NAME, TO_CHAR(ra.RACEDATE, 'DD/MM/YY'), re.NATION, ra.RID
FROM resorts re
LEFT JOIN RACES ra ON ra.RESORT = re.NAME AND EXTRACT(YEAR FROM ra.RACEDATE) >= 2004
WHERE re.NATION = 'JPN'
ORDER BY re.NAME, ra.RACEDATE;

/**
  Stel dat een RDBMS niet beschikt over de max en de countfunctie.
  Hoe kunnen we dan toch hetzelfde resultaat bekomen als volgende query ?
  Geef een oplossing met outer join!!
 */
SELECT x.HASC, x.ISO, x.GEBRUIK
FROM TAALGEBRUIK x
LEFT JOIN TAALGEBRUIK y ON x.HASC = y.HASC AND x.GEBRUIK < y.GEBRUIK
WHERE y.GEBRUIK IS NULL
GROUP BY x.HASC, x.ISO, x.GEBRUIK
ORDER BY x.HASC, x.GEBRUIK;

/**
  Toon de landen (tabel Regios NIVEAU 0)
  welke niet zijn aangesloten bij een internationale organisatie (tabellen Org en Members).
 */
SELECT r.NAME
FROM regios r
LEFT JOIN members m ON m.HASC = r.HASC
WHERE r.NIVEAU = 0 AND m.HASC IS NULL
ORDER BY r.NAME;

/**
  Zoek die periodes waarin het datumverschil tussen
  opeenvolgende afdalingen voor mannen meer dan 1 maand, maar minder dan 2 maanden was.
 */
SELECT TO_CHAR(x.RACEDATE, 'DD/MM/YY') AS "X.RACEDATE", TO_CHAR(y.RACEDATE, 'DD/MM/YY') AS "Y.RACEDATE"
FROM RACES x
JOIN RACES y ON y.DISCIPLINE = x.DISCIPLINE AND y.GENDER = x.GENDER
                AND y.RACEDATE BETWEEN x.RACEDATE + 30 AND x.RACEDATE + 60
LEFT JOIN RACES z ON z.DISCIPLINE = x.DISCIPLINE AND z.GENDER = x.GENDER
                AND z.RACEDATE BETWEEN x.RACEDATE + 1 AND y.RACEDATE - 1
WHERE x.DISCIPLINE = 'DH' AND x.GENDER = 'M'
    AND z.RACEDATE IS NULL
GROUP BY x.RACEDATE, y.RACEDATE
ORDER BY x.RACEDATE, y.RACEDATE;

/**
  Omschrijf de ontbrekende elevations in de Cities tabel voor iso='IS' (IJsland)
  zo veel mogelijk als intervallen, waarin alle elevations ontbreken. Opgelet voor dubbels !
 */
SELECT low.ELEVATION + 1 AS ELEVATION,
       CASE WHEN high.ELEVATION - low.ELEVATION > 2 THEN high.ELEVATION - 1 END AS " "
FROM CITIES low
JOIN CITIES high ON high.ISO = low.ISO
        AND low.ELEVATION + 1 < high.ELEVATION
LEFT JOIN CITIES betw ON betw.ISO = low.ISO
        AND betw.ELEVATION BETWEEN low.ELEVATION + 1 AND high.ELEVATION - 1
WHERE low.ISO = 'IS'
  AND low.ELEVATION IS NOT NULL
  AND betw.ELEVATION IS NULL
GROUP BY low.ELEVATION, high.ELEVATION
ORDER BY low.ELEVATION;

/**
  Omschrijf de sequentieel opeenvolgende elevations in de Cities tabel voor iso='IS'
  (IJsland) zo veel mogelijk als intervallen, waarin alle elevations optreden. Opgelet voor dubbels !

  Elk interval heeft een low en high bound
    -- Indien ze gelijk zijn => interval van 1 unit
    -- Indien niet => meerdere units tss

  Een interval is gedefinieerd als een eindige rij
  Waarbij
    - Alles tussen low en high niet null is (between)
    - low bound - 1 == NULL (lower)
    - high bound + 1 == NULL (higher)
 */
SELECT low.ELEVATION AS ELEVATION, CASE WHEN low.ELEVATION != high.ELEVATION THEN high.ELEVATION END
FROM CITIES low
JOIN CITIES high ON high.ISO = low.ISO AND high.ELEVATION >= low.ELEVATION
JOIN CITIES betw ON betw.ISO = low.ISO AND betw.ELEVATION BETWEEN low.ELEVATION AND high.ELEVATION
LEFT JOIN CITIES lower ON lower.ISO = low.ISO AND lower.ELEVATION = low.ELEVATION - 1
LEFT JOIN CITIES higher ON higher.ISO = low.ISO AND higher.ELEVATION = high.ELEVATION + 1
WHERE low.ISO = 'IS'
  AND low.ELEVATION IS NOT NULL
  AND lower.ELEVATION IS NULL
  AND higher.ELEVATION IS NULL
GROUP BY low.ELEVATION, high.ELEVATION
HAVING COUNT(DISTINCT betw.ELEVATION) = high.ELEVATION - low.ELEVATION + 1
ORDER BY low.ELEVATION, high.ELEVATION
