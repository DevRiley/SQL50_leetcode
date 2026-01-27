# 🍢 SQL Case Study: Group Sold Products By The Date
> **Category:** String Aggregation / Grouping  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `GROUP BY`, `GROUP_CONCAT`, `COUNT DISTINCT`

## 1. Problem Description
**Goal:** For each date, find:
1.  The number of **different** (unique) products sold.
2.  A list of their names, joined by a comma, and sorted **lexicographically** (A-Z).

The final result must be sorted by `sell_date`.

### Table `Activities`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `sell_date` | date | Date of sale |
| `product` | varchar | Product Name |

*(No Primary Key, duplicates allowed).*

### Example Input
| sell_date | product |
| :--- | :--- |
| 2020-05-30 | Headphone |
| 2020-05-30 | Basketball |
| 2020-05-30 | T-Shirt |
| 2020-06-02 | Mask |
| 2020-06-02 | **Mask** (Duplicate) |

### Expected Output
| sell_date | num_sold | products |
| :--- | :--- | :--- |
| 2020-05-30 | 3 | Basketball,Headphone,T-Shirt |
| 2020-06-02 | 1 | Mask |

**Explanation:**
* **2020-05-30:** 3 items. Sorted alphabetically: B -> H -> T. Joined by comma.
* **2020-06-02:** Mask appears twice, but we only count unique items. Result count is 1, string is just "Mask".

---

## 💡 Thought Process

### 1. The Grouping
We need one row per date.
* **Action:** `GROUP BY sell_date`.



### 2. Metric 1: Count of Unique Items
We cannot use `COUNT(product)` because of duplicates (like 'Mask').
* **Action:** `COUNT(DISTINCT product)`.

### 3. Metric 2: String Aggregation (The Core Challenge)
We need to squash multiple rows of text into a single cell.
* **Standard SQL:** There is no single universal function, but in MySQL (LeetCode standard), we use `GROUP_CONCAT`.
* **Requirements inside the function:**
    1.  **No Duplicates:** Need `DISTINCT`.
    2.  **Sorted:** Need `ORDER BY product`.
    3.  **Separator:** Need `SEPARATOR ','` (Note: comma is the default, but being explicit is good).

---

## 2. Solutions & Implementation

### ✅ Approach 1: MySQL GROUP_CONCAT (Standard Solution)
This function is specifically designed for this task. It allows filtering, sorting, and separating within the aggregation itself.

```sql
SELECT 
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    GROUP_CONCAT(
        DISTINCT product 
        ORDER BY product ASC 
        SEPARATOR ','
    ) AS products
FROM 
    Activities
GROUP BY 
    sell_date
ORDER BY 
    sell_date;
```

### 🔹 Approach 2: PostgreSQL (Alternative Syntax)
Just for reference, if you are using PostgreSQL, `GROUP_CONCAT` does not exist. You would use `STRING_AGG`.

```sql
-- PostgreSQL Syntax (For reference only)
SELECT 
    sell_date,
    COUNT(DISTINCT product) AS num_sold,
    STRING_AGG(DISTINCT product, ',' ORDER BY product) AS products
FROM 
    Activities
GROUP BY 
    sell_date
ORDER BY 
    sell_date;
```

---

## 3. 🔍 Deep Dive

#### 1. Anatomy of `GROUP_CONCAT`
The syntax is powerful but specific:
```sql
GROUP_CONCAT(
    [DISTINCT] col_name
    [ORDER BY sorting_col ASC/DESC]
    [SEPARATOR 'string_val']
)
```
* **Order Matters:** You must write `DISTINCT` first, then `ORDER BY`, then `SEPARATOR`. Mixing them up causes syntax errors.

#### 2. Default Separator
If you omit `SEPARATOR ','`, MySQL defaults to a comma. So `GROUP_CONCAT(DISTINCT product ORDER BY product)` is valid and produces the same result. However, adding `SEPARATOR` makes the code readable if requirements change (e.g., separating by spaces).

#### 3. Length Limit
In real-world MySQL production, `GROUP_CONCAT` has a length limit (default 1024 characters). If the list of products is massive, the string will be truncated. This can be increased by setting the system variable `group_concat_max_len`.

---

## 4. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Grouping** | `GROUP BY` | $O(N)$ | Scans the table to bucket rows by date. |
| **2. Deduplication** | `DISTINCT` | $O(N)$ | Uses a hash set or sorting to remove duplicates within groups. |
| **3. Sorting (Internal)** | `ORDER BY` | $O(N \log N)$ | Sorting the product names *within* each group to form the string. |

**Total Complexity:** $O(N \log N)$ (Dominated by the sorting required for the string construction).
