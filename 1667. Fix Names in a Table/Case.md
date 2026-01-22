# 🔠 SQL Case Study: Fix Names in a Table
> **Category:** String Manipulation  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `String Functions`, `CONCAT`, `UPPER`, `LOWER`, `SUBSTRING`

## 1. Problem Description
**Goal:** Fix the formatting of user names so that:
1.  The **first character** is uppercase.
2.  The **rest of the characters** are lowercase.

Finally, sort the result by `user_id`.

### Table `Users`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `user_id` | int | Primary Key |
| `name` | varchar | User Name (mixed case) |

### Example Input
| user_id | name |
| :--- | :--- |
| 1 | aLice |
| 2 | bOB |

### Expected Output
| user_id | name |
| :--- | :--- |
| 1 | Alice |
| 2 | Bob |

**Explanation:**
* **aLice:** 'a' $\rightarrow$ 'A', 'Lice' $\rightarrow$ 'lice'. Result: "Alice".
* **bOB:** 'b' $\rightarrow$ 'B', 'OB' $\rightarrow$ 'ob'. Result: "Bob".

---

## 💡 Thought Process

### 1. String Anatomy
We need to dissect the string into two parts and treat them differently.



* **Part A (Head):** The first character.
    * Function: Extract it, then force it to **UPPERCASE**.
* **Part B (Tail):** The second character until the end.
    * Function: Extract it, then force it to **lowercase**.
* **Merge:** Glue Part A and Part B back together.

### 2. The Functions
* **To Extract Head:** `LEFT(name, 1)` or `SUBSTRING(name, 1, 1)`.
* **To Extract Tail:** `SUBSTRING(name, 2)` (Starts from index 2 to the end).
* **To Capitalize:** `UPPER()`.
* **To Lowercase:** `LOWER()`.
* **To Glue:** `CONCAT()`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Standard String Functions (MySQL / SQL Server)
This is the most universal logic that works across most databases.

```sql
SELECT 
    user_id, 
    CONCAT(
        UPPER(LEFT(name, 1)),       -- 1. Grab first char & Uppercase it
        LOWER(SUBSTRING(name, 2))   -- 2. Grab the rest & Lowercase it
    ) AS name
FROM 
    Users
ORDER BY 
    user_id;
```

### 🔹 Approach 2: Using INITCAP (PostgreSQL / Oracle)
Some databases have a built-in function specifically for "Title Case".
*Note: MySQL does NOT support `INITCAP` natively.*

```sql
SELECT 
    user_id, 
    INITCAP(name) AS name
FROM 
    Users
ORDER BY 
    user_id;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Compatibility | Syntax | Note |
| :--- | :--- | :--- | :--- |
| **1. CONCAT + SUBSTRING** | ⭐⭐⭐ High | Verbose | Works in MySQL, SQL Server (use `+` or `CONCAT`), PostgreSQL. The logic is explicit. |
| **2. INITCAP** | ⭐ Low | Concise | Only works in Oracle and PostgreSQL. Very convenient if available, but not portable to MySQL. |

---

## 4. 🔍 Deep Dive

#### 1. 1-Based Indexing
Unlike many programming languages (C, Python, Java) where strings start at Index 0, **SQL strings start at Index 1**.
* `SUBSTRING(name, 1, 1)` gets the first letter.
* `SUBSTRING(name, 2)` gets everything from the second letter onwards.

#### 2. `SUBSTRING` vs `SUBSTR`
* In MySQL and PostgreSQL, `SUBSTRING` and `SUBSTR` are synonyms.
* In SQL Server, you must use `SUBSTRING`.
* To be safe, `SUBSTRING` is usually the standard choice.

#### 3. Handling Length
We don't need to specify the length for the "Tail" part. `SUBSTRING(name, 2)` automatically implies "from position 2 until the end of the string". If the name is a single letter (e.g., "a"), `SUBSTRING("a", 2)` simply returns an empty string, and `LOWER("")` is `""`. The logic still holds ("A" + "" = "A").

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of users and $L$ be the average length of a name.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. String Ops** | `UPPER`, `LOWER`, `CONCAT` | $O(N \times L)$ | The database must process every character in every name. |
| **2. Sorting** | `ORDER BY` | $O(N \log N)$ | Sorting by ID. |

**Total Complexity:** $O(N \times L)$.
