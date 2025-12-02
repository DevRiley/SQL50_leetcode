# 👔 SQL Case Study: Managers with at Least 5 Direct Reports
> **Category:** Aggregation / Self-Join  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `Self-Join`, `Group By`, `Having`, `Subquery`

## 1. Problem Description
**Goal:** Identify managers who have **at least 5 direct reports** and return their names.

We are given a single table `Employee`. This table contains a hierarchical structure (adjacency list) where `managerId` refers to the `id` of another row in the same table.

### Table `Employee`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key |
| `name` | varchar | Employee name |
| `department`| varchar | Department name |
| `managerId` | int | ID of the manager (Foreign Key to `id`) |

*Note: If `managerId` is null, the employee has no manager (e.g., the CEO).*

### Example Input
**Data:**
* John (101) manages: Dan, James, Amy, Anne, Ron. (Total 5 people)
* The others are just employees.

### Expected Output
| name |
| :--- |
| John |

**Explanation:**
The employee with `id = 101` (John) appears as the `managerId` for 5 distinct rows (102, 103, 104, 105, 106). Therefore, John is included in the result.

---

## 💡 Thought Process

### 1. The Data Structure Challenge (Self-Reference)
The tricky part of this problem is that the "Manager" and the "Employee" are in the **same table**.
* To find out *who* manages *whom*, we usually need to look at the table twice (Self-Join).
* However, if we just need to **count**, we can simply look at the `managerId` column first.

### 2. The Logic Steps
1.  **Count Reports:** Group the table by `managerId`.
2.  **Filter:** Keep only the `managerId`s that appear 5 or more times (`COUNT >= 5`).
3.  **Identify Name:** The result of step 2 gives us IDs (e.g., `101`). We need to map `101` back to the name "John".



---

## 2. Solutions & Implementation

### ✅ Approach 1: Group By + Subquery (The Logic-First Way)
This approach separates the problem into two clean steps: "Find the IDs" then "Find the Names".

```sql
SELECT 
    name 
FROM 
    Employee 
WHERE 
    id IN (
        SELECT 
            managerId 
        FROM 
            Employee 
        GROUP BY 
            managerId 
        HAVING 
            COUNT(id) >= 5
    );
```

### 🔹 Approach 2: Inner Join (The Performance Way)
We join the table to itself.
* **Table `m` (Manager):** The source of the name.
* **Table `r` (Report):** The source of the count.

```sql
SELECT 
    m.name
FROM 
    Employee m
JOIN 
    Employee r ON m.id = r.managerId
GROUP BY 
    m.id, m.name
HAVING 
    COUNT(r.id) >= 5;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Readability | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. Subquery (`IN`)** | ⭐⭐⭐ High | Good | Easiest to write and understand mentally. Modern optimizers handle this well. |
| **2. Self-Join** | ⭐⭐ Medium | Good | Standard relational approach. Requires understanding `GROUP BY` on joined columns. |

---

## 4. 🔍 Deep Dive

#### 1. `HAVING` vs `WHERE`
Why do we use `HAVING COUNT(*) >= 5` instead of `WHERE`?
* **`WHERE`**: Filters **rows** before they are grouped. (e.g., "Filter only employees in Department A").
* **`HAVING`**: Filters **groups** after aggregation. We can only know if a count is >= 5 *after* we have finished counting.

#### 2. Self-Join Visualization
When performing Approach 2 (`m.id = r.managerId`), imagine placing two copies of the `Employee` table side-by-side:

| m.id (Manager) | m.name | ... | r.id (Report) | r.name | r.managerId |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 101 | John | ... | 102 | Dan | 101 |
| 101 | John | ... | 103 | James | 101 |
| 101 | John | ... | 104 | Amy | 101 |

Because "John" appears on the left side 5 times (once for each match on the right), we can `GROUP BY m.name` and count the rows.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the Employee table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Aggregation** | `GROUP BY managerId` | $O(N)$ | The database scans the table to count occurrences of each manager ID. |
| **2. Lookup** | `IN (...)` or `JOIN` | $O(N)$ or $O(M \log N)$ | Depends on indexing. If `id` is indexed (Primary Key), looking up the specific manager names is very fast. |

**Total Complexity:** $O(N)$
(Linear time complexity, as we essentially pass through the table once to count, and once to fetch names).
