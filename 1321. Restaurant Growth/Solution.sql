WITH DailyStats AS (
    -- Step 1: Aggregate multiple transactions per day
    SELECT 
        visited_on, 
        SUM(amount) AS daily_total
    FROM 
        Customer
    GROUP BY 
        visited_on
)
SELECT 
    visited_on, 
    -- Step 2: Calculate Sum over 7-day window
    SUM(daily_total) OVER (
        ORDER BY visited_on 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS amount, 
    -- Step 3: Calculate Average over 7-day window
    ROUND(AVG(daily_total) OVER (
        ORDER BY visited_on 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS average_amount
FROM 
    DailyStats
-- Step 4: Filter to start only after the 7th day
WHERE 
    visited_on >= (
        SELECT DATE_ADD(MIN(visited_on), INTERVAL 6 DAY) 
        FROM Customer
    )
ORDER BY 
    visited_on;
