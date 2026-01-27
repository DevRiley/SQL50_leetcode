# 📦 SQL Case Study: List the Products Ordered in a Period
> **Category:** Aggregation / Date Filtering  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `GROUP BY`, `HAVING`, `SUM`, `Date Functions`

## 1. Problem Description
**Goal:** Get the names of products and their total ordered amount, specifically for orders placed in **February 2020**, where the total amount is **at least 100**.

### Table `Products`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `product_id` | int | Primary Key |
| `product_name` | varchar | Name of the product |
| `product_category` | varchar | Category |

### Table `Orders`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `product_id` | int | Foreign Key to Products |
| `order_date` | date | Date of the order |
| `unit` | int | Quantity ordered |

### Example Input
* **Product 1 (Leetcode Solutions):**
    * Feb 5: 60 units
    * Feb 10: 70 units
    * *Total Feb:* 130 (Pass > 100)
* **Product 2 (Jewels of Stringology):**
    * Jan 18: 30 units (Ignore, wrong month)
    * Feb 11: 80 units
    * *Total Feb:* 80 (Fail < 100)
* **Product 5 (Leetcode Kit):**
    * Feb 25: 50 units
    * Feb 27: 50 units
    * Mar 01: 50 units (Ignore, wrong month)
    * *Total Feb:* 100 (Pass >= 100)

### Expected Output
| product_name | unit |
| :--- | :--- |
| Leetcode Solutions | 130 |
| Leetcode Kit | 100 |

---

## 💡 Thought Process

### 1. Filtering by Date
We only care about orders in **February 2020**.
* **Option A (String Matching):** `LEFT(order_date, 7) = '2020-02'` or `DATE_FORMAT`. (Easy to write, but slow as it prevents Index usage).
* **Option B (Range Check):** `order_date BETWEEN '2020-02-01' AND '2020-02-29'`. (Best for performance).

### 2. Aggregation
We need the sum of units per product.
* **Action:** `GROUP BY product_name` (or `product_id`).
* **Calculation:** `SUM(unit)`.

### 3. Conditional Filtering (Post-Aggregation)
We only want totals $\ge 100$.
* Since this condition is based on the *result* of a calculation (`SUM`), we must use the **`HAVING`** clause, not `WHERE`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Standard Join + Group By + Having
This uses the standard index-friendly date range check.

```sql
SELECT 
    p.product_name, 
    SUM(o.unit) AS unit
FROM 
    Products p
JOIN 
    Orders o ON p.product_id = o.product_id
WHERE 
    o.order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY 
    p.product_id, 
    p.product_name
HAVING 
    SUM(o.unit) >= 100;
```

### 🔹 Approach 2: Using String Date Functions (For Simplicity)
If performance is not the primary concern and you want concise code.

```sql
SELECT 
    p.product_name, 
    SUM(o.unit) AS unit
FROM 
    Products p
JOIN 
    Orders o ON p.product_id = o.product_id
WHERE 
    o.order_date LIKE '2020-02%'
GROUP BY 
    p.product_id, 
    p.product_name
HAVING 
    SUM(o.unit) >= 100;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Date Filter Syntax | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. BETWEEN** | `'2020-02-01' AND '2020-02-29'` | ⭐⭐⭐ High | **SARGable.** The database can use an index on `order_date` to instantly find the rows. This is the professional standard. |
| **2. LIKE / LEFT** | `LIKE '2020-02%'` | ⭐⭐ Medium | **Non-SARGable.** The database often has to scan every single row and run the string function to check the date. |

---

## 4. 🔍 Deep Dive

#### 1. WHERE vs. HAVING
* **`WHERE`**: Filters **rows** before they are grouped.
    * *Usage here:* We use `WHERE` to filter `order_date` because we want to throw away non-February rows *before* we start counting.
* **`HAVING`**: Filters **groups** after they are aggregated.
    * *Usage here:* We use `HAVING` to check `SUM(unit) >= 100` because we can't know the sum until after we've grouped the February orders.

#### 2. Why 2020 has 29 days?
This is a small detail in date range queries. 2020 was a **Leap Year**. If you hardcoded `'2020-02-28'`, you might miss orders on the 29th.
* *Tip:* Using `o.order_date >= '2020-02-01' AND o.order_date < '2020-03-01'` is often safer because you don't need to remember if it's a leap year.

---

## 5. ⏱️ Time Complexity Analysis

Let $O$ be the number of orders and $P$ be the number of products.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Joining** | `JOIN` | $O(O \log P)$ | Linking orders to product names using PK/FK. |
| **2. Filtering** | `WHERE` | $O(\log O)$ or $O(O)$ | Depends on index. If indexed, logarithmic; otherwise linear scan. |
| **3. Aggregation** | `GROUP BY` | $O(F)$ | Where $F$ is the number of filtered rows (February orders). |

**Total Complexity:** Efficient, dominated by the number of orders in the target month.
