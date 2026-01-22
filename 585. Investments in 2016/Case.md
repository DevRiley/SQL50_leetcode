# 🏦 SQL Case Study: Investments in 2016
> **Category:** Aggregation / Subqueries / Window Functions
> **Difficulty:** Medium
> **Tags:** `SQL`, `GROUP BY`, `HAVING`, `IN Clause`, `Window Functions`

## 1. Problem Description
**Goal:** Calculate the sum of `tiv_2016` for all policyholders who meet two specific criteria:
1.  **Shared Investment Value:** Their `tiv_2015` value must be the same as at least one other policyholder.
2.  **Unique Location:** Their location `(lat, lon)` must be unique (i.e., no one else lives at the exact same coordinates).

The final result must be rounded to **two decimal places**.

### Table `Insurance`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `pid` | int | Primary Key |
| `tiv_2015` | float | Total Investment Value in 2015 |
| `tiv_2016` | float | Total Investment Value in 2016 |
| `lat` | float | Latitude |
| `lon` | float | Longitude |

### Example Input
| pid | tiv_2015 | tiv_2016 | lat | lon |
| :--- | :--- | :--- | :--- | :--- |
| 1 | **10** | 5 | **10** | **10** |
| 2 | 20 | 20 | 20 | 20 |
| 3 | **10** | 30 | 20 | 20 |
| 4 | **10** | 40 | **40** | **40** |

### Expected Output
| tiv_2016 |
| :--- |
| 45.00 |

**Explanation:**
1.  **Check `tiv_2015`:** The value `10` appears 3 times (PID 1, 3, 4). These are candidates. Value `20` appears once (PID 2) $\rightarrow$ PID 2 is rejected.
2.  **Check Location:**
    * PID 1 (10, 10): Unique. **(Keep)**
    * PID 3 (20, 20): Same as PID 2. **(Reject)**
    * PID 4 (40, 40): Unique. **(Keep)**
3.  **Sum:** PID 1 (`5`) + PID 4 (`40`) = `45.00`.

---

## 💡 Thought Process

### 1. Breaking Down the Conditions
We need to filter the main table based on aggregate properties of the whole dataset.
* **Condition A:** `COUNT(tiv_2015) > 1`
* **Condition B:** `COUNT(lat, lon) = 1`

### 2. Strategy Selection
* **Set-Based Approach (Subqueries):** We can create a list of "Valid TIVs" and a list of "Valid Locations" using `GROUP BY` and `HAVING`, then filter the main table against these lists using `IN`.
* **Window Function Approach:** We can attach the count of TIVs and Locations to every row using `COUNT(*) OVER(...)`, then filter based on these calculated columns.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Subqueries with GROUP BY (The Standard Way)
This approach is very intuitive: "Find me the list of duplicated investments, and the list of unique locations, then give me the people who match both lists."

```sql
SELECT 
    ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM 
    Insurance
WHERE 
    -- Condition 1: tiv_2015 appears more than once
    tiv_2015 IN (
        SELECT tiv_2015 
        FROM Insurance 
        GROUP BY tiv_2015 
        HAVING COUNT(*) > 1
    )
    AND 
    -- Condition 2: Location (lat, lon) appears exactly once
    (lat, lon) IN (
        SELECT lat, lon 
        FROM Insurance 
        GROUP BY lat, lon 
        HAVING COUNT(*) = 1
    );
```

### 🔹 Approach 2: Window Functions (The Modern Way)
This approach avoids scanning the table multiple times in subqueries. It computes the counts "on the fly" in a single pass (depending on the optimizer).

```sql
SELECT 
    ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM (
    SELECT 
        tiv_2016,
        COUNT(*) OVER(PARTITION BY tiv_2015) AS cnt_tiv,
        COUNT(*) OVER(PARTITION BY lat, lon) AS cnt_loc
    FROM 
        Insurance
) AS stats
WHERE 
    cnt_tiv > 1 
    AND 
    cnt_loc = 1;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Readability | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. IN (Subqueries)** | ⭐⭐⭐ High | ⭐⭐ Medium | **Conceptually Clear.** Easy to explain. However, MySQL might execute the subqueries first. Using tuple comparison `(lat, lon) IN` is standard in MySQL/Postgres but might need concatenation in older SQL dialects. |
| **2. Window Functions** | ⭐⭐ Medium | ⭐⭐⭐ High | **Efficient.** Often faster on large datasets because it avoids multiple grouping passes. Requires a subquery (or CTE) because you cannot use Window Functions in a `WHERE` clause directly. |

---

## 4. 🔍 Deep Dive

#### 1. Tuple Comparison `(lat, lon) IN (...)`
Notice the syntax:
```sql
WHERE (lat, lon) IN (SELECT lat, lon ...)
```
This is a powerful SQL feature called **Row Constructor Comparison**. It checks if the *pair* exists in the result set.
* If your database doesn't support this (e.g., SQL Server older versions), you would have to write:
`WHERE CONCAT(lat, lon) IN (SELECT CONCAT(lat, lon)...)` (which is risky due to formatting) or use `EXISTS`.

#### 2. Why not just `GROUP BY` directly?
We cannot simply write `SELECT SUM(tiv_2016) ... GROUP BY tiv_2015 HAVING ...`.
Why? Because the grouping criteria for Condition 1 (Investment) and Condition 2 (Location) are **conflicting**.
* You can't group by `tiv_2015` AND `lat, lon` simultaneously to satisfy both distinct count logic requirements in a single layer. We must separate the logic either via Subqueries or Window Functions.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Grouping/Windowing** | Sort/Hash | $O(N \log N)$ | To find duplicates (`tiv_2015`) and uniques (`lat, lon`), the DB must sort or hash the data. |
| **2. Filtering** | Filter | $O(N)$ | Scanning the results to apply the conditions. |

**Total Complexity:** $O(N \log N)$ (Dominated by the counting mechanism).
