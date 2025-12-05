# 🛵 SQL Case Study: Immediate Food Delivery II
> **Category:** Filtering / Aggregation / Subqueries  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `Tuple Filtering`, `MIN()`, `AVG`, `Date Logic`

## 1. Problem Description
**Goal:** Calculate the percentage of **immediate** orders among the **first orders** of all customers.

We need to filter the dataset to keep only the *first* order made by each customer. Then, within that filtered set, we calculate what percentage of them were "Immediate".

**Definitions:**
* **Immediate Order:** `order_date` == `customer_pref_delivery_date`
* **First Order:** The order with the minimum `order_date` for a specific customer.

### Table `Delivery`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `delivery_id` | int | Primary Key |
| `customer_id` | int | Customer ID |
| `order_date` | date | Date the order was made |
| `customer_pref_delivery_date` | date | Date the customer wants food |

### Example Input
| delivery_id | customer_id | order_date | customer_pref... | Type | Note |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | 1 | **2019-08-01** | 2019-08-02 | Scheduled | **First** |
| 2 | 2 | **2019-08-02** | 2019-08-02 | Immediate | **First** |
| 3 | 1 | 2019-08-11 | ... | ... | Not First |
| 5 | 3 | **2019-08-21** | 2019-08-22 | Scheduled | **First** |
| 7 | 4 | **2019-08-09** | 2019-08-09 | Immediate | **First** |

### Expected Output
| immediate_percentage |
| :--- |
| 50.00 |

**Explanation:**
* **Total First Orders:** 4 (Customers 1, 2, 3, 4).
* **Immediate First Orders:** 2 (Customer 2 and Customer 4).
* **Calculation:** $2 / 4 = 0.50 \rightarrow 50.00\%$.

---

## 💡 Thought Process

### 1. Step 1: Identify the First Orders
We cannot simply check `MIN(order_date)` globally. We need the minimum date **per customer**.
* **Logic:** Group by `customer_id` and find `MIN(order_date)`.
* **Result:** A list of pairs `(customer_id, first_order_date)`.

### 2. Step 2: Filter the Main Table
We only want to perform calculations on the rows identified in Step 1.
* **Technique:** Use a `WHERE` clause with a **Tuple** comparison.
    * `WHERE (customer_id, order_date) IN (...)`

### 3. Step 3: Calculate the Percentage
Once we have filtered down to only the 4 "First Order" rows, we use the Boolean Averaging trick (introduced in the previous problem).
* Logic: `AVG(order_date = customer_pref_delivery_date)`.
* If immediate: 1. If scheduled: 0.
* Average of [0, 1, 0, 1] is 0.5.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Tuple Filtering (Standard Solution)
This approach is very concise and leverages the power of SQL's tuple comparison capabilities.

```sql
SELECT 
    ROUND(AVG(order_date = customer_pref_delivery_date) * 100, 2) AS immediate_percentage
FROM 
    Delivery
WHERE 
    (customer_id, order_date) IN (
        SELECT 
            customer_id, 
            MIN(order_date) 
        FROM 
            Delivery
        GROUP BY 
            customer_id
    );
```

### 🔹 Approach 2: Window Functions (Modern Approach)
If the database supports `RANK()` or `ROW_NUMBER()`, this avoids the subquery re-scan and is often more scalable for complex logic.

```sql
SELECT 
    ROUND(
        SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
    , 2) AS immediate_percentage
FROM (
    SELECT 
        *,
        RANK() OVER(PARTITION BY customer_id ORDER BY order_date ASC) as rnk
    FROM 
        Delivery
) AS ranked_orders
WHERE 
    rnk = 1;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Syntax | Performance | Pros & Cons |
| :--- | :--- | :--- | :--- |
| **1. Tuple IN** | `WHERE (col1, col2) IN (...)` | ⭐⭐ Medium | **Cleanest Syntax.** Easy to read. Performance depends on whether the DB can optimize tuple lookups (MySQL is good at this). |
| **2. Window Function** | `RANK() OVER(...)` | ⭐⭐⭐ High | **Most Flexible.** Best if you need to handle ties specifically or keep other columns. Scans the table once. |

---

## 4. 🔍 Deep Dive

#### 1. Why `(customer_id, order_date)` tuple?
Why not just `WHERE order_date IN (SELECT MIN(order_date)...)`?
* **The Bug:** If Customer A's *first* order was on Jan 1st, and Customer B's *third* order was also on Jan 1st, filtering by date alone would incorrectly include Customer B's third order.
* **The Fix:** We must match **both** the ID and the Date together to ensure we are grabbing the specific row that corresponds to that customer's first order.

#### 2. Boolean Averaging vs. Count
* `AVG(order_date = customer_pref_delivery_date)` works in MySQL because `True` is `1` and `False` is `0`.
* In SQL Server / PostgreSQL, you would use:
    `CAST(SUM(CASE WHEN ... THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)`.

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in the `Delivery` table.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Subquery** | `GROUP BY` | $O(N)$ | Finds the min date for all customers. |
| **2. Filtering** | `IN (Subquery)` | $O(N \log N)$ | The DB looks up each row against the result of the subquery. Indexes on `(customer_id, order_date)` make this very fast ($O(N)$). |
| **3. Aggregation** | `AVG` | $O(C)$ | Where $C$ is the number of customers (rows remaining after filter). |

**Total Complexity:** $O(N \log N)$ or $O(N)$ with good indexing.
