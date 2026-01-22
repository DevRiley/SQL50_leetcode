# 📈 SQL Case Study: Restaurant Growth (Moving Average)
> **Category:** Window Functions / Time Series Analysis  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `Window Functions`, `ROWS BETWEEN`, `Grouping`, `Date Interval`

## 1. Problem Description
**Goal:** Calculate the **7-day moving average** of customer payments.
* **Window:** Current day + 6 previous days (Total 7 days).
* **Output:** Return the date, the sum of amounts in that 7-day window, and the average amount (rounded to 2 decimal places).
* **Constraint:** Only output rows where a full 7-day window exists (i.e., start outputting from the 7th available day).

### Table `Customer`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `customer_id` | int | Customer ID |
| `name` | varchar | Customer Name |
| `visited_on` | date | Transaction Date |
| `amount` | int | Payment Amount |

*(Note: There can be multiple customers/transactions on the same day).*

### Example Input
| customer_id | visited_on | amount |
| :--- | :--- | :--- |
| 1 | 2019-01-01 | 100 |
| 2 | 2019-01-02 | 110 |
| ... | ... | ... |
| 7 | 2019-01-07 | 150 |
| 1 | 2019-01-10 | 130 |
| 3 | 2019-01-10 | 150 |

### Expected Output
| visited_on | amount | average_amount |
| :--- | :--- | :--- |
| 2019-01-07 | 860 | 122.86 |
| 2019-01-08 | 840 | 120 |
| ... | ... | ... |

---

## 💡 Thought Process

### 1. Pre-processing: Daily Aggregation
The raw table contains individual transactions. A single day might have multiple rows (e.g., `2019-01-10` appears twice).
Before calculating a moving average, we must first condense the data into **one row per day**.
* **Action:** `GROUP BY visited_on` and `SUM(amount)`.

### 2. Defining the Window
We need a **Rolling Window** of size 7.
* SQL Syntax: `ROWS BETWEEN 6 PRECEDING AND CURRENT ROW`.
* This looks at the current row and the 6 rows above it (assuming the data is sorted by date).

### 3. The Filtering Challenge
The problem only wants results where a full 7-day window is possible.
* If the dataset starts on Jan 1st, the first valid 7-day window ends on Jan 7th.
* **Action:** We need to filter out the first 6 days.
* **Logic:** `WHERE visited_on >= (MIN(visited_on) + 6 days)`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: CTE + Window Functions (Best Practice)
This approach cleanly separates the daily aggregation from the moving average calculation.

```sql
WITH DailyStats AS (
    -- Step 1: Aggregate multiple transactions per day
    SELECT 
        visited_on, 
        SUM(amount) AS daily_total
    FROM 
        Customer
    GROUP BY 
        visited_on
)
SELECT 
    visited_on, 
    -- Step 2: Calculate Sum over 7-day window
    SUM(daily_total) OVER (
        ORDER BY visited_on 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS amount, 
    -- Step 3: Calculate Average over 7-day window
    ROUND(AVG(daily_total) OVER (
        ORDER BY visited_on 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ), 2) AS average_amount
FROM 
    DailyStats
-- Step 4: Filter to start only after the 7th day
WHERE 
    visited_on >= (
        SELECT DATE_ADD(MIN(visited_on), INTERVAL 6 DAY) 
        FROM Customer
    )
ORDER BY 
    visited_on;
```

### 🔹 Approach 2: Self-Join (Conceptual / Old SQL)
If Window Functions are unavailable, we join the table to itself matching dates within the range.

```sql
SELECT 
    a.visited_on, 
    SUM(b.amount) AS amount, 
    ROUND(AVG(b.amount), 2) AS average_amount
FROM 
    (SELECT visited_on, SUM(amount) as amount FROM Customer GROUP BY visited_on) a, 
    (SELECT visited_on, SUM(amount) as amount FROM Customer GROUP BY visited_on) b
WHERE 
    DATEDIFF(a.visited_on, b.visited_on) BETWEEN 0 AND 6
GROUP BY 
    a.visited_on
HAVING 
    COUNT(b.visited_on) = 7 -- Ensure full 7 days exist
ORDER BY 
    a.visited_on;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Readability | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. Window Function** | ⭐⭐⭐ High | ⭐⭐⭐ High | **O(N).** The database sorts the daily stats once and iterates through with a sliding pointer. This is the industry standard. |
| **2. Self-Join** | ⭐ Low | ⭐ Low | **O(N²).** For every single day, it re-scans the previous 6 days. It scales poorly with large datasets. |

---

## 4. 🔍 Deep Dive

#### 1. Why `ROWS BETWEEN` and not `RANGE BETWEEN`?
* **`ROWS`**: Counts physical rows. Since we aggregated data to exactly one row per day, `6 PRECEDING` guarantees exactly 7 data points (assuming no missing dates in the sequence).
* **`RANGE`**: Looks at the value of the date. If there were missing days (gaps) in the business operation, `RANGE BETWEEN INTERVAL 6 DAY PRECEDING` would be safer, but the problem implies contiguous operations ("at least one customer every day").



#### 2. The Date Filter Logic
To dynamically find the starting point:
`SELECT DATE_ADD(MIN(visited_on), INTERVAL 6 DAY) FROM Customer`
* If Min Date = Jan 1st.
* Min + 6 Days = Jan 7th.
* The `WHERE` clause ensures we only output rows from Jan 7th onwards.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the `Customer` table, and $D$ be the number of unique days.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Aggregation** | `GROUP BY` | $O(N)$ | Condensing raw transactions into Daily Stats. |
| **2. Windowing** | `OVER(ORDER BY)` | $O(D \log D)$ | Sorting the unique days. |
| **3. Sliding** | `AVG/SUM` | $O(D)$ | Linear pass over the sorted days. |

**Total Complexity:** $O(N + D \log D)$.
