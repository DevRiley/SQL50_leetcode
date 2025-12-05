# 🎮 SQL Case Study: Game Play Analysis (Day 1 Retention)
> **Category:** Date Logic / Subqueries / Ratio Calculation  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `Self-Join`, `DATE_ADD`, `MIN()`, `Retention Rate`

## 1. Problem Description
**Goal:** Calculate the **Day 1 Retention Rate**.
This is defined as the fraction of players who logged in on the very next day after their **first** login.

**Formula:**
$$Retention = \frac{\text{Players who logged in on (First Date + 1)}}{\text{Total count of distinct players}}$$

### Table `Activity`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `player_id` | int | Player ID |
| `device_id` | int | Device ID |
| `event_date` | date | Login Date |
| `games_played` | int | Number of games |

*(player_id, event_date) is the Primary Key.*

### Example Input
| player_id | event_date | Note |
| :--- | :--- | :--- |
| 1 | **2016-03-01** | **First Login** |
| 1 | **2016-03-02** | **Next Day Login (Success)** |
| 2 | 2017-06-25 | First Login |
| 3 | 2016-03-02 | First Login |
| 3 | 2018-07-03 | Future Login (Not Next Day) |

### Expected Output
| fraction |
| :--- |
| 0.33 |

**Explanation:**
* **Total Players:** 3 (IDs: 1, 2, 3).
* **Player 1:** First login 03-01. Logged in 03-02. $\rightarrow$ **Counted**.
* **Player 2:** First login 06-25. No login on 06-26. $\rightarrow$ Not Counted.
* **Player 3:** First login 03-02. No login on 03-03. $\rightarrow$ Not Counted.
* **Result:** $1 / 3 = 0.33$.

---

## 💡 Thought Process

### 1. Identify the "Anchor" (First Login)
First, we must know *when* each player started.
* Logic: Group by `player_id` and find `MIN(event_date)`.

### 2. Identify the "Target" (Next Day Login)
We need to check if a record exists where:
* `player_id` matches.
* `event_date` is exactly `First_Login_Date + 1 Day`.

### 3. The Math (Fraction)
* **Numerator:** Count of unique players who met the target condition.
* **Denominator:** Count of total unique players in the table.
* **Rounding:** `ROUND(..., 2)`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Tuple Filtering (Concise & Efficient)
This approach finds the first login, calculates what the "next day" *should* be, and checks if that specific `(id, date)` exists in the main table.

```sql
SELECT 
    ROUND(
        COUNT(player_id) / (SELECT COUNT(DISTINCT player_id) FROM Activity), 
        2
    ) AS fraction
FROM 
    Activity
WHERE 
    (player_id, DATE_SUB(event_date, INTERVAL 1 DAY)) IN (
        -- Subquery: Find the First Login Date for every player
        SELECT 
            player_id, 
            MIN(event_date) 
        FROM 
            Activity
        GROUP BY 
            player_id
    );
```

### 🔹 Approach 2: Left Join (Structural Logic)
We create a list of "First Logins" and try to `LEFT JOIN` the original table on the next day. This is often easier to debug visually.

```sql
SELECT 
    ROUND(
        COUNT(t2.player_id) / COUNT(t1.player_id), 
        2
    ) AS fraction
FROM 
    (
        -- Table 1: Every player and their first date
        SELECT player_id, MIN(event_date) AS first_date
        FROM Activity
        GROUP BY player_id
    ) t1
LEFT JOIN 
    Activity t2 
    ON t1.player_id = t2.player_id 
    AND t2.event_date = DATE_ADD(t1.first_date, INTERVAL 1 DAY);
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic Style | Pros & Cons |
| :--- | :--- | :--- |
| **1. Tuple IN** | Filter-based | ⭐⭐⭐ **Slightly Faster.** Often faster because it filters the main table directly. Requires the database to support tuple syntax `(a,b) IN ...` (MySQL/Postgres do). |
| **2. LEFT JOIN** | Set-based | ⭐⭐ **More Visual.** Easier to understand step-by-step logic (Table A joined to Table B). Good for standard SQL compatibility. |

---

## 4. 🔍 Deep Dive

#### 1. Date Arithmetic Variations
Different SQL dialects handle "Adding 1 Day" differently:
* **MySQL:** `DATE_ADD(date, INTERVAL 1 DAY)` or `date + INTERVAL 1 DAY`.
* **SQL Server:** `DATEADD(day, 1, date)`.
* **PostgreSQL:** `date + 1`.
* **Oracle:** `date + 1`.

#### 2. Why `DATE_SUB` in Approach 1?
In Approach 1, we are looking at the *current* row in the `Activity` table (which represents the "Next Day" login) and asking: *"Was yesterday my first login?"*
* Formula: `Yesterday = Current_Date - 1 Day`
* Check: Is `(My_ID, Yesterday)` in the list of `(ID, First_Login_Date)`?

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows (logins) and $P$ be the number of players.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Find Min Date** | `GROUP BY` | $O(N)$ | Must scan table to find min date per player. |
| **2. Matching** | `JOIN` or `IN` | $O(N)$ | Hash Match or Index Lookup. |
| **3. Count** | `COUNT(DISTINCT)` | $O(N)$ | In the denominator subquery. |

**Total Complexity:** $O(N)$.
