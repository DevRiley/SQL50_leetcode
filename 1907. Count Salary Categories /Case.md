# 💰 SQL Case Study: Count Salary Categories
> **Category:** Data Aggregation / Fixed Result Set  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `UNION ALL`, `Handling Zero Counts`, `Hardcoding Categories`

## 1. Problem Description
**Goal:** Calculate the number of bank accounts falling into three specific salary categories:
1.  **Low Salary:** `< $20,000`
2.  **Average Salary:** `[$20,000, $50,000]` (Inclusive)
3.  **High Salary:** `> $50,000`

**Critical Requirement:** The result table **must** contain all three categories. If a category has no accounts, the count should be **0**.

### Table `Accounts`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `account_id` | int | Primary Key |
| `income` | int | Monthly Income |

### Example Input
| account_id | income |
| :--- | :--- |
| 3 | 108939 (High) |
| 2 | 12747 (Low) |
| 8 | 87709 (High) |
| 6 | 91796 (High) |

*(Note: There are no incomes between 20k and 50k)*

### Expected Output
| category | accounts_count |
| :--- | :--- |
| Low Salary | 1 |
| Average Salary | 0 |
| High Salary | 3 |

---

## 💡 Thought Process

### 1. The Trap: `GROUP BY`
A natural first thought is to categorise the rows using `CASE WHEN` and then `GROUP BY`.
```sql
-- ❌ THIS WILL FAIL
SELECT 
    CASE WHEN income < 20000 THEN 'Low Salary' ... END as category, 
    COUNT(*) 
FROM Accounts 
GROUP BY category;
```
**Why it fails:** If there is **no data** for 'Average Salary', the `CASE WHEN` never generates that string. Consequently, `GROUP BY` never sees that bucket, and the row is simply missing from the output. The requirement specifically asks for "Average Salary | 0".

### 2. The Solution: Hardcoding Rows (`UNION`)
Since we *know* exactly which 3 rows we need, we can manually construct them using `UNION ALL`.
* Query 1: Calculate count for 'Low Salary'.
* Query 2: Calculate count for 'Average Salary'.
* Query 3: Calculate count for 'High Salary'.
* Combine them.

Since each query is independent (e.g., `SELECT 'Low Salary', COUNT(*) ... WHERE income < 20000`), if no rows match the `WHERE` clause, `COUNT(*)` returns **0**, which is exactly what we want.

---

## 2. Solutions & Implementation

### ✅ Approach 1: UNION ALL (The Robust Way)
We create three separate queries and stack them together. This ensures all 3 categories always appear.

```sql
SELECT 
    'Low Salary' AS category, 
    COUNT(account_id) AS accounts_count
FROM 
    Accounts
WHERE 
    income < 20000

UNION ALL

SELECT 
    'Average Salary' AS category, 
    COUNT(account_id) AS accounts_count
FROM 
    Accounts
WHERE 
    income >= 20000 AND income <= 50000

UNION ALL

SELECT 
    'High Salary' AS category, 
    COUNT(account_id) AS accounts_count
FROM 
    Accounts
WHERE 
    income > 50000;
```

### 🔹 Approach 2: Left Join with Generated Table (Advanced)
If you want to avoid scanning the table 3 times, you can create a "Master List" of categories and `LEFT JOIN` the data to it.

```sql
SELECT 
    t.category,
    COUNT(a.account_id) AS accounts_count
FROM (
    -- Create the skeleton table
    SELECT 'Low Salary' AS category
    UNION SELECT 'Average Salary'
    UNION SELECT 'High Salary'
) t
LEFT JOIN 
    Accounts a ON (
        CASE 
            WHEN a.income < 20000 THEN 'Low Salary'
            WHEN a.income BETWEEN 20000 AND 50000 THEN 'Average Salary'
            WHEN a.income > 50000 THEN 'High Salary'
        END
    ) = t.category
GROUP BY 
    t.category;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. UNION ALL** | 3 Separate Scans | ⭐ Medium | **Simplest to Write.** Logic is crystal clear. Guarantees 0s appear. While it technically scans the table 3 times, database optimizers can often handle this efficiently for simple counts. |
| **2. LEFT JOIN** | 1 Scan + Logic | ⭐⭐⭐ High | **Best for Huge Data.** Only passes through the `Accounts` table once. However, the syntax is more verbose and requires constructing a temporary table derived table. |

---

## 4. 🔍 Deep Dive

#### 1. Why `COUNT(account_id)` works with `WHERE` filtering
In the `UNION ALL` approach:
```sql
SELECT 'Average Salary', COUNT(account_id) FROM Accounts WHERE income BETWEEN 20000 AND 50000
```
If no rows match the `WHERE` clause:
1.  The database returns **one row** because it's an aggregation query without a `GROUP BY`.
2.  The static string column is `'Average Salary'`.
3.  The aggregation `COUNT(account_id)` returns `0`.
4.  Result: `| Average Salary | 0 |` (Perfect!).

#### 2. Inclusive vs Exclusive Ranges
Pay close attention to the problem statement:
* "Strictly less than" ($<$)
* "Inclusive range" ($\ge$ and $\le$)
* "Strictly greater than" ($>$)
Boundary errors (off-by-one errors) are the most common reason to fail this test.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of accounts.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. UNION ALL** | 3 x Filters | $O(N)$ (Three passes) | We iterate the table 3 times (once for each condition). |
| **2. LEFT JOIN** | 1 x Scan | $O(N)$ (One pass) | We iterate the table once, classifying each row into a bucket. |

**Space Complexity:** $O(1)$ (Result is always fixed at 3 rows).
