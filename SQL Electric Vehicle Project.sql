-- explore data

SELECT *
FROM electric_vehicle_population_data
LIMIT 10;

SELECT COUNT(*) AS total_vehicles
FROM electric_vehicle_population_data;


-- cleaned view

CREATE OR REPLACE VIEW ev_clean AS
SELECT
    UPPER(TRIM(`Make`)) AS make,
    UPPER(TRIM(`Model`)) AS model,
    `Model Year`,
    TRIM(`Electric Vehicle Type`) AS ev_type,

    CASE 
        WHEN `Electric Range` = 0 THEN NULL
        ELSE `Electric Range`
    END AS electric_range,

    TRIM(`County`) AS county,
    TRIM(`City`) AS city,
    TRIM(`State`) AS state,
    `Postal Code`,
    TRIM(`Clean Alternative Fuel Vehicle (CAFV) Eligibility`) AS cafv_eligibility

FROM electric_vehicle_population_data
WHERE `Make` IS NOT NULL
  AND `Model` IS NOT NULL;


-- ev type distribution

SELECT 
    ev_type,
    COUNT(*) AS total
FROM ev_clean
GROUP BY ev_type;


-- yearly trend

SELECT 
    `Model Year`,
    COUNT(*) AS total_cars
FROM ev_clean
GROUP BY `Model Year`
ORDER BY `Model Year`;


-- cte growth analysis

WITH yearly_data AS (
    SELECT 
        `Model Year`,
        COUNT(*) AS total_cars
    FROM ev_clean
    GROUP BY `Model Year`
),
growth AS (
    SELECT 
        `Model Year`,
        total_cars,
        LAG(total_cars) OVER (ORDER BY `Model Year`) AS prev_year
    FROM yearly_data
)
SELECT 
    `Model Year`,
    total_cars,
    prev_year,
    ROUND(
        (total_cars - prev_year) * 100.0 / prev_year,
        2
    ) AS growth_percentage
FROM growth;


-- market share

SELECT 
    make,
    COUNT(*) AS total_cars,

    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS market_share_percentage

FROM ev_clean
GROUP BY make
ORDER BY market_share_percentage DESC;


-- top cities

WITH city_stats AS (
    SELECT 
        city,
        COUNT(*) AS total_ev
    FROM ev_clean
    GROUP BY city
)
SELECT *
FROM city_stats
ORDER BY total_ev DESC
LIMIT 10;


-- segmentation

SELECT 
    make,
    COUNT(*) AS total_cars,

    CASE 
        WHEN COUNT(*) > 10000 THEN 'high'
        WHEN COUNT(*) BETWEEN 5000 AND 10000 THEN 'medium'
        ELSE 'low'
    END AS market_segment

FROM ev_clean
GROUP BY make;


-- year over year comparison (self join)

SELECT 
    a.make,
    a.`Model Year` AS year,
    COUNT(a.make) AS current_year,
    COUNT(b.make) AS previous_year,

    ROUND(
        (COUNT(a.make) - COUNT(b.make)) * 100.0 / NULLIF(COUNT(b.make), 0),
        2
    ) AS yoy_growth

FROM ev_clean a
LEFT JOIN ev_clean b
    ON a.make = b.make
    AND a.`Model Year` = b.`Model Year` + 1

GROUP BY 
    a.make,
    a.`Model Year`
ORDER BY 
    a.make,
    a.`Model Year`;


-- average range

SELECT 
    make,
    ROUND(AVG(electric_range), 2) AS avg_range
FROM ev_clean
WHERE electric_range IS NOT NULL
GROUP BY make
ORDER BY avg_range DESC;


-- rank manufacturers per year (ADDED)

SELECT *
FROM (
    SELECT 
        `Model Year`,
        make,
        COUNT(*) AS total_cars,

        RANK() OVER (
            PARTITION BY `Model Year`
            ORDER BY COUNT(*) DESC
        ) AS rank_per_year

    FROM ev_clean
    GROUP BY `Model Year`, make
) ranked;