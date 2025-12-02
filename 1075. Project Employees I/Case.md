# 🏗️ SQL Case Study: Project Employees Average Experience
> **Category:** Aggregation / Joins  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `INNER JOIN`, `GROUP BY`, `AVG`, `ROUND`

## 1. Problem Description
**Goal:** Calculate the **average experience years** of all employees assigned to each project.

The result must be:
1.  Grouped by `project_id`.
2.  The average value must be **rounded to 2 decimal places**.

### Table `Project`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `project_id` | int | ID of the project |
| `employee_id` | int | ID of the employee working on the project |

*(project_id, employee_id) is the Primary Key.*

### Table `Employee`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `employee_id` | int | Primary Key |
| `name` | varchar | Employee Name |
| `experience_years` | int | Years of experience |

### Example Input
**Project Table:**
| project_id | employee_id |
| :--- | :--- |
| 1 | 1 |
| 1 | 2 |
| 1 | 3 |
| 2 | 1 |
| 2 | 4 |

**Employee Table:**
| employee_id | name | experience_years |
| :--- | :--- | :--- |
| 1 | Khaled | 3 |
| 2 | Ali | 2 |
| 3 | John | 1 |
| 4 | Doe | 2 |

### Expected Output
| project_id | average_years |
| :--- | :--- |
| 1 | 2.00 |
| 2 | 2.50 |

**Explanation:**
* **Project 1:** Employees [1, 2, 3] with experience [3, 2, 1]. Average = $(3+2+1)/3 = 2.00$.
* **Project 2:** Employees [1, 4] with experience [3, 2]. Average = $(3+2)/2 = 2.50$.

---

## 💡 Thought Process

### 1. Data Combination
The `Project` table tells us *who* is on the project, but not *how much experience* they have. The `Employee` table has the experience data.
* **Action:** We need to join these two tables using `employee_id`.

### 2. Aggregation Strategy
We want one row per project.
* **Action:** `GROUP BY project_id`.

### 3. Calculation & Formatting
We need the average of `experience_years`.
* **Action:** Use `AVG()`.
* **Constraint:** Round to 2 digits.
* **Action:** Wrap the result in `ROUND(..., 2)`.

---

## 2. Solutions & Implementation

### ✅ Approach: Inner Join + Aggregation
This is the standard solution. We use `INNER JOIN` because we only care about employees who are actually assigned to a project (and referential integrity is usually guaranteed by FK constraints).

```sql
SELECT 
    p.project_id, 
    ROUND(AVG(e.experience_years), 2) AS average_years
FROM 
    Project p
JOIN 
    Employee e ON p.employee_id = e.employee_id
GROUP BY 
    p.project_id;
```

---

## 3. 🔍 Deep Dive

#### 1. Why `ROUND(..., 2)`?
Calculators and SQL engines can produce repeating decimals (e.g., $10/3 = 3.33333...$).
* The problem strictly requires formatting the output to 2 decimal places.
* **Note:** In some SQL dialects (like T-SQL/SQL Server), `AVG` on integers returns an integer (truncates decimals). You might need to cast to float first: `AVG(CAST(experience_years AS FLOAT))`. However, in standard MySQL/PostgreSQL, `AVG` automatically returns a decimal for calculation.

#### 2. Join Type Selection
* **`INNER JOIN`**: Used here because `employee_id` in the `Project` table is a Foreign Key to `Employee`. Every ID in `Project` *must* exist in `Employee`.
* **`LEFT JOIN`**: If it were possible to have a project ID with an invalid employee ID (bad data integrity), `LEFT JOIN` would keep the project row, but `experience_years` would be NULL, and `AVG` ignores NULLs.

---

## 4. ⏱️ Time Complexity Analysis

Let $P$ be rows in `Project` and $E$ be rows in `Employee`.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `JOIN` | $O(P)$ or $O(P \log E)$ | Depends on indexing. Since `employee_id` is PK in Employee, lookups are fast. |
| **2. Aggregation** | `GROUP BY` | $O(P)$ | We iterate through the joined result set to calculate averages. |

**Total Complexity:** $O(P)$ (Linear relative to the size of the Project assignments).
