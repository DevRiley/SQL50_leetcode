SELECT 
    user_id, 
    CONCAT(
        UPPER(LEFT(name, 1)),       -- 1. Grab first char & Uppercase it
        LOWER(SUBSTRING(name, 2))   -- 2. Grab the rest & Lowercase it
    ) AS name
FROM 
    Users
ORDER BY 
    user_id;
