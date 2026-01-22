# 🏆 SQL Case Study: Department Top Three Salaries
> **Category:** Window Functions / Ranking Logic  
> **Difficulty:** Hard  
> **Tags:** `SQL`, `DENSE_RANK()`, `Partition By`, `Subquery`

## 1. Problem Description
**Goal:** Find the "High Earners" in each department.
A **High Earner** is an employee whose salary is in the **top three unique** salaries for that department.

### Table `Employee`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key |
| `name` | varchar | Employee Name |
| `salary` | int | Salary |
| `departmentId` | int | FK to Department |

### Table `Department`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key |
| `name` | varchar | Department Name |

### Example Input
**IT Department Employees:**
1.  Max: $90,000
2.  Joe: $85,000
3.  Randy: $85,000
4.  Will: $70,000
5.  Janet: $69,000

**Sales Department Employees:**
1.  Henry: $80,000
2.  Sam: $60,000

### Expected Output
| Department | Employee | Salary |
| :--- | :--- | :--- |
| IT | Max | 90000 |
| IT | Joe | 85000 |
| IT | Randy | 85000 |
| IT | Will | 70000 |
| Sales | Henry | 80000 |
| Sales | Sam | 60000 |

**Explanation:**
* **Rank 1:** Max ($90k).
* **Rank 2:** Joe ($85k) AND Randy ($85k). *(They share the rank)*.
* **Rank 3:** Will ($70k). *(The next rank is 3, not 4)*.
* **Rank 4:** Janet ($69k). *(Excluded)*.

---

## 💡 Thought Process

### 1. Choosing the Right Ranking Function
The core challenge is handling **ties** (Joe and Randy) and the **gaps** afterwards.
Let's see how different functions rank the salaries [90k, 85k, 85k, 70k]:

* **`ROW_NUMBER()`**: 1, 2, 3, 4. (Randy becomes 3, Will becomes 4. **Wrong**, ties should share rank).
* **`RANK()`**: 1, 2, 2, 4. (Will becomes 4 because 3 is skipped. **Wrong**, we need top 3 unique).
* **`DENSE_RANK()`**: 1, 2, 2, 3. (Will becomes 3. **Correct!** No gaps).



### 2. The Strategy
1.  **Join:** Combine `Employee` and `Department` to get department names.
2.  **Window Function:** Use `DENSE_RANK()` partitioned by `departmentId` and ordered by `salary DESC`.
3.  **Filter:** Select rows where the calculated rank is $\le 3$.

---

## 2. Solutions & Implementation

### ✅ Approach 1: DENSE_RANK() (Modern & Best Practice)
This is the standard solution for "Top N" problems involving ties.

```sql
WITH RankedEmployees AS (
    SELECT 
        d.name AS Department,
        e.name AS Employee,
        e.salary AS Salary,
        DENSE_RANK() OVER (
            PARTITION BY e.departmentId 
            ORDER BY e.salary DESC
        ) AS rk
    FROM 
        Employee e
    JOIN 
        Department d ON e.departmentId = d.id
)
SELECT 
    Department, 
    Employee, 
    Salary
FROM 
    RankedEmployees
WHERE 
    rk <= 3;
```

### 🔹 Approach 2: Correlated Subquery (Legacy / No Window Functions)
If you are on an ancient database version without Window Functions, you have to count "how many distinct salaries are greater than or equal to this one".

```sql
SELECT 
    d.name AS Department,
    e1.name AS Employee,
    e1.salary AS Salary
FROM 
    Employee e1
JOIN 
    Department d ON e1.departmentId = d.id
WHERE 
    3 >= (
        SELECT COUNT(DISTINCT e2.salary) 
        FROM Employee e2 
        WHERE e2.salary >= e1.salary 
        AND e1.departmentId = e2.departmentId
    );
```
*Logic: "If only 1, 2, or 3 distinct salaries are bigger than mine (including mine), then I am in the top 3."*

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. DENSE_RANK** | Windowing | ⭐⭐⭐ High | **O(N log N).** The database sorts salaries once per department. This is highly optimized. |
| **2. Subquery** | `COUNT(DISTINCT)` | ⭐ Low | **O(N²).** For *every single employee*, the database must re-scan the department table to count higher salaries. Extremely slow on large datasets. |

---

## 4. 🔍 Deep Dive

#### 1. Why `PARTITION BY`?
The problem asks for top salaries **"in each of the company's departments"**.
* `PARTITION BY departmentId` tells the ranking counter to reset to 1 whenever it encounters a new department.
* Without partitioning, you would get the top 3 salaries of the *entire company*, mixed together.

#### 2. Why `DISTINCT` in the subquery approach?
The requirement is "top 3 **unique** salaries".
If we had salaries: 90, 85, 85, 85, 70.
* Without `DISTINCT`, 85 is "greater or equal" to 85 three times. The count would be messy.
* With `DISTINCT`, the set of higher salaries is {90, 85}. The count is 2. Correct.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of employees.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `JOIN` | $O(N)$ | Linking employees to departments. |
| **2. Ranking** | `ORDER BY` | $O(N \log N)$ | Sorting employees within partitions to assign ranks. |

**Total Complexity:** $O(N \log N)$.
