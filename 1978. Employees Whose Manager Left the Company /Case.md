# 👻 SQL Case Study: Employees Whose Manager Left the Company
> **Category:** Join Logic / Data Integrity  
> **Difficulty:** Easy-Medium  
> **Tags:** `SQL`, `Anti-Join`, `LEFT JOIN`, `IS NULL`, `NOT EXISTS`

## 1. Problem Description
**Goal:** Find the IDs of employees who meet **two conditions**:
1.  Their salary is **strictly less than $30,000**.
2.  Their manager has left the company. (This means the `manager_id` field has a value, but that value **does not exist** in the `employee_id` column of the table anymore).

### Table `Employees`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `employee_id` | int | Primary Key |
| `name` | varchar | Employee Name |
| `manager_id` | int | ID of the Manager (Nullable) |
| `salary` | int | Monthly Salary |

### Example Input
| employee_id | name | manager_id | salary |
| :--- | :--- | :--- | :--- |
| 1 | Kalel | 11 | 21241 |
| 11 | Joziah | **6** | 28485 |
| 6 | (Deleted) | - | - |

*(Note: Employee 6 is missing from the table)*

### Expected Output
| employee_id |
| :--- |
| 11 |

**Explanation:**
* **Kalel (1):** Salary < 30000. Manager is 11. Employee 11 (Joziah) exists. $\rightarrow$ Exclude.
* **Joziah (11):** Salary < 30000. Manager is 6. Employee 6 does **not** exist in the table. $\rightarrow$ Include.
* **Others:** Salaries are too high.

---

## 💡 Thought Process

### 1. Identifying "Orphan" Records
We are looking for rows where `manager_id` points to a "ghost".
* Valid relationship: `Child.manager_id` exists in `Parent.employee_id`.
* Broken relationship (Manager left): `Child.manager_id` has a number (e.g., 6), but looking up 6 in the ID list returns nothing.

### 2. Strategy: The Anti-Join
The most standard way to find missing relationships is:
1.  **Left Join** the table to itself (Employee to Manager).
2.  **Filter** for rows where the Manager side is `NULL` (meaning the join failed).

---

## 2. Solutions & Implementation

### ✅ Approach 1: LEFT JOIN (Anti-Join Pattern)
We try to join the employee with their manager. If the manager is missing, the columns from the `m` (manager) table will be `NULL`.

```sql
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
```

### 🔹 Approach 2: NOT IN / NOT EXISTS (Subquery)
We can intuitively ask: "Select employees where the manager_id is NOT in the list of current employee IDs".

```sql
SELECT 
    employee_id
FROM 
    Employees
WHERE 
    salary < 30000
    AND manager_id IS NOT NULL
    AND manager_id NOT IN (
        SELECT employee_id FROM Employees
    )
ORDER BY 
    employee_id;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. LEFT JOIN** | `m.id IS NULL` | ⭐⭐⭐ High | **Standard & Robust.** This is the classic "Anti-Join". It handles NULLs safely and is typically optimized very well by database engines. |
| **2. NOT IN** | `Subquery` | ⭐⭐ Medium | **Risky with NULLs.** If the subquery (`SELECT employee_id`) contained a NULL value, `NOT IN` would break (return nothing). Since `employee_id` is a Primary Key here, it's safe, but in general practice, `NOT EXISTS` is preferred over `NOT IN`. |

---

## 4. 🔍 Deep Dive

#### 1. Why `e.manager_id IS NOT NULL`?
It is crucial to filter out employees who legitimately have **no manager** (like the CEO, e.g., `manager_id` is NULL).
* If we don't check this, the `LEFT JOIN` condition `ON NULL = NULL` fails (because NULL != NULL), so `m.employee_id` becomes NULL.
* The query might mistakenly think the CEO's manager "left the company", when in fact they never had one.

#### 2. The Logic of `m.employee_id IS NULL`
When you `LEFT JOIN` table A to B:
* **Match Found:** Table B columns have values.
* **No Match Found:** Table B columns are filled with `NULL`.
Checking for this NULL is the most efficient way to detect "missing" counterparts.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the `Employees` table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `LEFT JOIN` | $O(N)$ or $O(N \log N)$ | Using the PK index on `employee_id`, lookups are fast. |
| **2. Filtering** | `WHERE` | $O(N)$ | Scans the joined result. |

**Total Complexity:** $O(N)$ (Assuming Hash Join or Indexed Nested Loop Join).
