# 🗑️ SQL Case Study: Delete Duplicate Emails
> **Category:** Data Cleaning / Manipulation  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `DELETE`, `Self-Join`, `Data Cleaning`

## 1. Problem Description
**Goal:** Delete all duplicate emails from the `Person` table, keeping **only one unique email** with the **smallest `id`**.

**Important Constraints:**
1.  You must write a `DELETE` statement, not a `SELECT` statement.
2.  The operation must be performed on the table itself.

### Table `Person`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key |
| `email` | varchar | Email address |

### Example Input
| id | email |
| :--- | :--- |
| 1 | john@example.com |
| 2 | bob@example.com |
| 3 | john@example.com |

### Expected Result (After DELETE)
| id | email |
| :--- | :--- |
| 1 | john@example.com |
| 2 | bob@example.com |

**Explanation:**
* `john@example.com` appears twice (IDs 1 and 3).
* We want to keep ID 1 (smallest).
* We must delete ID 3.

---

## 💡 Thought Process

### 1. Identifying the Logic
We need to compare rows against other rows in the *same table*.
* **Condition for Duplication:** `p1.email = p2.email`
* **Condition for Deletion:** We want to remove the row with the **larger** ID. So, if `p1.id > p2.id`, then `p1` is the "duplicate" that came later, and `p2` is the "original" we want to keep.



### 2. The Solution Strategy: Self-Join DELETE
In standard SQL (specifically MySQL, which is the default context for this problem), we can delete from a table while joining it to itself.

* **Target (`p1`):** The alias for rows we want to *check for deletion*.
* **Reference (`p2`):** The alias for rows we want to *keep* (the anchors).

---

## 2. Solutions & Implementation

### ✅ Approach 1: DELETE with Self-Join (Best Practice)
This is the most efficient and standard way to handle this in MySQL.

```sql
DELETE p1
FROM 
    Person p1
JOIN 
    Person p2 ON p1.email = p2.email
WHERE 
    p1.id > p2.id;
```

### 🔹 Approach 2: DELETE with Subquery (Generic SQL)
If you find Self-Joins confusing, you might think: "Find the minimum IDs, then delete everything else."
*Note: In MySQL, you cannot delete from a table and select from the same table in a subquery directly without wrapping it in a temporary alias.*

```sql
DELETE FROM Person 
WHERE id NOT IN (
    SELECT * FROM (
        SELECT MIN(id) 
        FROM Person 
        GROUP BY email
    ) AS min_ids
);
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. Self-Join** | `DELETE p1 FROM ... JOIN ...` | ⭐⭐⭐ High | **Recommended.** The database engine optimizes joins very well. It directly identifies pairs `(id:3, id:1)` and deletes the one where $3 > 1$. |
| **2. NOT IN** | `DELETE ... NOT IN (...)` | ⭐⭐ Medium | **Verbose.** Requires creating a temporary table (the subquery) to bypass MySQL's restriction on modifying a table while selecting from it. |

---

## 4. 🔍 Deep Dive

#### 1. Understanding `DELETE p1`
In the syntax `DELETE p1 FROM Person p1 JOIN Person p2 ...`:
* The `p1` after `DELETE` specifies **which table alias to delete from**.
* Since we matched `p1` and `p2` based on the same email, and filtered for `p1.id > p2.id`, `p1` represents the "redundant" rows with higher IDs.
* If we wrote `DELETE p2`, we would delete the *original* (smallest ID) and keep the duplicates. (Don't do that!)

#### 2. Visualizing the Join
Imagine the join result before deletion:

| p1.id | p1.email | p2.id | p2.email | Condition `p1.id > p2.id`? | Action |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | john | 1 | john | False ($1 > 1$) | Keep |
| 1 | john | 3 | john | False ($1 > 3$) | Keep |
| 3 | john | 1 | john | **True ($3 > 1$)** | **DELETE p1 (ID 3)** |
| 3 | john | 3 | john | False ($3 > 3$) | Keep |

The only row that satisfies the WHERE clause is the pair (3, 1), targeting ID 3 for deletion.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `JOIN` | $O(N \log N)$ | The database joins the table to itself using `email`. If `email` is indexed, this is fast. |
| **2. Deleting** | `DELETE` | $O(D)$ | Where $D$ is the number of duplicates found. |

**Total Complexity:** $O(N \log N)$.
