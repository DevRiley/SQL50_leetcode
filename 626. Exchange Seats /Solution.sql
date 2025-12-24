SELECT
    CASE
        -- Case 1: Even ID -> Move back
        WHEN id % 2 = 0 THEN id - 1
        
        -- Case 2: Last ID (if it's Odd) -> Stay put
        WHEN id % 2 = 1 AND id = (SELECT COUNT(*) FROM Seat) THEN id
        
        -- Case 3: Odd ID (not last) -> Move forward
        ELSE id + 1
    END AS id,
    student
FROM 
    Seat
ORDER BY 
    id ASC;
