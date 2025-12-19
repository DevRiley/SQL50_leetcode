SELECT 
    person_name
FROM (
    SELECT 
        person_name, 
        turn,
        SUM(weight) OVER (ORDER BY turn) AS running_total
    FROM 
        Queue
) AS q
WHERE 
    running_total <= 1000
ORDER BY 
    running_total DESC  -- Pick the largest total that fits
LIMIT 1;
