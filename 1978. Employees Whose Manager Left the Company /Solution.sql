SELECT 
    e.employee_id
FROM 
    Employees e
LEFT JOIN 
    Employees m ON e.manager_id = m.employee_id
WHERE 
    e.salary < 30000          -- Condition 1: Low Salary
    AND e.manager_id IS NOT NULL -- Safety Check: Must have a manager ID initially
    AND m.employee_id IS NULL -- Condition 2: The Manager was not found
ORDER BY 
    e.employee_id;
