# 🆔 SQL Case Study: Replace Employee ID with Unique Identifier
> **Category:** Join Types / NULL Handling    
> **Difficulty:** Easy    
> **Tags:** `SQL`, `LEFT JOIN`, `Basic Syntax`

## 1. Problem Description
**Goal:** Display the name of **every** employee from the `Employees` table, along with their `unique_id` from the `EmployeeUNI` table.

**Crucial Requirement:** If an employee does not have a `unique_id` (i.e., no matching row in the `EmployeeUNI` table), display `null` for that column.

### Table `Employees`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key (Employee ID) |
| `name` | varchar | Employee Name |

### Table `EmployeeUNI`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Foreign Key to Employees |
| `unique_id` | int | The Unique Identifier |

### Example Input
**Employees Table:**
| id | name |
| :--- | :--- |
| 1 | Alice |
| 7 | Bob |
| 3 | Jonathan |

**EmployeeUNI Table:**
| id | unique_id |
| :--- | :--- |
| 3 | 1 |

### Expected Output
| unique_id | name |
| :--- | :--- |
| null | Alice |
| null | Bob |
| 1 | Jonathan |

**Explanation:**
* **Alice (1):** ID 1 is NOT in `EmployeeUNI`. Result: `null`.
* **Bob (7):** ID 7 is NOT in `EmployeeUNI`. Result: `null`.
* **Jonathan (3):** ID 3 IS in `EmployeeUNI`. Result: `1`.

---

## 💡 Thought Process

### 1. Identify the "Master" Table
We want to show the name of **every** employee.
* This means the `Employees` table is our "Master" or "Left" table. We must preserve all rows from it.

### 2. Identify the "Enrichment" Table
We want to add extra information (`unique_id`) from `EmployeeUNI` if it exists.
* This is the "Right" table.

### 3. Choosing the Join Type
* **`INNER JOIN`**: Only keeps rows where IDs exist in **both** tables. Alice and Bob would be deleted. (Wrong)
* **`LEFT JOIN`**: Keeps all rows from the Left table (`Employees`). If no match is found in the Right table, fills the columns with `NULL`. (Correct)

---

## 2. Solutions & Implementation

### ✅ Approach 1: LEFT JOIN (Standard)
This is the most standard way to solve "enrichment" problems where data might be missing.

```sql
SELECT 
    eu.unique_id, 
    e.name
FROM 
    Employees e
LEFT JOIN 
    EmployeeUNI eu ON e.id = eu.id;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | SQL Syntax | Result on Missing Data |
| :--- | :--- | :--- |
| **LEFT JOIN** | `Employees LEFT JOIN EmployeeUNI` | ✅ **Preserves Alice & Bob.** Returns `NULL` for their unique IDs. |
| **INNER JOIN** | `Employees JOIN EmployeeUNI` | ❌ **Deletes Alice & Bob.** Only returns Jonathan because he is the only one with a match. |
| **RIGHT JOIN** | `Employees RIGHT JOIN EmployeeUNI` | ❌ **Preserves IDs, loses Names.** If there were IDs in `EmployeeUNI` that didn't exist in `Employees` (orphan records), this would keep them, but that's not the goal here. |



[Image of SQL Join Types Venn Diagram]


---

## 4. 🔍 Deep Dive

#### 1. Why `eu.unique_id` first?
The problem example output shows `unique_id` as the first column. In SQL, the order of columns in the `SELECT` clause determines the order in the output.
* `SELECT eu.unique_id, e.name` -> Output: `| unique_id | name |`
* `SELECT e.name, eu.unique_id` -> Output: `| name | unique_id |`

#### 2. Naming Aliases
Using aliases (`e` for `Employees`, `eu` for `EmployeeUNI`) is best practice. It makes the code readable and helps avoid "Ambiguous Column" errors if both tables had a column with the exact same name (like `id`).

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be rows in `Employees` and $M$ be rows in `EmployeeUNI`.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `LEFT JOIN` | $O(N)$ or $O(N \log M)$ | Depends on indexing. Since `id` is the Primary Key in `Employees` and likely indexed in `EmployeeUNI`, the lookup is very fast. |

**Total Complexity:** $O(N)$.
