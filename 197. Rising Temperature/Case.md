# 🌤️ SQL Case Study: Rising Temperature
> **Category:** Data Analysis / Time Series Analysis  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `MySQL`, `Date Manipulation`, `Self-Join` ,` Window Functions`

## 1. Problem Description 
**Goal:** Write a solution to find all dates' `id` with higher temperatures compared to its previous dates (yesterday).

### Table `Weather` 
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key (Unique value) |
| `recordDate` | date | The date of the weather record |
| `temperature` | int | The temperature on that day |

*Note: There are no different rows with the same recordDate.*

### Example Input
| id | recordDate | temperature |
| :--- | :--- | :--- |
| 1 | 2015-01-01 | 10 |
| 2 | 2015-01-02 | 25 |
| 3 | 2015-01-03 | 20 |
| 4 | 2015-01-04 | 30 |

### Expected Output
| id |
| :--- |
| 2 |
| 4 |

---
## 2. Solutions & Implementation

### ✅ Approach 1: Self-Join
This is the most common and efficient way to solve row-comparison problems in relational databases.   
We join the table to itself: one instance representing "Today" (`w1`) and the other "Yesterday" (`w2`).

```sql
SELECT 
    w1.id
FROM 
    Weather w1
JOIN 
    Weather w2 
    -- MySQL Syntax: DATEDIFF(Today, Yesterday) = 1
    ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE 
    w1.temperature > w2.temperature;
```


### 🔹 Approach 2: Window Functions  
Using LAG() allows us to access data from the previous row without a self-join.

Critical Note: Since LAG() looks at the physical previous row, we must add a check (DATE_ADD) to ensure the previous row is actually yesterday (handling cases where dates are missing).
~~~sql
WITH PreviousWeatherData AS (
    SELECT 
        id,
        recordDate,
        temperature, 
        LAG(temperature, 1) OVER (ORDER BY recordDate) AS PreviousTemperature,
        LAG(recordDate, 1) OVER (ORDER BY recordDate) AS PreviousRecordDate
    FROM 
        Weather
)
SELECT 
    id 
FROM 
    PreviousWeatherData
WHERE 
    temperature > PreviousTemperature
    -- Ensure the gap is exactly 1 day (Handle missing dates)
    AND recordDate = DATE_ADD(PreviousRecordDate, INTERVAL 1 DAY);
~~~



### ⚠️ Approach 3: Subquery in WHERE Clause
This approach fetches the previous day's temperature for every single row.   
While logically correct, it is often less performant on large datasets.
```sql
SELECT 
    w1.id
FROM 
    Weather w1
WHERE 
    w1.temperature > (
        SELECT w2.temperature
        FROM Weather w2
        WHERE w2.recordDate = DATE_SUB(w1.recordDate, INTERVAL 1 DAY)
    ); 
```

<br>

## 3.  ⚖️ Comparative Analysis of Solutions

While the **Self-Join** (Approach 1) is the standard solution, there are other ways to solve this problem. Here is a comparison of their performance and suitability.

| Approach | Technique | Time Complexity | Modern Standard? | Pros & Cons |
| :--- | :--- | :--- | :--- | :--- |
| **1** | **Self-Join (Explicit)** | $O(N \log N)$ or $O(N)$ | ✅ Yes | **Best Choice.** Clear intent, optimized execution, and handles missing dates correctly. |
| **2** | **Window Function (LAG)** | $O(N \log N)$ | ✅ Yes |  Shows advanced SQL skills. Requires careful handling of non-consecutive dates. |
| **3** | **Correlated Subquery** | $O(N^2)$ (Worst Case) | ⚠️ No | **Performance Risk.** Executes a query for *every row*. Good for logic prototyping but bad for Big Data. |

---

## 🔍 Deep Dive

#### Approach 2: Window Functions (`LAG`)
Using `LAG()` is very powerful for time-series analysis.
* **The Trap:** `LAG(temperature)` simply gets the *previous row's* value. If data is missing (e.g., Jan 1st, then Jan 3rd), `LAG` will compare Jan 3rd to Jan 1st.
* **The Fix:** You **must** include the condition `recordDate = DATE_ADD(PreviousRecordDate, INTERVAL 1 DAY)` to ensure the gap is exactly one day.
* **Verdict:** Solution if the dataset is guaranteed to be continuous (no missing dates), otherwise requires extra filtering overhead.

#### Approach 3: Subquery in WHERE
* **Logic:** "For this row, go find me the temp from yesterday."
* **Drawback:** This forces the database to execute the inner query repeatedly (Row-by-Row processing), rather than processing the data as a whole set.
* **Verdict:** **Row-by-Row Processing (RBAR).** Treats SQL procedurally rather than declaratively. Good for logic prototyping, but poor for scalability on large datasets.Acceptable for small datasets, but generally discouraged in production environments due to performance costs.


