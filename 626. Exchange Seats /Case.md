# 🪑 SQL Case Study: Exchange Seats
> **Category:** Logic / Math / Conditionals  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `CASE WHEN`, `Modulus`, `Subquery`

## 1. Problem Description
**Goal:** Swap the `id` of every two consecutive students.
* Row 1 $\leftrightarrow$ Row 2
* Row 3 $\leftrightarrow$ Row 4
* If the total number of students is **odd**, the last student's `id` remains unchanged.

The result must be returned ordered by the new `id`.

### Table `Seat`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key (Sequential: 1, 2, 3...) |
| `student` | varchar | Student Name |

### Example Input
| id | student |
| :--- | :--- |
| 1 | Abbot |
| 2 | Doris |
| 3 | Emerson |
| 4 | Green |
| 5 | Jeames |

### Expected Output
| id | student |
| :--- | :--- |
| 1 | Doris |
| 2 | Abbot |
| 3 | Green |
| 4 | Emerson |
| 5 | Jeames |

**Explanation:**
* Abbot (1) moves to seat 2.
* Doris (2) moves to seat 1.
* Emerson (3) moves to seat 4.
* Green (4) moves to seat 3.
* Jeames (5) is the last one (odd total), so he stays at 5.

---

## 💡 Thought Process

### 1. The Mathematical Pattern
Instead of physically "swapping" rows (which is hard in `SELECT` statements), we can simply **calculate the new ID** for each student.



Let's look at the transformation rule:
* **Even IDs (2, 4, 6...):** They become `id - 1`. (2 $\rightarrow$ 1, 4 $\rightarrow$ 3).
* **Odd IDs (1, 3, 5...):** They become `id + 1`. (1 $\rightarrow$ 2, 3 $\rightarrow$ 4).
* **The Exception (Last Odd ID):** If the table has an odd number of rows (e.g., 5 rows), the student with `id = 5` is Odd, but should *not* become 6. They should stay 5.

### 2. The Logic Structure
We can use a `CASE WHEN` statement to handle these three states:
1.  Is it Even? $\rightarrow$ Subtract 1.
2.  Is it the Last One (and Odd)? $\rightarrow$ Keep same.
3.  Is it Odd (and not last)? $\rightarrow$ Add 1.

---

## 2. Solutions & Implementation

### ✅ Approach 1: CASE WHEN with Subquery (The Standard)
This is the most readable and direct way to implement the logic derived above.

```sql
SELECT
    CASE
        -- Case 1: Even ID -> Move back
        WHEN id % 2 = 0 THEN id - 1
        
        -- Case 2: Last ID (if it's Odd) -> Stay put
        WHEN id % 2 = 1 AND id = (SELECT COUNT(*) FROM Seat) THEN id
        
        -- Case 3: Odd ID (not last) -> Move forward
        ELSE id + 1
    END AS id,
    student
FROM 
    Seat
ORDER BY 
    id ASC;
```

### 🔹 Approach 2: Bit Manipulation (The Hacker Way)
(Optional Knowledge) In binary, swapping adjacent numbers (1 $\leftrightarrow$ 2, 3 $\leftrightarrow$ 4) involves flipping the last bit. The expression `(id - 1) ^ 1 + 1` is often used in programming, but in SQL, `CASE WHEN` is preferred for readability.

---

## 3. ⚖️ Comparative Analysis

| Feature | Note |
| :--- | :--- |
| **Logic** | The `CASE` order matters. We check `id % 2 = 0` first. Then we handle the Odd cases. We must verify if an Odd ID is the *last* one before simply adding 1. |
| **Performance** | The subquery `(SELECT COUNT(*) FROM Seat)` is executed. In modern databases, this is optimized (calculated once), making the query efficiently $O(N)$. |
| **Sorting** | The `ORDER BY id` at the end is crucial. Since we computed new IDs, the physical result might be jumbled if we don't explicitly sort by the *new* calculated column. |

---

## 4. 🔍 Deep Dive

#### 1. Why `(SELECT COUNT(*))` inside CASE?
We need to know the dynamic size of the table to handle the edge case.
* If we just wrote `WHEN id % 2 = 1 THEN id + 1`, then for a table of 5 people, user 5 would become user 6.
* Since ID 6 doesn't exist, we would have a gap or an incorrect ID.

#### 2. Can we use LEAD/LAG?
Yes! Another valid way to think about this is:
* For Odd rows: Grab the student name from the **Next** row (`LEAD`).
* For Even rows: Grab the student name from the **Previous** row (`LAG`).
* This approach "swaps names" instead of "calculating IDs".

```sql
SELECT 
    id,
    COALESCE(
        CASE 
            WHEN id % 2 = 1 THEN LEAD(student) OVER(ORDER BY id)
            ELSE LAG(student) OVER(ORDER BY id)
        END,
        student -- Fallback for the last odd person (LEAD is null)
    ) AS student
FROM Seat;
```
*This is often considered more "expensive" than simple math, but highly declarative.*

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of students.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Subquery** | `COUNT(*)` | $O(N)$ or $O(1)$ | Depends if the engine uses table metadata for count. |
| **2. Calculation** | `CASE WHEN` | $O(N)$ | Iterates through every row once. |
| **3. Sorting** | `ORDER BY` | $O(N \log N)$ | Re-orders the output based on the new IDs. |

**Total Complexity:** $O(N \log N)$ (Due to the final sort).
