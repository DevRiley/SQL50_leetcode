# 📐 SQL Case Study: Triangle Judgement
> **Category:** Logic / Control Flow  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `CASE WHEN`, `IF`, `Math Logic`

## 1. Problem Description
**Goal:** Determine if three line segments can form a valid triangle.

For each row containing three lengths $(x, y, z)$, we need to output "Yes" if they form a triangle, and "No" otherwise.

**Triangle Inequality Theorem:**
For any three sides to form a triangle, the sum of **any two sides** must be strictly greater than the third side.
1.  $x + y > z$
2.  $x + z > y$
3.  $y + z > x$

All three conditions must be true.

### Table `Triangle`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `x` | int | Length of side 1 |
| `y` | int | Length of side 2 |
| `z` | int | Length of side 3 |

*(x, y, z) is the Primary Key.*

### Example Input
| x | y | z | Evaluation | Result |
| :--- | :--- | :--- | :--- | :--- |
| 13 | 15 | 30 | $13+15 = 28$. Is $28 > 30$? **No.** | **No** |
| 10 | 20 | 15 | $10+20 > 15$ (Yes), $10+15 > 20$ (Yes), $20+15 > 10$ (Yes) | **Yes** |

### Expected Output
| x | y | z | triangle |
| :--- | :--- | :--- | :--- |
| 13 | 15 | 30 | No |
| 10 | 20 | 15 | Yes |

---

## 💡 Thought Process

### 1. The Logic
We need to perform a row-by-row check. This is not an aggregation problem, nor is it a filtering problem (we keep all rows). It is a **Transformation** problem (adding a new column based on logic).

### 2. The Tool: CASE WHEN
In SQL, conditional logic within a `SELECT` clause is handled by `CASE WHEN`.
* Structure:
  ```sql
  CASE
      WHEN condition_is_true THEN 'Value A'
      ELSE 'Value B'
  END
  ```

---

## 2. Solutions & Implementation

### ✅ Approach 1: CASE WHEN (Standard SQL)
This works in almost every SQL dialect (MySQL, PostgreSQL, SQL Server, Oracle).

```sql
SELECT 
    x, 
    y, 
    z,
    CASE 
        WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes'
        ELSE 'No'
    END AS triangle
FROM 
    Triangle;
```

### 🔹 Approach 2: IF() Function (MySQL Specific)
If you are strictly using MySQL, the `IF()` function offers a shorter syntax, similar to Excel.

```sql
SELECT 
    x, 
    y, 
    z,
    IF(x + y > z AND x + z > y AND y + z > x, 'Yes', 'No') AS triangle
FROM 
    Triangle;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Portability | Note |
| :--- | :--- | :--- | :--- |
| **1. CASE WHEN** | `CASE WHEN .. THEN .. END` | ⭐⭐⭐ High | **Recommended.** It is the ISO standard. Always prefer this for interview code. |
| **2. IF Function** | `IF(cond, val, val)` | ⭐ Low | **MySQL Only.** Good for quick scripts, but fails in PostgreSQL or SQL Server. |

---

## 4. 🔍 Deep Dive

#### 1. Why check all three?
A common mistake is to only check $x + y > z$.
* Counter Example: $x=100, y=1, z=2$.
* $100 + 1 > 2$ is **True**.
* But these cannot form a triangle because $1 + 2$ is not greater than $100$.
* Therefore, you must check **all permutations** OR sort them first (Smallest + Middle > Largest). Since SQL doesn't sort columns horizontally easily, checking all three is the standard approach.

#### 2. Data Types & Overflow
In extreme edge cases (like competitive programming), adding two large Integers (`x + y`) could exceed the maximum limit of an `INT` (Integer Overflow).
* **Safe Practice:** In a real-world system with massive numbers, you might cast them to `BIGINT` before adding: `CAST(x AS BIGINT) + y > z`.
* For this problem's constraints, standard integer arithmetic is usually sufficient.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the `Triangle` table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Evaluation** | `CASE WHEN` | $O(N)$ | The arithmetic $(+, >)$ is performed once per row. |

**Total Complexity:** $O(N)$.
