# 🏷️ SQL Case Study: Product Sales Analysis III (First Year Sales)
> **Category:** Aggregation / Subqueries / Window Functions  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `Tuple Filtering`, `MIN()`, `RANK()`, `Subquery`

## 1. Problem Description
**Goal:** Select all sales records that belong to the **first year** a product was sold.

We need to:
1.  Find the earliest year (`MIN(year)`) for each product.
2.  Return the detailed columns (`quantity`, `price`) for the rows that match that specific product and year.
3.  Rename the `year` column to `first_year`.

### Table `Sales`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `sale_id` | int | Sale ID |
| `product_id` | int | Product ID |
| `year` | int | Year of sale |
| `quantity` | int | Quantity sold |
| `price` | int | Price per unit |

*(sale_id, year) is the Primary Key. A product can have multiple sales in the same year.*

### Example Input
| sale_id | product_id | year | quantity | price | Note |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 100 | **2008** | 10 | 5000 | **First Year for 100** |
| 2 | 100 | 2009 | 12 | 5000 | Later Year |
| 7 | 200 | **2011** | 15 | 9000 | **First Year for 200** |

### Expected Output
| product_id | first_year | quantity | price |
| :--- | :--- | :--- | :--- |
| 100 | 2008 | 10 | 5000 |
| 200 | 2011 | 15 | 9000 |

---

## 💡 Thought Process

### 1. The Core Problem
We cannot simply use `GROUP BY product_id` and select `quantity`, because `quantity` is not an aggregated column.
* *Wrong Query:* `SELECT product_id, MIN(year), quantity FROM Sales GROUP BY product_id`.
* *Why Wrong:* This is strictly forbidden in most SQL standards (e.g., SQL Server, Oracle, newer MySQL). The database doesn't know *which* quantity to pick if there are multiple rows for the minimum year.

### 2. The Strategy
We need a two-step process:
1.  **Find the Target:** Calculate the `MIN(year)` for every `product_id`.
    * Result: `[(100, 2008), (200, 2011)]`.
2.  **Filter the Original:** Select rows from the main table where the `(product_id, year)` pair exists in the result from Step 1.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Tuple Filtering (IN Clause)
This is the most concise and standard way to solve "Groupwise Minimum" problems in MySQL/PostgreSQL.

```sql
SELECT 
    product_id, 
    year AS first_year, 
    quantity, 
    price
FROM 
    Sales
WHERE 
    (product_id, year) IN (
        -- Step 1: Find the (Product, First Year) pairs
        SELECT 
            product_id, 
            MIN(year) 
        FROM 
            Sales
        GROUP BY 
            product_id
    );
```

### 🔹 Approach 2: Window Functions (RANK)
Using `RANK()` is powerful because it handles ties automatically (e.g., if a product was sold twice in 2008, both rows get Rank 1).

```sql
SELECT 
    product_id, 
    year AS first_year, 
    quantity, 
    price
FROM (
    SELECT 
        *, 
        RANK() OVER(PARTITION BY product_id ORDER BY year ASC) as rnk
    FROM 
        Sales
) AS ranked_sales
WHERE 
    rnk = 1;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. Tuple IN** | `WHERE (a,b) IN (...)` | ⭐⭐ Medium | **Cleanest Syntax.** Very easy to understand. Performance is usually good if there is an index on `(product_id, year)`. |
| **2. Window Function** | `RANK() OVER()` | ⭐⭐⭐ High | **Most Robust.** Avoids self-joins or subquery re-scans. It scans the table once, sorts (partitions), and filters. Ideal for large datasets. |

---

## 4. 🔍 Deep Dive

#### 1. Why `RANK()` and not `ROW_NUMBER()`?
The problem asks for **all** sales in the first year.
* Suppose Product A was sold **twice** in 2008 (Row 1 and Row 2).
* `ROW_NUMBER()`: Would give them ranks 1 and 2. Filtering `rnk=1` returns only **one** row. (Wrong)
* `RANK()`: Would give both rows rank 1. Filtering `rnk=1` returns **both** rows. (Correct)

#### 2. Index Optimization
To make Approach 1 extremely fast, you should create a composite index:
`CREATE INDEX idx_prod_year ON Sales(product_id, year);`
This allows the subquery `MIN(year)` to run purely on the index (Covering Index) without touching the actual table rows until the final lookup.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the `Sales` table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Aggregation / Sorting** | `GROUP BY` or `ORDER BY` | $O(N \log N)$ | Finding the min year or ranking requires organizing the data by product and year. |
| **2. Filtering** | `IN (...)` | $O(N \log N)$ | Looking up the tuples against the subquery result. |

**Total Complexity:** $O(N \log N)$.
