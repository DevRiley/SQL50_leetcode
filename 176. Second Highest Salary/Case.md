# 🥈 SQL Case Study: Second Highest Salary
> **Category:** Aggregation / Subqueries / Limit & Offset  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `MAX()`, `LIMIT OFFSET`, `IFNULL`, `Subquery`

## 1. Problem Description
**Goal:** Find the **second highest distinct** salary from the `Employee` table.

**Critical Constraint:** If there is no second highest salary (e.g., table has only 1 row or all salaries are equal), the query must return `null`.

### Table `Employee`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key |
| `salary` | int | Salary Amount |

### Example Input
**Case 1 (Standard):**
| id | salary |
| :--- | :--- |
| 1 | 100 |
| 2 | 200 |
| 3 | 300 |
*Sorted Distinct:* [300, 200, 100]. Second is **200**.

**Case 2 (Edge Case - Not enough data):**
| id | salary |
| :--- | :--- |
| 1 | 100 |
*Sorted Distinct:* [100]. No second item. Result must be **null**.

---

## 💡 Thought Process

### 1. The Logic: Sorting vs. Exclusion
We can think of this in two ways:
1.  **Sorting:** Sort the distinct salaries in descending order (300, 200, 100) and pick the 2nd one.
2.  **Exclusion:** The "Second Highest" is technically the "Maximum salary that is *not* the absolute Maximum".



### 2. The "NULL" Trap
This is where most candidates fail.
* Running a simple query like `SELECT ... LIMIT 1 OFFSET 1` on a table with 1 row returns **Empty Set** (0 rows).
* The problem asks for **`NULL`** (1 row containing a null value).
* **Fix:** We must wrap the query in a `SELECT (...)` or use a function like `MAX()` which inherently returns `NULL` if no data matches.

---

## 2. Solutions & Implementation

### ✅ Approach 1: LIMIT / OFFSET with Nested SELECT (Most Intuitive)
We sort the data, skip the first one, and take the next.
* **Crucial Step:** Wrapping the entire query in an outer `SELECT (...) AS SecondHighestSalary` forces the database to return a `NULL` object if the inner query returns nothing.

```sql
SELECT (
    SELECT DISTINCT salary 
    FROM Employee 
    ORDER BY salary DESC 
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;
```

### 🔹 Approach 2: MAX() with Subquery (Most Compatible)
We find the max salary that is *strictly less than* the overall max salary.
Logic: $Max(Salary \text{ where } Salary < OverallMax)$.
* This approach automatically returns `NULL` if no such value exists, without needing extra wrappers.

```sql
SELECT 
    MAX(salary) AS SecondHighestSalary 
FROM 
    Employee 
WHERE 
    salary < (SELECT MAX(salary) FROM Employee);
```

### 🔹 Approach 3: Window Functions (DENSE_RANK)
For interviewers looking for advanced SQL skills. We rank salaries and then pick Rank 2. We use `IFNULL` to handle the empty case.

```sql
SELECT 
    IFNULL(
        (SELECT DISTINCT salary
         FROM (
             SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) as rk 
             FROM Employee
         ) sub
         WHERE rk = 2), 
    NULL) AS SecondHighestSalary;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic | Null Safety | Note |
| :--- | :--- | :--- | :--- |
| **1. LIMIT OFFSET** | `OFFSET 1` | ⭐ Requires Wrapper | **Cleanest Syntax.** Easy to read. Requires the outer `SELECT` to satisfy the "Return NULL" requirement. |
| **2. MAX Subquery** | `MAX < MAX` | ⭐⭐⭐ Automatic | **Best Portability.** Works on almost all SQL engines (even those without LIMIT/OFFSET support). `MAX()` on an empty set returns `NULL` by default. |
| **3. DENSE_RANK** | Ranking | ⭐ Conditional | **Overkill.** Good for "N-th Highest" problems (e.g., 5th or 10th), but too verbose for just the 2nd highest. |

---

## 4. 🔍 Deep Dive

#### 1. Why `DISTINCT` is mandatory
If we have salaries `[100, 200, 200]`:
* Without `DISTINCT`, `ORDER BY DESC` gives `200, 200, 100`.
* `OFFSET 1` would skip the first 200 and return the second **200**.
* This is wrong. The second highest value is 100. `DISTINCT` fixes this list to `[200, 100]`.

#### 2. The Difference between "Empty Set" and "NULL"
* **Empty Set:** The table result has 0 rows. (Visual: An empty box).
* **NULL:** The table result has 1 row, and the value in that row is `NULL`. (Visual: A box containing the word "Nothing").
* The LeetCode/Hackerrank checkers specifically expect the latter.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Sorting/Scanning** | `ORDER BY` or `MAX` | $O(N)$ or $O(N \log N)$ | Finding MAX is linear $O(N)$. Sorting is $O(N \log N)$. |

**Conclusion:** Approach 2 (MAX subquery) is generally faster ($2 \times O(N)$) than Approach 1 (Sorting $O(N \log N)$) on very large datasets without indexes.
