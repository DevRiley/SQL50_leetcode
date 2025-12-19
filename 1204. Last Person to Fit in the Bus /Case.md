# 🚌 SQL Case Study: Last Person to Fit in the Bus
> **Category:** Window Functions / Cumulative Sum  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `Window Functions`, `SUM() OVER`, `Subquery`, `Running Total`

## 1. Problem Description
**Goal:** Find the name of the **last person** who can board the bus without the total weight exceeding **1000 kg**.

The boarding order is strictly determined by the `turn` column. We need to calculate the **cumulative weight** (Running Total) row by row and stop just before it crosses 1000.

### Table `Queue`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `person_id` | int | Unique ID |
| `person_name` | varchar | Name |
| `weight` | int | Weight in kg |
| `turn` | int | Boarding order (1 = first) |

### Example Input
| person_id | person_name | weight | turn |
| :--- | :--- | :--- | :--- |
| 5 | Alice | 250 | 1 |
| 4 | Bob | 175 | 5 |
| 3 | Alex | 350 | 2 |
| 6 | John Cena | 400 | 3 |
| 1 | Winston | 500 | 6 |
| 2 | Marie | 200 | 4 |

### Expected Output
| person_name |
| :--- |
| John Cena |

**Explanation:**
1.  **Turn 1 (Alice):** Total = 250. (Fits)
2.  **Turn 2 (Alex):** Total = 250 + 350 = 600. (Fits)
3.  **Turn 3 (John Cena):** Total = 600 + 400 = 1000. (Fits - Exact limit)
4.  **Turn 4 (Marie):** Total = 1000 + 200 = 1200. (Exceeds limit!)

The last person to successfully board is **John Cena**.

---

## 💡 Thought Process

### 1. The Core Logic: Running Total
To solve this, we cannot just look at individual rows. We need the sum of the current row **plus all previous rows** (based on `turn`).
* Mathematical term: **Cumulative Sum** or **Prefix Sum**.
* SQL Tool: **Window Functions**.

### 2. The Algorithm
1.  **Sort** the data by `turn`.
2.  **Calculate** `SUM(weight)` for each row, including all preceding rows.
3.  **Filter** rows where this running total is $\le 1000$.
4.  **Sort** the remaining valid rows by the total weight (Descending) to find the largest one.
5.  **Limit** to the top 1 result.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Window Function (Best Practice)
This is the modern, efficient, and readable way to calculate running totals.

```sql
SELECT 
    person_name
FROM (
    SELECT 
        person_name, 
        turn,
        SUM(weight) OVER (ORDER BY turn) AS running_total
    FROM 
        Queue
) AS q
WHERE 
    running_total <= 1000
ORDER BY 
    running_total DESC  -- Pick the largest total that fits
LIMIT 1;
```

### 🔹 Approach 2: Self-Join (Legacy / Conceptual)
If Window Functions are not supported (very old SQL versions), we join the table to itself to sum up "everything with a smaller or equal turn".

```sql
SELECT 
    q1.person_name
FROM 
    Queue q1
JOIN 
    Queue q2 ON q1.turn >= q2.turn
GROUP BY 
    q1.person_id
HAVING 
    SUM(q2.weight) <= 1000
ORDER BY 
    SUM(q2.weight) DESC
LIMIT 1;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. Window Function** | `SUM() OVER` | ⭐⭐⭐ High | **O(N) or O(N log N).** The database sorts once and iterates to calculate the sum. This is the industry standard. |
| **2. Self-Join** | `q1.turn >= q2.turn` | ⭐ Low | **O(N²).** For every person, the database has to re-scan all previous people to sum them up. Extremely slow on large datasets. |

---

## 4. 🔍 Deep Dive

#### 1. Understanding `SUM(...) OVER (ORDER BY ...)`
The syntax `ORDER BY turn` inside the `OVER()` clause changes the behavior of `SUM`.
* **Without ORDER BY:** It calculates the total sum of the *entire partition*.
* **With ORDER BY:** It defaults to `RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`. This effectively creates a running total.



#### 2. Why `ORDER BY running_total DESC`?
After filtering `WHERE running_total <= 1000`, we might have multiple people:
* Alice (250)
* Alex (600)
* John Cena (1000)

We want the **last** one. Since the running total is strictly increasing (weights are positive), the person with the highest valid running total is automatically the last person.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of people in the queue.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Windowing** | `ORDER BY turn` | $O(N \log N)$ | Sorting is required to determine the order. |
| **2. Summation** | `SUM() OVER` | $O(N)$ | Linear pass to add values. |
| **3. Filtering** | `WHERE` | $O(N)$ | Linear scan. |

**Total Complexity:** $O(N \log N)$.
