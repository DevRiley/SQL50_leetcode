-- Rule 1: Explicit Primary Flag
SELECT 
    employee_id, 
    department_id
FROM 
    Employee
WHERE 
    primary_flag = 'Y'

UNION

-- Rule 2: Employees with only one department
SELECT 
    employee_id, 
    department_id
FROM 
    Employee
GROUP BY 
    employee_id
HAVING 
    COUNT(employee_id) = 1;
