# 🏥 SQL Case Study: Patients With a Condition
> **Category:** String Pattern Matching / Filtering  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `LIKE`, `Wildcards`, `REGEXP`

## 1. Problem Description
**Goal:** Find all patients who have **Type I Diabetes**.
* The condition code for Type I Diabetes always **starts with** the prefix `DIAB1`.
* The `conditions` column contains a list of codes separated by **spaces**.

### Table `Patients`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `patient_id` | int | Primary Key |
| `patient_name` | varchar | Name of the patient |
| `conditions` | varchar | Space-separated list of condition codes |

### Example Input
| patient_id | patient_name | conditions |
| :--- | :--- | :--- |
| 1 | Daniel | YFEV COUGH |
| 2 | Alice | (Empty) |
| 3 | Bob | **DIAB1**00 MYOP |
| 4 | George | ACNE **DIAB1**00 |
| 5 | Alain | DIAB201 |
| 6 | Trap | SADIAB100 |

### Expected Output
| patient_id | patient_name | conditions |
| :--- | :--- | :--- |
| 3 | Bob | DIAB100 MYOP |
| 4 | George | ACNE DIAB100 |

**Explanation:**
* **Bob:** `DIAB100` is at the very beginning. (Match)
* **George:** `DIAB100` is the second code. (Match)
* **Alain:** `DIAB201` starts with `DIAB2`, not `DIAB1`. (Fail)
* **Trap (Hypothetical):** `SADIAB100` contains `DIAB1`, but it is not a prefix of the specific code. It's part of another word. (Fail)

---

## 💡 Thought Process

### 1. The Trap: Simple Wildcards
If we simply use `conditions LIKE '%DIAB1%'`, we might match incorrect strings like `SADIAB100` or `MEDIAB1`. The problem specifically says the code *starts with* `DIAB1`.

### 2. The Two Scenarios
Since the codes are space-separated, the target code `DIAB1...` can appear in two positions:
1.  **At the very start of the string:** e.g., `"DIAB100 MYOP"`
    * Pattern: `'DIAB1%'`
2.  **Inside the string (preceded by a space):** e.g., `"ACNE DIAB100"`
    * Pattern: `'% DIAB1%'` (Notice the space after the first `%`)

We need to combine these with an `OR` logic.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Standard LIKE (Universal & Best Practice)
This solution works on almost all SQL databases (MySQL, PostgreSQL, SQL Server).

```sql
SELECT 
    patient_id, 
    patient_name, 
    conditions
FROM 
    Patients
WHERE 
    conditions LIKE 'DIAB1%'      -- Case 1: Starts with DIAB1
    OR 
    conditions LIKE '% DIAB1%';   -- Case 2: Contains space + DIAB1
```

### 🔹 Approach 2: Regular Expressions (MySQL Specific)
If your database supports Regex (like MySQL 8.0+ or PostgreSQL), you can use a word boundary `\b` to make the query much shorter.

```sql
SELECT 
    patient_id, 
    patient_name, 
    conditions
FROM 
    Patients
WHERE 
    conditions REGEXP '\\bDIAB1';
```
*Note: `\b` matches the position between a word character and a non-word character (like a space or start of string).*

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Compatibility | Note |
| :--- | :--- | :--- | :--- |
| **1. LIKE** | `LIKE '...' OR LIKE '...'` | ⭐⭐⭐ High | **Standard Solution.** It explicitly handles the two edge cases defined by the "space separator" rule. It is safe and readable. |
| **2. REGEXP** | `REGEXP '\\b...'` | ⭐ Low | **Engine Dependent.** While cleaner to write, `REGEXP` syntax varies wildly between databases (MySQL uses `REGEXP`, Postgres uses `~`, SQL Server needs CLR integration). |

---

## 4. 🔍 Deep Dive

#### 1. Why `'% DIAB1%'` needs the space?
If we use `'%DIAB1%'` (without space):
* It matches: `MYDIAB100` (Wrong! This is a different disease code).
* By adding the space `'% DIAB1%'`, we ensure that `DIAB1` is the **start** of a new code token within the string.



#### 2. Indexing Performance
Scanning text with leading wildcards (`%...`) generally prevents the database from using standard B-Tree indexes. This query usually results in a **Full Table Scan**.
* For large medical databases, full-text search engines (like Elasticsearch) or specific Full-Text Indexes in SQL are usually preferred over `LIKE`.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of patients and $L$ be the average length of the conditions string.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Scanning** | `WHERE` | $O(N \times L)$ | The database must check the string pattern against every row. |

**Total Complexity:** $O(N \times L)$.
