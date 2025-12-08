# 📩 SQL Case Study: Confirmation Rate
> **Category:** Aggregation / Join Types / Ratio Math  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `LEFT JOIN`, `AVG`, `IFNULL`, `Boolean Averaging`

## 1. Problem Description
**Goal:** Calculate the **confirmation rate** for every user found in the `Signups` table.

**Definition:**
$$Confirmation Rate = \frac{\text{Count of 'confirmed' messages}}{\text{Total confirmation messages requested}}$$

**Special Rules:**
1.  If a user has **no** confirmation requests, their rate is **0**.
2.  The result must be rounded to **2 decimal places**.
3.  **All** users from the `Signups` table must be included in the output.

### Table `Signups`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `user_id` | int | Primary Key |
| `time_stamp` | datetime | Signup Time |

### Table `Confirmations`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `user_id` | int | Foreign Key to Signups |
| `time_stamp` | datetime | Action Time |
| `action` | enum | 'confirmed' or 'timeout' |

### Example Input
**Signups:** Users 3, 7, 2, 6.
**Confirmations:**
* User 7: 3 requests, 3 confirmed. (Rate: 1.00)
* User 2: 2 requests, 1 confirmed, 1 timeout. (Rate: 0.50)
* User 3: 2 requests, 2 timeouts. (Rate: 0.00)
* **User 6:** Not in Confirmations table. (Rate: 0.00)

### Expected Output
| user_id | confirmation_rate |
| :--- | :--- |
| 6 | 0.00 |
| 3 | 0.00 |
| 7 | 1.00 |
| 2 | 0.50 |

---

## 💡 Thought Process

### 1. Join Strategy: LEFT JOIN
We need to report on *every* user in `Signups`, even if they never requested a confirmation (like User 6).
* `INNER JOIN`: Would remove User 6. (❌ Wrong)
* `LEFT JOIN`: Keeps User 6, with `action` as `NULL`. (✅ Correct)

### 2. Calculating the Rate
We need the average of successful confirmations.
* **Math Logic:** Convert 'confirmed' to `1` and 'timeout' to `0`. Then take the average.
    * User 7: `AVG(1, 1, 1) = 1`
    * User 2: `AVG(1, 0) = 0.5`
    * User 3: `AVG(0, 0) = 0`

### 3. Handling NULLs (The Zero Case)
For User 6 (who has no rows in `Confirmations`):
* The `AVG(...)` function will run on a set of `NULL` values.
* In SQL, `AVG(NULL)` returns `NULL`.
* **Requirement:** Return `0`.
* **Fix:** Wrap the result in `IFNULL(..., 0)` or `COALESCE(..., 0)`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Boolean Averaging (MySQL Concise Way)
This leverages MySQL's ability to treat boolean expressions (`action='confirmed'`) as `1` or `0`.

```sql
SELECT 
    s.user_id,
    ROUND(
        IFNULL(AVG(c.action = 'confirmed'), 0)
    , 2) AS confirmation_rate
FROM 
    Signups s
LEFT JOIN 
    Confirmations c ON s.user_id = c.user_id
GROUP BY 
    s.user_id;
```

### 🔹 Approach 2: Standard SQL (CASE WHEN)
If you are using PostgreSQL, SQL Server, or Oracle, you should use `CASE WHEN` to be explicit.

```sql
SELECT 
    s.user_id,
    ROUND(
        COALESCE(
            AVG(CASE WHEN c.action = 'confirmed' THEN 1.0 ELSE 0.0 END), 
            0
        )
    , 2) AS confirmation_rate
FROM 
    Signups s
LEFT JOIN 
    Confirmations c ON s.user_id = c.user_id
GROUP BY 
    s.user_id;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic | Null Handling | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. Boolean AVG** | `AVG(action='confirmed')` | `IFNULL` | ⭐⭐⭐ **Fastest to write.** Works great in MySQL/MariaDB. Very readable logic: "Average of truth". |
| **2. Sum / Count** | `SUM(confirmed) / COUNT(*)` | `IFNULL` | ⭐⭐ **Traditional.** Prone to "Division by Zero" errors if not careful. `AVG` naturally avoids dividing by zero (it returns NULL instead). |

---

## 4. 🔍 Deep Dive

#### 1. Why `AVG` works better than `SUM / COUNT` here?
Mathematically, Rate = Sum / Count.
* If a user has 0 requests: `Count` is 0.
* **Sum / Count:** $0 / 0$ throws an error in some SQL dialects or returns NULL. You have to handle the denominator being 0 explicitly.
* **AVG:** Naturally returns `NULL` on empty sets. It simplifies the logic to just "Calculate Average, if result is NULL, make it 0".

#### 2. The Logic of `IFNULL(AVG(...), 0)`
Let's trace User 6:
1.  **LEFT JOIN:** Row is `[User 6, NULL action]`.
2.  **AVG:** `action = 'confirmed'` is Unknown (NULL). `AVG(NULL)` result is `NULL`.
3.  **IFNULL:** Converts `NULL` to `0`.
4.  **ROUND:** `ROUND(0, 2)` $\rightarrow$ `0.00`. Matches requirement.

---

## 5. ⏱️ Time Complexity Analysis

Let $S$ be rows in `Signups` and $C$ be rows in `Confirmations`.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `LEFT JOIN` | $O(S + C)$ | Standard join. Index on `user_id` makes this efficient. |
| **2. Grouping** | `GROUP BY` | $O(S)$ | We group by the unique users from the Signups table. |
| **3. Aggregation** | `AVG` | $O(C)$ | The calculation runs over the confirmation records. |

**Total Complexity:** $O(S + C)$.
