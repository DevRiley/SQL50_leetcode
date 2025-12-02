# 🏫 SQL Case Study: Students and Examinations
> **Category:** Advanced Joins / Aggregation  
> **Difficulty:** Easy-Medium  
> **Tags:** `SQL`, `Cross Join`, `Left Join`, `Group By`, `Handling NULLs`

## 1. Problem Description
**Goal:** Calculate the number of times each student attended each exam.

**Crucial Requirement:** The result must include **every student** and **every subject**, even if the student did not attend any exams for that subject (in which case, the count should be 0).

### Table `Students`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `student_id` | int | Primary Key |
| `student_name` | varchar | Name of the student |

### Table `Subjects`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `subject_name` | varchar | Primary Key |

### Table `Examinations`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `student_id` | int | Foreign Key to Students |
| `subject_name` | varchar | Foreign Key to Subjects |

*Note: This table contains no primary key and may have duplicates (representing multiple attendances).*

### Example Input
**Students:** Alice (1), Bob (2), Alex (6)
**Subjects:** Math, Physics, Programming
**Examinations:** Alice took all 3, Bob took Math & Programming, Alex took none.

### Expected Output
| student_id | student_name | subject_name | attended_exams |
| :--- | :--- | :--- | :--- |
| 1 | Alice | Math | 3 |
| 1 | Alice | Physics | 2 |
| ... | ... | ... | ... |
| 6 | Alex | Math | 0 |
| 6 | Alex | Physics | 0 |

---

## 💡 Thought Process
This problem tests your understanding of **Dataset Generation**.

**The Challenge:**
If we simply join `Students` with `Examinations`, students like "Alex" (who took no exams) or specific subjects (like Bob's Physics) will disappear from the result set because there is no matching record to count.

**The Strategy:**
1.  **Generate the Skeleton (The Matrix):** We need a list of *every possible combination* of Student and Subject.
    * Mathematical Operation: **Cartesian Product**.
    * SQL Operator: `CROSS JOIN`.
2.  **Map the Real Data:** Now that we have the skeleton (Rows for Alice-Math, Alice-Physics... Alex-Math, etc.), we attach the actual exam records.
    * SQL Operator: `LEFT JOIN` (to keep the skeleton rows even if no exam data exists).
3.  **Count:** Group by the student and subject, then count the matching records.

---

## 2. Solutions & Implementation

### ✅ Approach: Cross Join + Left Join
This is the standard and most robust solution.

```sql
SELECT 
    s.student_id, 
    s.student_name, 
    sub.subject_name, 
    COUNT(e.subject_name) AS attended_exams
FROM 
    Students s
CROSS JOIN 
    Subjects sub
LEFT JOIN 
    Examinations e 
    ON s.student_id = e.student_id 
    AND sub.subject_name = e.subject_name
GROUP BY 
    s.student_id, 
    s.student_name, 
    sub.subject_name
ORDER BY 
    s.student_id, 
    sub.subject_name;
```

---

## 3. 🔍 Deep Dive

#### Why `COUNT(e.subject_name)` instead of `COUNT(*)`?
This is a critical distinction in `LEFT JOIN` scenarios.

* **The Scenario:** Alex (student 6) has never taken Math.
* **The Row:** The Cross Join creates a row: `[6, Alex, Math]`. The Left Join finds no match in `Examinations`, so the joined columns from the `Examinations` table become `NULL`.
* **`COUNT(*)`:** Counts **rows**. It sees the row `[6, Alex, Math, NULL, NULL]` and counts **1**. **(WRONG - This implies Alex took the exam)**
* **`COUNT(e.subject_name)`:** Counts **non-NULL values** in that specific column. It sees `NULL` and counts **0**. **(CORRECT)**



#### Understanding the Cross Join
Think of `CROSS JOIN` as a multiplication of tables.
* If `Students` has $N$ rows.
* If `Subjects` has $M$ rows.
* The `CROSS JOIN` produces exactly $N \times M$ rows.

This ensures "Zero" values are reported, which is common in reporting requirements (e.g., "Show me sales for all months, even months with zero sales").

---

## 4. ⏱️ Time Complexity Analysis

Let:
* $N$ = Number of Students
* $M$ = Number of Subjects
* $E$ = Number of rows in Examinations table

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Cartesian Product** | `Students CROSS JOIN Subjects` | $O(N \times M)$ | Creates the base grid (Skeleton). |
| **2. Joining** | `LEFT JOIN Examinations` | $O(E)$ or $O(E \log E)$ | Depends on indexing. With Hash Join, it's roughly linear relative to the total data size. |
| **3. Aggregation** | `GROUP BY` | $O(N \times M)$ | We are grouping the result of the cross join. |
| **4. Sorting** | `ORDER BY` | $O(NM \log(NM))$ | Sorting the final result set. |

### Total Complexity
$$O(N \times M + E)$$
*(Assuming efficient Hash Joins and ignoring sorting overhead for small datasets)*

**Performance Implication:**
Since Cross Joins grow multiplicatively, this query can become very slow if $N$ and $M$ are both very large (e.g., 10,000 students and 1,000 subjects = 10 million intermediate rows). However, for dense reporting summaries ("Pivot Table" style reports), this strategy is standard.
