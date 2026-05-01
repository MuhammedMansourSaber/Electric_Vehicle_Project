
-- Explore data
SELECT *
FROM electric_vehicle_population_data
LIMIT 10;
-- Purpose: Get total number of EV records in dataset
-- Insight: Understand dataset size
-- Business question: How big is the EV market data we are analyzing?

SELECT COUNT(*) AS total_vehicles
FROM electric_vehicle_population_data;

-- Purpose: Get Distribution of EV Types (BEV vs PHEV)
-- Business question: Which EV type is more common in registrations?
select 
`Electric Vehicle Type`,
count(`Electric Vehicle Type`) as vehicle_count
from 
electric_vehicle_population_data
group by 
`Electric Vehicle Type`;

-- Purpose: Analyze EV type distribution across model years
-- Business question: How does the adoption of BEV vs PHEV change over time?
-- Insight: Identify trends in EV technology preference over the years

SELECT 
    `Model Year`,
    `Electric Vehicle Type`,
    COUNT(*) AS vehicle_count
FROM electric_vehicle_population_data
GROUP BY 
    `Model Year`,
    `Electric Vehicle Type`
ORDER BY 
    `Model Year`,
    vehicle_count DESC;
    
-- Purpose: Identify top EV manufacturer for each model year
-- Business question: Which manufacturer dominates EV market each year?
-- Insight: Track how market leadership changes over time

SELECT *
FROM (
    SELECT 
        `Model Year`,
        Make,
        COUNT(*) AS total_cars,
        RANK() OVER (
            PARTITION BY `Model Year`
            ORDER BY COUNT(*) DESC
        ) AS rank_per_year
    FROM electric_vehicle_population_data
    GROUP BY 
        `Model Year`,
        Make
) ranked_data
WHERE rank_per_year = 1;

-- Purpose: Calculate market share percentage for each EV manufacturer
-- Business question: What percentage of the EV market does each manufacturer hold?
-- Insight: Identify dominant players and market concentration

select 
Make,
count(*) as total_cars,
round(
count(*)* 100 / sum(count(*)) over(),2
) as market_share_percentage
from electric_vehicle_population_data
group by Make
order by market_share_percentage desc; 

-- Purpose: Analyze yearly market share and rank EV manufacturers
-- Business question: Which manufacturers dominate each year in EV market?
-- Insight: Track competition and leadership changes over time

SELECT 
    `Model Year`,
    Make,
    COUNT(*) AS total_cars,
    
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY `Model Year`),
        2
    ) AS market_share_percentage,

    RANK() OVER (
        PARTITION BY `Model Year`
        ORDER BY COUNT(*) DESC
    ) AS rank_per_year

FROM electric_vehicle_population_data
GROUP BY 
    `Model Year`,
    Make
ORDER BY 
    `Model Year`,
    rank_per_year;
    
-- Data Cleaning 

-- Purpose: Create a clean version of EV dataset for analysis
-- Business question: How can we standardize data for reliable reporting?
-- Insight: Remove invalid values and normalize key fields

CREATE VIEW ev_clean AS
SELECT
    TRIM(`Make`) AS make,
    TRIM(`Model`) AS model,
    `Model Year`,
    `Electric Vehicle Type`,

    -- Fix invalid electric range values
    CASE 
        WHEN `Electric Range` = 0 THEN NULL
        ELSE `Electric Range`
    END AS electric_range,

    `County`,
    `City`,
    `State`,
    `Postal Code`,
    `Clean Alternative Fuel Vehicle (CAFV) Eligibility` AS cafv_eligibility
FROM electric_vehicle_population_data;

-- Purpose: Analyze EV adoption over time
-- Business question: Is EV adoption increasing over the years?
-- Insight: Market growth trend

SELECT 
    `Model Year`,
    COUNT(*) AS total_cars
FROM electric_vehicle_population_data
GROUP BY `Model Year`
ORDER BY `Model Year`;





