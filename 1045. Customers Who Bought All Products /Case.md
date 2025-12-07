# 🛒 SQL Case Study: Customers Who Bought All Products
> **Category:** Aggregation / Relational Division  
> **Difficulty:** Medium  
> **Tags:** `SQL`, `GROUP BY`, `HAVING`, `COUNT DISTINCT`, `Subquery`

## 1. Problem Description
**Goal:** Identify the customers who have purchased **every single product** listed in the `Product` table.

We need to compare two sets:
1.  The set of unique products a customer has bought.
2.  The set of all available products in the `Product` table.

If these two sets have the same size (count), the customer has bought everything.

### Table `Customer`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `customer_id` | int | ID of the customer |
| `product_key` | int | ID of the product purchased |

*(This table may contain duplicate rows. A customer might buy the same product multiple times).*

### Table `Product`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `product_key` | int | Primary Key (All available products) |

### Example Input
**Product Table:** (Total Products = 2)
| product_key |
| :--- |
| 5 |
| 6 |

**Customer Table:**
| customer_id | product_key | Analysis |
| :--- | :--- | :--- |
| 1 | 5 | ... |
| 1 | 6 | **Bought {5, 6}. Count = 2. Match!** |
| 2 | 6 | Bought {6}. Count = 1. Fail. |
| 3 | 5 | ... |
| 3 | 6 | **Bought {5, 6}. Count = 2. Match!** |

### Expected Output
| customer_id |
| :--- |
| 1 |
| 3 |

---

## 💡 Thought Process

### 1. The Logic: Comparing Counts
Since we don't care *when* they bought it or *how many times* they bought it, we can simplify this to a counting problem.

1.  **Get the Target Number:** Count how many unique products exist in the `Product` table. (In the example, this is **2**).
2.  **Count per Customer:** Group the `Customer` table by `customer_id` and count how many **unique** products they bought.
3.  **Filter:** Only keep customers where `My_Unique_Count == Target_Number`.

### 2. The Trap: Duplicates
The `Customer` table may contain duplicates.
* Example: Customer 2 buys Product 6 three times.
* If we use `COUNT(product_key)`, the result is 3.
* If the Total Products count is 2, we might falsely think Customer 2 bought everything because $3 > 2$.
* **Fix:** We MUST use `COUNT(DISTINCT product_key)`.

---

## 2. Solutions & Implementation

### ✅ Approach 1: Group By + Having (The Standard Solution)
This is the most readable and efficient way to handle "For All" queries in modern SQL.

```sql
SELECT 
    customer_id
FROM 
    Customer
GROUP BY 
    customer_id
HAVING 
    COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product);
```

---

## 3. ⚖️ Comparative Analysis

| Component | Code | Reason |
| :--- | :--- | :--- |
| **Grouping** | `GROUP BY customer_id` | We need to analyze each customer individually. |
| **Counting** | `COUNT(DISTINCT product_key)` | Ensures we don't double-count if a customer bought the same item twice. We only care about the *variety* of items. |
| **Comparison** | `= (SELECT COUNT(*) FROM Product)` | This dynamic subquery calculates the total number of products available. |

---

## 4. 🔍 Deep Dive: Relational Division

This problem is a specific instance of **Relational Division**.
* In Set Theory: If $A$ is the set of products Customer 1 bought, and $B$ is the set of all products. We want customers where $B \subseteq A$.
* Since we know $A$ cannot contain products that don't exist in $B$ (due to Foreign Key constraints), we just need to prove that the **Cardinality (Size)** of the sets is equal. $|A| = |B|$.

#### Alternative Approach (Double Negative)
In older SQL or strictly academic contexts, you might see this solved using `NOT EXISTS`:
*"Find customers where there is NO product that they have NOT bought."*
```sql
SELECT DISTINCT customer_id FROM Customer c1
WHERE NOT EXISTS (
    SELECT product_key FROM Product
    WHERE product_key NOT IN (
        SELECT product_key FROM Customer c2 WHERE c2.customer_id = c1.customer_id
    )
);
```
*Note: This is much harder to read and perform. Use the `HAVING COUNT` approach for interviews.*

---

## 5. ⏱️ Time Complexity Analysis

Let $C$ be the number of rows in `Customer` and $P$ be the number of rows in `Product`.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Target Count** | `SELECT COUNT(*)` | $O(P)$ | Scans the Product table once. |
| **2. Grouping** | `GROUP BY` | $O(C)$ | Scans the Customer table. |
| **3. Dedup Count** | `COUNT(DISTINCT)` | $O(C)$ | Requires hashing/sorting product IDs within each customer group. |

**Total Complexity:** $O(C + P)$.
