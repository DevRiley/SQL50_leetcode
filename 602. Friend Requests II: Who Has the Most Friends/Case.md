# 🤝 SQL Case Study: Friend Requests II (Who has the most friends?)
> **Category:** Union / Aggregation
> **Difficulty:** Medium
> **Tags:** `SQL`, `UNION ALL`, `GROUP BY`, `ORDER BY`, `LIMIT`

## 1. Problem Description
**Goal:** Find the person (or people) who has the **most friends** and report the total number of friends.

In this social network:
* A friendship is defined by a row in the `RequestAccepted` table.
* Friendship is **bidirectional**. If User A accepts a request from User B, they are friends. Both A and B gain +1 friend count.
* The data is split across `requester_id` and `accepter_id`.

### Table `RequestAccepted`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `requester_id` | int | User who sent the request |
| `accepter_id` | int | User who accepted the request |
| `accept_date` | date | Date of acceptance |

### Example Input
| requester_id | accepter_id |
| :--- | :--- |
| 1 | 2 |
| 1 | 3 |
| 2 | 3 |
| 3 | 4 |

### Expected Output
| id | num |
| :--- | :--- |
| 3 | 3 |

**Explanation:**
* **User 1:** Friends with 2, 3. (Count: 2)
* **User 2:** Friends with 1, 3. (Count: 2)
* **User 3:** Friends with 1, 2, 4. (Count: **3**)
* **User 4:** Friend with 3. (Count: 1)
User 3 has the highest count.

---

## 💡 Thought Process

### 1. The Data Shape Issue
The main challenge is that a user's ID can appear in **either** the `requester_id` column **or** the `accepter_id` column.
* To count User 3's friends, we need to find rows where `requester_id = 3` **AND** rows where `accepter_id = 3`.

### 2. The Strategy: Normalize with UNION ALL
Instead of writing complex `OR` conditions, the best approach is to "stack" the two columns into one long list of IDs.
* Step 1: Extract all `requester_id`s.
* Step 2: Extract all `accepter_id`s.
* Step 3: Combine them into a single list using `UNION ALL`.



Once we have a single vertical list of all participants in every friendship, we simply `GROUP BY id` and count the occurrences.

---

## 2. Solutions & Implementation

### ✅ Approach 1: UNION ALL + LIMIT (Basic Solution)
This solves the primary problem where there is guaranteed to be only one winner.

```sql
SELECT 
    id, 
    COUNT(*) AS num
FROM (
    -- Get all requesters
    SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    -- Get all accepters
    SELECT accepter_id AS id FROM RequestAccepted
) AS all_friends
GROUP BY 
    id
ORDER BY 
    num DESC
LIMIT 1;
```

### 🔹 Follow-up: Handling Ties (Multiple Winners)
If multiple people share the same maximum number of friends, `LIMIT 1` is insufficient. We need to use `RANK()` or `DENSE_RANK()`.

```sql
WITH FriendCounts AS (
    SELECT 
        id, 
        COUNT(*) AS num
    FROM (
        SELECT requester_id AS id FROM RequestAccepted
        UNION ALL
        SELECT accepter_id AS id FROM RequestAccepted
    ) AS combined
    GROUP BY id
),
Ranked AS (
    SELECT 
        id, 
        num, 
        RANK() OVER (ORDER BY num DESC) as rk
    FROM FriendCounts
)
SELECT id, num
FROM Ranked
WHERE rk = 1;
```

---

## 3. ⚖️ Comparative Analysis

| Approach | Logic | Performance | Note |
| :--- | :--- | :--- | :--- |
| **1. UNION ALL** | Stack & Count | ⭐⭐⭐ High | **Best Practice.** `UNION ALL` is very fast because it just appends data without sorting or deduplicating. |
| **2. Case/Sum** | `SUM(CASE WHEN id=req THEN 1 ...)` | ⭐ Low | **Inefficient.** Requires knowing all potential IDs beforehand or scanning the table multiple times with complex logic. |

---

## 4. 🔍 Deep Dive

#### 1. UNION vs. UNION ALL
* **`UNION`**: Removes duplicates. (e.g., if User 1 appears twice, it keeps 1). **Bad here!** We need to count every instance to know how many friends they have.
* **`UNION ALL`**: Keeps duplicates. **Good here!** If User 1 appears 5 times in the combined list, it means they have 5 friends.

#### 2. Why not just join?
Trying to join the table to itself to find friends of friends is valid for "Social Graph Traversal" (e.g., finding 2nd-degree connections), but for simple counting, flat aggregation via `UNION ALL` is O(N) and much cheaper than joining O(N²).

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in `RequestAccepted`.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Stacking** | `UNION ALL` | $O(N)$ | Simple append operation. Creates a virtual table of size $2N$. |
| **2. Aggregation** | `GROUP BY` | $O(N)$ | Scans the $2N$ rows to count frequencies. |
| **3. Sorting** | `ORDER BY` | $O(U \log U)$ | Where $U$ is the number of unique users. |

**Total Complexity:** $O(N)$.
