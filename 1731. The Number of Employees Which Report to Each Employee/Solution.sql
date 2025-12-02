SELECT 
    mgr.employee_id, 
    mgr.name, 
    COUNT(emp.employee_id) AS reports_count, 
    ROUND(AVG(emp.age), 0) AS average_age
FROM 
    Employees mgr
JOIN 
    Employees emp 
    ON mgr.employee_id = emp.reports_to
GROUP BY 
    mgr.employee_id, 
    mgr.name
ORDER BY 
    mgr.employee_id;
