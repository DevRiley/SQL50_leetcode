# 🤝 SQL Case Study: Friend Requests II (Most Friends & Handling Ties)
> **Category:** Aggregation / Union / Ranking    
> **Difficulty:** Medium    
> **Tags:** `SQL`, `UNION ALL`, `GROUP BY`, `RANK`, `DENSE_RANK`

## 1. Problem Description
**Goal:** Find the person (or people) who has the **most friends** and report the total number of friends.

In this social network:
* A friendship is defined by a row in the `RequestAccepted` table.
* Friendship is **bidirectional**. If User A accepts a request from User B, they are friends. Both A and B gain +1 friend count.
* The data is split across `requester_id` and `accepter_id`.

**Follow-up Requirement:** In the real world, multiple people could have the same "most" number of friends (a tie). The solution should be able to find **all** these people.

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

### ✅ Approach 1: Basic Solution (Limit 1)
Use this if the problem guarantees only one winner.

```sql
SELECT 
    id, 
    COUNT(*) AS num
FROM (
    SELECT requester_id AS id FROM RequestAccepted
    UNION ALL
    SELECT accepter_id AS id FROM RequestAccepted
) AS all_friends
GROUP BY 
    id
ORDER BY 
    num DESC
LIMIT 1;
```

### 🔹 Approach 2: Follow-up Solution (Handling Ties)
Use this to return **all** users who share the top spot. We use `RANK()` or `DENSE_RANK()` to assign rank #1 to the highest counts.

```sql
WITH FriendCounts AS (
    SELECT 
        id, 
        COUNT(*) AS num
    FROM (
        SELECT requester_id AS id FROM RequestAccepted
        UNION ALL
        SELECT accepter_id AS id FROM RequestAccepted
    ) AS all_ids
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

## 3. 🔍 Deep Dive: UNION vs. UNION ALL

This is the most critical concept in this problem. Why did we choose `UNION ALL`?

| Feature | UNION | UNION ALL |
| :--- | :--- | :--- |
| **Duplicates** | **Removes duplicates.** It performs a distinct check on the result set. | **Keeps duplicates.** It simply stacks the results of the second query under the first. |
| **Performance** | **Slower.** The database must perform a sort or hash operation to identify and remove duplicates. | **Faster.** No sorting or checking required; just append data. |
| **Context Logic** | **Wrong for this problem.** If User 1 appears 5 times in the list (has 5 friends), `UNION` would compress them into a single row `1`. The count would become 1, which is incorrect. | **Correct for this problem.** We *need* the duplicates because each occurrence represents one friend connection. |

**Example:**
* **Query A (Requesters):** `[1, 1, 2]`
* **Query B (Accepters):** `[2, 3, 3]`

* **Result of `UNION`:** `[1, 2, 3]` (Count for User 1 is lost).
* **Result of `UNION ALL`:** `[1, 1, 2, 2, 3, 3]` (User 1 appears twice $\rightarrow$ Count = 2. Correct!).

---

## 4. ⚖️ Comparative Analysis

| Approach | Logic | Performance | Best For |
| :--- | :--- | :--- | :--- |
| **1. LIMIT 1** | Simple Sort | ⭐⭐⭐ High | Simple interview questions where "unique winner" is guaranteed. |
| **2. RANK()** | Window Function | ⭐⭐⭐ High | **Real-world scenarios.** Robust against ties. Modern standard. |

---

## 5. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows in `RequestAccepted`.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Stacking** | `UNION ALL` | $O(N)$ | Simple append operation. Creates a virtual table of size $2N$. |
| **2. Aggregation** | `GROUP BY` | $O(N)$ | Scans the $2N$ rows to count frequencies. |
| **3. Sorting** | `ORDER BY` | $O(U \log U)$ | Where $U$ is the number of unique users. |

**Total Complexity:** $O(N)$ (Linear complexity relative to the number of friend connections).
