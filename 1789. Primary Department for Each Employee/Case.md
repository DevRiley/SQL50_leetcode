# 🏢 SQL Case Study: Primary Department for Each Employee
> **Category:** Conditional Filtering / Union / Window Functions    
> **Difficulty:** Easy-Medium    
> **Tags:** `SQL`, `UNION`, `GROUP BY`, `HAVING`, `Window Functions`

## 1. Problem Description
**Goal:** Report the **primary department** for each employee.

The rules for determining the primary department are mixed:
1.  **Explicit Rule:** If an employee has a row with `primary_flag = 'Y'`, that is their primary department.
2.  **Implicit Rule:** If an employee belongs to **only one** department, that department is their primary one (even if the flag is 'N', as per the problem note).

### Table `Employee`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `employee_id` | int | Employee ID |
| `department_id` | int | Department ID |
| `primary_flag` | enum | 'Y' or 'N' |

*(employee_id, department_id) is the Primary Key.*

### Example Input
| employee_id | department_id | primary_flag |
| :--- | :--- | :--- |
| 1 | 1 | **N** (Only 1 dept $\rightarrow$ Pick this) |
| 2 | 1 | **Y** (Has Y $\rightarrow$ Pick this) |
| 2 | 2 | N |
| 3 | 3 | **N** (Only 1 dept $\rightarrow$ Pick this) |
| 4 | 2 | N |
| 4 | 3 | **Y** (Has Y $\rightarrow$ Pick this) |
| 4 | 4 | N |

### Expected Output
| employee_id | department_id |
| :--- | :--- |
| 1 | 1 |
| 2 | 1 |
| 3 | 3 |
| 4 | 3 |

---

## 💡 Thought Process

### 1. Analyzing the Two Scenarios
We have two disjoint groups of employees:
* **Group A (Multi-Department):** They have multiple rows. We simply look for `primary_flag = 'Y'`.
* **Group B (Single-Department):** They have only one row. We must pick it regardless of the flag (the problem says the flag is 'N' in this case).

### 2. Strategy Selection
Since the logic conditions are quite different for the two groups, a **Divide and Conquer** strategy works best.
* **Query 1:** Find rows where `primary_flag = 'Y'`.
* **Query 2:** Find rows where the employee appears exactly once (`COUNT = 1`).
* **Combine:** Use `UNION` to merge the results.

---

## 2. Solutions & Implementation

### ✅ Approach 1: UNION (Divide and Conquer)
This approach is very readable because it clearly separates the two business rules.

```sql
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
```

### 🔹 Approach 2: Window Functions (Advanced)
If your database supports Window Functions (like MySQL 8.0+, PostgreSQL, SQL Server), you can calculate the "Department Count" for each employee on the fly without grouping.

```sql
SELECT 
    employee_id, 
    department_id
FROM (
    SELECT 
        *, 
        COUNT(employee_id) OVER(PARTITION BY employee_id) AS dept_count
    FROM 
        Employee
) AS sub
WHERE 
    primary_flag = 'Y' 
    OR 
    dept_count = 1;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic Type | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. UNION** | Set Operation | ⭐⭐ Good | **Best for Clarity.** Conceptually simple. The database runs two separate queries and merges them. `HAVING COUNT` requires a pass, and `WHERE 'Y'` requires a pass. |
| **2. Window Function** | Analytic | ⭐⭐⭐ High | **Best for Efficiency.** It scans the table once (Single Pass) to compute the count and filter simultaneously. Great for large datasets. |

---

## 4. 🔍 Deep Dive

#### 1. Why `UNION` instead of `UNION ALL`?
In this specific problem, the two sets of employees are **mutually exclusive**:
* An employee with `primary_flag = 'Y'` implies they have made a choice, so they likely have multiple departments (or at least one 'Y').
* An employee with `COUNT = 1` has `primary_flag = 'N'` (per problem description).
* Therefore, `UNION ALL` (which keeps duplicates) would actually yield the same result and be slightly faster. However, `UNION` is safer if there's any risk of overlap.

#### 2. The `HAVING` Clause
In Approach 1's second part:
```sql
GROUP BY employee_id HAVING COUNT(employee_id) = 1
```
This is a standard pattern to find "Unique entries". Note that we can select `department_id` here because if the count is 1, there is only one possible `department_id` to return. (In strict SQL modes like `ONLY_FULL_GROUP_BY`, you might need to wrap `department_id` in `MIN()` or `MAX()`, though most LeetCode environments allow this simplified syntax).

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Grouping / Partitioning** | `GROUP BY` or `OVER()` | $O(N \log N)$ | Needs to sort or hash employees to count their departments. |
| **2. Filtering** | `WHERE` | $O(N)$ | Linear scan. |

**Total Complexity:** $O(N \log N)$ (Dominated by the sorting required to count departments per employee).
