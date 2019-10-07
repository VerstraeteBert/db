SELECT CASE nation
    WHEN 'ITA' THEN 'Italie'
    WHEN 'GER' THEN 'Duitsland'
    WHEN 'AUT' THEN 'Oostenrijk'
    WHEN 'SUI' THEN 'Zwitserland'
    ELSE nation end as "land"
FROM resorts;

SELECT name, finishaltitude, CASE
    WHEN finishaltitude < 1300 THEN 'laag'
    WHEN finishaltitude BETWEEN 1300 AND 1700 THEN 'middelmatig'
    WHEN finishaltitude > 1700 THEN 'hoog'
    END AS hoogte
FROM resorts
WHERE finishaltitude IS NOT NULL
ORDER BY finishaltitude;

SELECT name, finishaltitude, 
    CASE 
        WHEN finishaltitude < 1300 THEN 'x' ELSE ' '
    END AS laag,
    CASE 
        WHEN finishaltitude BETWEEN 1300 AND 1700 then 'x' else ' '
    END AS middelmatig,
    CASE
        WHEN finishaltitude > 1700 then 'x' else ' '
    END AS hoog
FROM resorts
WHERE finishaltitude IS NOT NULL
ORDER BY finishaltitude;

SELECT DISTINCT discipline, resort
FROM races
WHERE discipline IS NOT NULL
ORDER BY
    CASE discipline
        WHEN 'KB' THEN 1
        WHEN 'GS' THEN 2
        WHEN 'SL' THEN 3
        WHEN 'DH' THEN 4
        WHEN ' SG' THEN 5
        ELSE 6
    END;
    
SELECT rid, modus
FROM RACES
WHERE discipline = 'SL' AND gender = 'M'
ORDER BY 
    CASE
        WHEN modus IS NULL THEN 1
        ELSE 2
    END,
    modus;

SELECT name, bmi, 
    CASE 
        WHEN bmi < 18.5 THEN 'ondergewicht'
        WHEN bmi BETWEEN 18.5 and 24.9999 THEN 'normaal'
        WHEN bmi > 24.999 THEN 'overgewicht'
    END AS bmi_cat
FROM (
    SELECT name, round((weight/(height*height)), 5) as bmi
    FROM competitors
    WHERE height > 0 AND weight > 0 AND gender = 'M'
)
ORDER BY 
    CASE bmi_cat
        WHEN 'ondergewicht' THEN 1
        WHEN 'normaal' THEN 2
        WHEN 'overgewicht' THEN 3
    END, 
    name;
    

SELECT name, bmi, 
    CASE WHEN gender = 'M' THEN 
        (CASE 
            WHEN bmi < 18.5 THEN 'ondergewicht'
            WHEN bmi BETWEEN 18.5 and 24.9999 THEN 'normaal'
            WHEN bmi > 24.999 THEN 'overgewicht'
        END)
    WHEN gender = 'L' THEN
        (CASE 
            WHEN bmi < 17  THEN 'ondergewicht'
            WHEN bmi BETWEEN 17 and 23.9999 THEN 'normaal'
            WHEN bmi >= 24 THEN 'overgewicht'
        END)
    END as bmi_cat
FROM (
    SELECT name, gender, round((weight/(height*height)), 5) as bmi
    FROM competitors
    WHERE height > 0 AND weight > 0
)
ORDER BY 
    CASE bmi_cat
        WHEN 'ondergewicht' THEN 1
        WHEN 'normaal' THEN 2
        WHEN 'overgewicht' THEN 3
    END, 
    name;

SELECT name, bmi, 
    CASE 
        WHEN (gender = 'M' AND BMI < 18.5) OR (gender = 'L' AND BMI < 17)
            THEN 'x' ELSE ' '
    END as ondergewicht,
    CASE
        WHEN (gender = 'M' AND BMI BETWEEN 18.5 AND 24.9999) OR (gender = 'L' AND BMI < 23.9999)
            THEN 'x' ELSE ' '
    END as normaal,
    CASE WHEN (gender = 'M' AND BMI > 24.9999) OR (gender = 'L' AND BMI > 23.9999)
        THEN 'x' ELSE ' '
    END as overgewicht
FROM (
    SELECT name, gender, round((weight/(height*height)), 5) as bmi
    FROM competitors
    WHERE height > 0 AND weight > 0
)
ORDER BY bmi, name;

SELECT racedate, resort,
    CASE discipline
        WHEN 'SL' THEN 'Slalom'
        WHEN 'GS' THEN 'Reuzeslalom'
        WHEN 'SG' THEN 'Super-G'
        WHEN 'DH' THEN 'Afdaling'
        ELSE 'Combinatie'
    END as casediscipl
FROM races
WHERE EXTRACT(YEAR FROM racedate) = 2006
ORDER BY
    CASE discipline
        WHEN 'SL' THEN 1
        WHEN 'GS' THEN 2
        WHEN 'SG' THEN 3
        WHEN 'DH' THEN 4
        ELSE 5
    END;

SELECT racedate, resort,
    CASE 
        WHEN discipline = 'DH' THEN 'x' ELSE ' '
    END AS afdaling,
    CASE 
        WHEN discipline = 'SG' THEN 'x' ELSE ' '
    END AS superg,
    CASE 
        WHEN discipline = 'GS' THEN 'x' ELSE ' '
    END AS reuzeslalom,
    CASE 
        WHEN discipline = 'SL' THEN 'x' ELSE ' '
    END AS slalom,
    CASE 
        WHEN discipline = 'KB' THEN 'x' ELSE ' '
    END AS combinatie
FROM races
WHERE EXTRACT(YEAR FROM racedate) = 2006
ORDER BY racedate, resort;

SELECT rid, rank, 
    CASE WHEN points IS NOT NULL THEN points ELSE 0 END as points
FROM Results
WHERE rank = 4 and points < 12;

SELECT name, 
    CASE 
        WHEN gender IS NULL THEN 'onbekend'
        WHEN gender = 'M' THEN 'man'
        WHEN gender = 'L' THEN 'vrouw'
    END AS gender
FROM Competitors
ORDER BY name;

SELECT name, nation,
    CASE 
        WHEN finishaltitude < 1300 THEN 'laag'
        WHEN finishaltitude BETWEEN 1330 AND 1700 THEN 'middelmatig'
        WHEN finishaltitude > 1700 THEN 'hoog'
    END AS hoogte
FROM resorts
WHERE finishaltitude is not null
ORDER BY 
    CASE nation
        WHEN 'ITA' THEN  1
        WHEN 'SUI' THEN 2
        WHEN 'AUT' THEN 3
        ELSE 4 
    END,
    finishaltitude;

SELECT EXTRACT(YEAR FROM (racedate + 183)) as seizoen, racedate,
    CASE WHEN EXTRACT(MONTH FROM racedate) BETWEEN 3 AND 6
        THEN (CASE WHEN 
                    (EXTRACT(MONTH FROM racedate) = 3 AND EXTRACT(DAY FROM racedate) < 21
                    OR EXTRACT(MONTH FROM racedate) = 6 AND EXTRACT(DAY FROM racedate) > 20)
                        THEN ' '
                        ELSE 'x' 
              END) 
        ELSE ' ' 
    END AS lente,
    CASE WHEN EXTRACT(MONTH FROM racedate) BETWEEN 6 AND 9
        THEN (CASE WHEN 
                    (EXTRACT(MONTH FROM racedate) = 6 AND EXTRACT(DAY FROM racedate) < 21
                    OR EXTRACT(MONTH FROM racedate) = 9 AND EXTRACT(DAY FROM racedate) > 20)
                        THEN ' '
                        ELSE 'x' 
              END) 
        ELSE ' ' 
    END AS zomer,
    CASE WHEN EXTRACT(MONTH FROM racedate) BETWEEN 9 AND 12
        THEN (CASE WHEN 
                    (EXTRACT(MONTH FROM racedate) = 9 AND EXTRACT(DAY FROM racedate) < 21
                    OR EXTRACT(MONTH FROM racedate) = 12 AND EXTRACT(DAY FROM racedate) > 20)
                        THEN ' '
                        ELSE 'x' 
              END) 
        ELSE ' ' 
    END as herfst,
    CASE WHEN EXTRACT(MONTH FROM racedate) IN (12, 1, 2, 3)
        THEN (CASE WHEN 
                    (EXTRACT(MONTH FROM racedate) = 12 AND EXTRACT(DAY FROM racedate) < 21
                    OR EXTRACT(MONTH FROM racedate) = 3 AND EXTRACT(DAY FROM racedate) > 20)
                        THEN ' '
                        ELSE 'x' 
              END) 
        ELSE ' ' 
    END as winter
FROM (
    SELECT racedate
    FROM races
    WHERE EXTRACT(YEAR FROM (racedate + 183)) BETWEEN 1990 AND 1993 AND discipline = 'SL'
)
ORDER BY seizoen
