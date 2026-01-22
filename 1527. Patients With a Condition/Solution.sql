SELECT 
    patient_id, 
    patient_name, 
    conditions
FROM 
    Patients
WHERE 
    conditions LIKE 'DIAB1%'      -- Case 1: Starts with DIAB1
    OR 
    conditions LIKE '% DIAB1%';   -- Case 2: Contains space + DIAB1
