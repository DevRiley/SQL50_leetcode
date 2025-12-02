(
    -- Query 1: Find the User
    SELECT 
        u.name AS results
    FROM 
        MovieRating mr
    JOIN 
        Users u ON mr.user_id = u.user_id
    GROUP BY 
        u.user_id
    ORDER BY 
        COUNT(mr.rating) DESC, -- Primary Sort: Most ratings
        u.name ASC             -- Tie-breaker: Alphabetical
    LIMIT 1
)
UNION ALL
(
    -- Query 2: Find the Movie
    SELECT 
        m.title AS results
    FROM 
        MovieRating mr
    JOIN 
        Movies m ON mr.movie_id = m.movie_id
    WHERE 
        mr.created_at BETWEEN '2020-02-01' AND '2020-02-29' -- Filter Feb 2020
    GROUP BY 
        m.movie_id
    ORDER BY 
        AVG(mr.rating) DESC,   -- Primary Sort: Best rating
        m.title ASC            -- Tie-breaker: Alphabetical
    LIMIT 1
);
