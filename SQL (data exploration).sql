-- =====================================================
-- 1. DATA EXPLORATION
-- =====================================================

SELECT *
FROM electric_vehicle_population_data
LIMIT 10;

SELECT COUNT(*) AS total_vehicles
FROM electric_vehicle_population_data;


-- =====================================================
-- 2. DATA CLEANING (CREATE CLEAN VIEW)
-- =====================================================

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


-- =====================================================
-- 3. BASIC ANALYSIS
-- =====================================================

-- EV Type Distribution
SELECT 
    ev_type,
    COUNT(*) AS vehicle_count
FROM ev_clean
GROUP BY ev_type;


-- EV Growth Over Time
SELECT 
    `Model Year`,
    COUNT(*) AS total_cars
FROM ev_clean
GROUP BY `Model Year`
ORDER BY `Model Year`;


-- =====================================================
-- 4. ADVANCED ANALYSIS
-- =====================================================

-- Yearly Growth Percentage 
SELECT 
    `Model Year`,
    COUNT(*) AS total_cars,

    LAG(COUNT(*)) OVER (ORDER BY `Model Year`) AS prev_year,

    ROUND(
        (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY `Model Year`)) * 100.0
        / LAG(COUNT(*)) OVER (ORDER BY `Model Year`),
        2
    ) AS growth_percentage

FROM ev_clean
GROUP BY `Model Year`;


-- Market Share by Manufacturer
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


-- Top Manufacturer per Year
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
) ranked
WHERE rank_per_year = 1;


-- =====================================================
-- 5. BUSINESS INSIGHTS QUERIES 
-- =====================================================

-- Average Electric Range by Manufacturer
SELECT 
    make,
    ROUND(AVG(electric_range), 2) AS avg_range
FROM ev_clean
WHERE electric_range IS NOT NULL
GROUP BY make
ORDER BY avg_range DESC;


-- Top Cities by EV Adoption
SELECT 
    city,
    COUNT(*) AS total_ev
FROM ev_clean
GROUP BY city
ORDER BY total_ev DESC
LIMIT 10;


-- EV Type Distribution by City
SELECT 
    city,
    ev_type,
    COUNT(*) AS total
FROM ev_clean
GROUP BY city, ev_type
ORDER BY city;


-- CAFV Eligibility Distribution
SELECT 
    cafv_eligibility,
    COUNT(*) AS total
FROM ev_clean
GROUP BY cafv_eligibility
ORDER BY total DESC;


-- =====================================================
-- 6. Market Share Per Year
-- =====================================================

SELECT 
    `Model Year`,
    make,

    COUNT(*) AS total_cars,

    ROUND(
        COUNT(*) * 100.0 
        / SUM(COUNT(*)) OVER (PARTITION BY `Model Year`),
        2
    ) AS market_share_percentage,

    RANK() OVER (
        PARTITION BY `Model Year`
        ORDER BY COUNT(*) DESC
    ) AS rank_per_year

FROM ev_clean
GROUP BY `Model Year`, make
ORDER BY `Model Year`, rank_per_year;
