# 📰 SQL Case Study: Article Views I 
> **Category:** Filtering / Sorting / Deduplication  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `WHERE Clause`, `DISTINCT`, `ORDER BY`, `Renaming Columns`

## 1. Problem Description
**Goal:** Find the IDs of authors who have viewed at least one of their own articles.

The result must be:
1.  **Deduplicated:** Each author ID should appear only once.
2.  **Renamed:** The output column should be named `id`.
3.  **Sorted:** Ordered by `id` in ascending order.

### Table `Views`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `article_id` | int | ID of the article |
| `author_id` | int | ID of the author |
| `viewer_id` | int | ID of the viewer |
| `view_date` | date | Date of the view |

*(Note: There is no primary key. Duplicate rows may exist).*

### Example Input
| article_id | author_id | viewer_id | view_date | Check |
| :--- | :--- | :--- | :--- | :--- |
| 1 | 3 | 5 | 2019-08-01 | $3 \neq 5$ (Skip) |
| 2 | **7** | **7** | 2019-08-01 | $7 = 7$ (Match) |
| 2 | 7 | 6 | 2019-08-02 | $7 \neq 6$ (Skip) |
| 3 | **4** | **4** | 2019-07-21 | $4 = 4$ (Match) |
| 3 | **4** | **4** | 2019-07-21 | $4 = 4$ (Duplicate Match) |

### Expected Output
| id |
| :--- |
| 4 |
| 7 |

**Explanation:**
* Author 7 viewed their own article (2).
* Author 4 viewed their own article (3) multiple times.
* The output is unique IDs sorted ascending (4, then 7).

---

## 💡 Thought Process

### 1. The Logic: Self-View
We need to find rows where the person who wrote the article is the same person who viewed it.
* **Condition:** `author_id = viewer_id`

### 2. The Duplicate Trap
The problem statement explicitly warns: *"the table may have duplicate rows"*.
Also, an author might view their own article multiple times on different dates, or view multiple different articles they wrote.
* If we simply select `author_id`, Author 4 would appear twice in the result.
* **Action:** Use `DISTINCT`.

### 3. Formatting
* **Rename:** `SELECT author_id AS id`.
* **Sort:** `ORDER BY id ASC`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Filtering with DISTINCT (Standard)
This is the most direct way to solve the problem.

```sql
SELECT DISTINCT 
    author_id AS id
FROM 
    Views
WHERE 
    author_id = viewer_id
ORDER BY 
    id ASC;
```

### 🔹 Approach 2: GROUP BY (Alternative)
You can also use `GROUP BY` to remove duplicates. This is functionally equivalent to `DISTINCT` in this context.

```sql
SELECT 
    author_id AS id
FROM 
    Views
WHERE 
    author_id = viewer_id
GROUP BY 
    author_id
ORDER BY 
    id ASC;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. DISTINCT** | `SELECT DISTINCT` | ⭐⭐⭐ High | **Best Practice.** Intention is clear: "I want unique IDs". |
| **2. GROUP BY** | `GROUP BY` | ⭐⭐⭐ High | **Valid Alternative.** In modern databases, the execution plan for `DISTINCT` and `GROUP BY` (without aggregation functions) is often identical. |

---

## 4. 🔍 Deep Dive

#### 1. Why `AS id`?
The problem asks to return the column with the header `id`, but the source column is named `author_id`.
* `SELECT author_id AS id`: This creates an **Alias**.
* **Important:** In the `ORDER BY` clause, standard SQL allows you to refer to the alias `id` directly.

#### 2. Self-View Business Logic
This query is a common pattern in fraud detection or analytics:
* **"Creator viewing own content":** In platforms like YouTube or Medium, views from the author might be excluded from monetization stats (to prevent gaming the system). This query isolates exactly those "invalid" views.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the `Views` table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Filtering** | `WHERE` | $O(N)$ | Scans the table to check `author_id = viewer_id`. |
| **2. Deduplication** | `DISTINCT` | $O(M \log M)$ | Where $M$ is the number of matching rows. Requires sorting or hashing to remove duplicates. |
| **3. Sorting** | `ORDER BY` | $O(K \log K)$ | Where $K$ is the number of unique authors found. |

**Total Complexity:** $O(N)$ scanning + Sorting cost.
