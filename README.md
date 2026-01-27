# SQL 50 LeetCode - Learning Notes & Interview Prep

> A comprehensive study guide covering all core SQL concepts from the LeetCode SQL 50 challenge, with common patterns, interview tips, and problem references.

---

## 📑 Table of Contents

- [1. SELECT Fundamentals](#1-select-fundamentals)
- [2. JOIN Operations](#2-join-operations)
- [3. Aggregate Functions & GROUP BY](#3-aggregate-functions--group-by)
- [4. Subqueries](#4-subqueries)
- [5. Window Functions](#5-window-functions)
- [6. String Functions](#6-string-functions)
- [7. Date & Time Functions](#7-date--time-functions)
- [8. Conditional Logic (CASE WHEN)](#8-conditional-logic-case-when)
- [9. UNION & Set Operations](#9-union--set-operations)
- [9.5 CTE (Common Table Expressions)](#95-cte-common-table-expressions)
- [10. Real-World Business Scenarios](#10-real-world-business-scenarios) ⭐
- [11. SQL Traps & Gotchas](#11-sql-traps--gotchas-面試陷阱題) 🆕⚠️
- [12. Common Patterns & Tricks](#12-common-patterns--tricks)
- [13. Interview Frequently Asked Topics](#13-interview-frequently-asked-topics)
- [14. Problems by Category](#14-problems-by-category)
- [15. Performance Optimization](#15-performance-optimization)

---

## 1. SELECT Fundamentals

### 1.1 DISTINCT - Remove Duplicates

```sql
SELECT DISTINCT column_name FROM table_name;
```

**When to use:** Remove duplicate rows from results.

**📌 Reference Problems:** 1148. Article Views I

---

### 1.2 WHERE - Filtering Rows

```sql
-- Basic comparison
SELECT * FROM Products WHERE price > 100;

-- Multiple conditions
SELECT * FROM Products WHERE low_fats = 'Y' AND recyclable = 'Y';

-- IN operator
SELECT * FROM Users WHERE country IN ('USA', 'Canada', 'UK');

-- BETWEEN (inclusive)
SELECT * FROM Orders WHERE order_date BETWEEN '2023-01-01' AND '2023-12-31';
```

**📌 Reference Problems:** 1757. Recyclable and Low Fat Products, 595. Big Countries

---

### 1.3 NULL Handling ⚠️ Critical Interview Topic

```sql
-- ❌ WRONG: NULL cannot be compared with = or !=
SELECT * FROM Customer WHERE referee_id != 2;  -- Misses NULL values!

-- ✅ CORRECT: Always handle NULL explicitly
SELECT * FROM Customer WHERE referee_id != 2 OR referee_id IS NULL;

-- COALESCE: Replace NULL with default value
SELECT name, COALESCE(bonus, 0) AS bonus FROM Employee;

-- IFNULL (MySQL specific)
SELECT name, IFNULL(bonus, 0) AS bonus FROM Employee;
```

**🎯 Key Insight:** `NULL != 2` evaluates to `NULL` (unknown), not `TRUE`. Always consider NULL cases!

**📌 Reference Problems:** 584. Find Customer Referee, 577. Employee Bonus

---

### 1.4 ORDER BY & LIMIT

```sql
-- Basic ordering
SELECT * FROM Employee ORDER BY salary DESC;

-- Multiple columns
SELECT * FROM Employee ORDER BY department ASC, salary DESC;

-- LIMIT with OFFSET (find Nth highest)
SELECT DISTINCT salary 
FROM Employee 
ORDER BY salary DESC 
LIMIT 1 OFFSET 1;  -- 2nd highest salary
```

**📌 Reference Problems:** 176. Second Highest Salary, 1141. User Activity for the Past 30 Days I

---

## 2. JOIN Operations

### 2.1 JOIN Types Overview

| JOIN Type | Description | Use Case |
|-----------|-------------|----------|
| INNER JOIN | Only matching rows from both tables | Find records that exist in both tables |
| LEFT JOIN | All rows from left + matching from right | Find "missing" records, preserve all left records |
| RIGHT JOIN | All rows from right + matching from left | Rarely used (can rewrite as LEFT JOIN) |
| CROSS JOIN | Cartesian product (all combinations) | Generate all possible combinations |
| SELF JOIN | Join table with itself | Compare rows within same table |

---

### 2.2 LEFT JOIN - Finding Missing Records

```sql
-- Pattern: Find records in A that don't exist in B
SELECT a.id
FROM TableA a
LEFT JOIN TableB b ON a.id = b.a_id
WHERE b.id IS NULL;
```

**Common Scenarios:**
- Customers who never ordered
- Employees without a manager
- Visits without transactions

**📌 Reference Problems:** 
- 1378. Replace Employee ID With The Unique Identifier
- 1581. Customer Who Visited but Did Not Make Any Transactions
- 577. Employee Bonus

---

### 2.3 SELF JOIN - Comparing Rows in Same Table

```sql
-- Find employees who earn more than their manager
SELECT e.name AS Employee
FROM Employee e
JOIN Employee m ON e.managerId = m.id
WHERE e.salary > m.salary;

-- Find consecutive numbers (appear 3+ times in a row)
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1
JOIN Logs l2 ON l1.id = l2.id - 1
JOIN Logs l3 ON l2.id = l3.id - 1
WHERE l1.num = l2.num AND l2.num = l3.num;
```

**📌 Reference Problems:**
- 197. Rising Temperature
- 180. Consecutive Numbers
- 1731. The Number of Employees Which Report to Each Employee

---

### 2.4 CROSS JOIN - Generate All Combinations

```sql
-- Generate all student-subject combinations
SELECT s.student_id, s.student_name, sub.subject_name
FROM Students s
CROSS JOIN Subjects sub;
```

**When to use:** When you need every possible combination (e.g., all students × all subjects).

**📌 Reference Problems:** 1280. Students and Examinations

---

## 3. Aggregate Functions & GROUP BY

### 3.1 Common Aggregate Functions

| Function | Description | NULL Handling |
|----------|-------------|---------------|
| `COUNT(*)` | Count all rows | Includes NULL |
| `COUNT(column)` | Count non-NULL values | Excludes NULL |
| `COUNT(DISTINCT col)` | Count unique non-NULL values | Excludes NULL |
| `SUM(column)` | Sum of values | Ignores NULL |
| `AVG(column)` | Average of values | Ignores NULL |
| `MAX(column)` | Maximum value | Ignores NULL |
| `MIN(column)` | Minimum value | Ignores NULL |

---

### 3.2 GROUP BY Patterns

```sql
-- Basic grouping
SELECT department, COUNT(*) AS emp_count
FROM Employee
GROUP BY department;

-- Multiple columns
SELECT department, job_title, AVG(salary)
FROM Employee
GROUP BY department, job_title;
```

**📌 Reference Problems:**
- 1075. Project Employees I
- 1633. Percentage of Users Attended a Contest
- 1211. Queries Quality and Percentage

---

### 3.3 HAVING vs WHERE ⚠️ Critical Difference

```sql
-- WHERE: Filter BEFORE grouping (cannot use aggregate functions)
-- HAVING: Filter AFTER grouping (can use aggregate functions)

SELECT customer_id, COUNT(*) AS order_count
FROM Orders
WHERE status = 'completed'      -- Filter rows first
GROUP BY customer_id
HAVING COUNT(*) >= 5;           -- Filter groups after
```

**📌 Reference Problems:**
- 596. Classes With at Least 5 Students
- 1729. Find Followers Count
- 570. Managers with at Least 5 Direct Reports

---

### 3.4 Aggregation with ROUND

```sql
-- Round to 2 decimal places
SELECT ROUND(AVG(salary), 2) AS avg_salary FROM Employee;

-- Percentage calculation
SELECT ROUND(COUNT(DISTINCT buyer_id) * 100.0 / COUNT(DISTINCT user_id), 2) AS percentage
FROM Users;
```

**📌 Reference Problems:** 1251. Average Selling Price, 1193. Monthly Transactions I

---

## 4. Subqueries

### 4.1 When to Use Subqueries

| Scenario | Solution |
|----------|----------|
| Filter based on aggregated value | Subquery in WHERE |
| Compare with another table's result | Subquery with IN/EXISTS |
| Need a derived/computed table | Subquery in FROM |
| Scalar value needed | Subquery in SELECT |

---

### 4.2 Subquery in WHERE

```sql
-- Find employees with salary above average
SELECT name, salary
FROM Employee
WHERE salary > (SELECT AVG(salary) FROM Employee);

-- Find employees in departments with > 10 people
SELECT *
FROM Employee
WHERE department_id IN (
    SELECT department_id
    FROM Employee
    GROUP BY department_id
    HAVING COUNT(*) > 10
);
```

**📌 Reference Problems:**
- 1978. Employees Whose Manager Left the Company
- 176. Second Highest Salary
- 185. Department Top Three Salaries

---

### 4.3 Subquery in FROM (Derived Table)

```sql
-- First aggregate, then filter
SELECT *
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM Orders
    GROUP BY customer_id
) AS subquery
WHERE order_count > 5;
```

**📌 Reference Problems:** 
- 1174. Immediate Food Delivery II
- 550. Game Play Analysis IV

---

### 4.4 Correlated Subquery

```sql
-- For each row, run subquery that references outer query
SELECT e1.name, e1.salary, e1.department_id
FROM Employee e1
WHERE e1.salary = (
    SELECT MAX(e2.salary)
    FROM Employee e2
    WHERE e2.department_id = e1.department_id  -- References outer query
);
```

**🎯 Key Insight:** Correlated subqueries run once per row - can be slow on large datasets.

**📌 Reference Problems:** 1070. Product Sales Analysis III

---

### 4.5 EXISTS vs IN

```sql
-- EXISTS: Returns TRUE if subquery returns any rows
SELECT c.name
FROM Customers c
WHERE EXISTS (
    SELECT 1 FROM Orders o WHERE o.customer_id = c.id
);

-- IN: Checks if value exists in subquery result set
SELECT c.name
FROM Customers c
WHERE c.id IN (SELECT customer_id FROM Orders);
```

**When to use EXISTS:**
- Subquery returns many rows
- Only need to check existence, not values
- Better performance with correlated subqueries

**📌 Reference Problems:** 1045. Customers Who Bought All Products

---

## 5. Window Functions

### 5.1 Window Function Syntax

```sql
FUNCTION_NAME() OVER (
    [PARTITION BY column(s)]    -- Optional: divide into groups
    [ORDER BY column(s)]        -- Optional: order within partition
    [ROWS/RANGE frame]          -- Optional: define window frame
)
```

---

### 5.2 Ranking Functions

| Function | Ties Handling | Example (1,1,3 vs 1,1,2) |
|----------|---------------|--------------------------|
| `ROW_NUMBER()` | Unique numbers | 1, 2, 3, 4 |
| `RANK()` | Same rank, skip next | 1, 1, 3, 4 |
| `DENSE_RANK()` | Same rank, no skip | 1, 1, 2, 3 |

```sql
-- Find top 3 salaries per department
SELECT department_id, name, salary,
       DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rank
FROM Employee;
```

**📌 Reference Problems:**
- 185. Department Top Three Salaries
- 176. Second Highest Salary

---

### 5.3 LAG & LEAD - Access Previous/Next Rows

```sql
-- Compare with previous row
SELECT 
    id,
    recordDate,
    temperature,
    LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp
FROM Weather;

-- Find days warmer than previous day
SELECT w1.id
FROM (
    SELECT id, temperature,
           LAG(temperature) OVER (ORDER BY recordDate) AS prev_temp
    FROM Weather
) w1
WHERE w1.temperature > w1.prev_temp;
```

**📌 Reference Problems:** 197. Rising Temperature

---

### 5.4 Running Total / Moving Average

```sql
-- Running total
SELECT 
    order_date,
    amount,
    SUM(amount) OVER (ORDER BY order_date) AS running_total
FROM Orders;

-- 7-day moving average
SELECT 
    visited_on,
    SUM(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS amount,
    ROUND(AVG(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS average_amount
FROM Customer;
```

**📌 Reference Problems:** 1321. Restaurant Growth

---

## 6. String Functions

### 6.1 Common String Functions

| Function | Description | Example |
|----------|-------------|---------|
| `CONCAT(a, b)` | Concatenate strings | `CONCAT('Hello', ' World')` → 'Hello World' |
| `SUBSTRING(str, start, len)` | Extract substring | `SUBSTRING('Hello', 1, 3)` → 'Hel' |
| `LEFT(str, n)` | First n characters | `LEFT('Hello', 2)` → 'He' |
| `RIGHT(str, n)` | Last n characters | `RIGHT('Hello', 2)` → 'lo' |
| `LENGTH(str)` | String length | `LENGTH('Hello')` → 5 |
| `UPPER(str)` | Uppercase | `UPPER('hello')` → 'HELLO' |
| `LOWER(str)` | Lowercase | `LOWER('HELLO')` → 'hello' |
| `TRIM(str)` | Remove leading/trailing spaces | `TRIM('  hi  ')` → 'hi' |
| `REPLACE(str, from, to)` | Replace substring | `REPLACE('abc', 'b', 'x')` → 'axc' |

---

### 6.2 Fix Names - Capitalize First Letter

```sql
SELECT user_id,
       CONCAT(UPPER(LEFT(name, 1)), LOWER(SUBSTRING(name, 2))) AS name
FROM Users
ORDER BY user_id;
```

**📌 Reference Problems:** 1667. Fix Names in a Table

---

### 6.3 GROUP_CONCAT - Aggregate Strings

```sql
-- Combine values into comma-separated list
SELECT sell_date,
       COUNT(DISTINCT product) AS num_sold,
       GROUP_CONCAT(DISTINCT product ORDER BY product) AS products
FROM Activities
GROUP BY sell_date;
```

**📌 Reference Problems:** 1484. Group Sold Products By The Date

---

### 6.4 LIKE & Regular Expressions

```sql
-- LIKE patterns
SELECT * FROM Users WHERE email LIKE '%@gmail.com';    -- Ends with
SELECT * FROM Users WHERE name LIKE 'A%';              -- Starts with
SELECT * FROM Users WHERE name LIKE '_o%';             -- Second char is 'o'

-- REGEXP (MySQL)
SELECT * FROM Patients WHERE conditions REGEXP '\\bDIAB1';  -- Word boundary
SELECT * FROM Users WHERE mail REGEXP '^[a-zA-Z][a-zA-Z0-9._-]*@leetcode\\.com$';
```

**📌 Reference Problems:**
- 1517. Find Users With Valid E-Mails
- 1527. Patients With a Condition

---

## 7. Date & Time Functions

### 7.1 Common Date Functions

| Function | Description | Example |
|----------|-------------|---------|
| `DATEDIFF(d1, d2)` | Days between dates | `DATEDIFF('2023-01-05', '2023-01-01')` → 4 |
| `DATE_ADD(date, INTERVAL n unit)` | Add time | `DATE_ADD('2023-01-01', INTERVAL 1 MONTH)` |
| `DATE_SUB(date, INTERVAL n unit)` | Subtract time | `DATE_SUB('2023-01-01', INTERVAL 7 DAY)` |
| `YEAR(date)` | Extract year | `YEAR('2023-05-15')` → 2023 |
| `MONTH(date)` | Extract month | `MONTH('2023-05-15')` → 5 |
| `DAY(date)` | Extract day | `DAY('2023-05-15')` → 15 |
| `DATE_FORMAT(date, format)` | Format date | `DATE_FORMAT('2023-05-15', '%Y-%m')` → '2023-05' |

---

### 7.2 Date Comparison Patterns

```sql
-- Find records from the past 30 days
SELECT *
FROM Activity
WHERE activity_date > DATE_SUB('2019-07-27', INTERVAL 30 DAY);

-- Compare with previous day (Self Join)
SELECT a.id
FROM Weather a
JOIN Weather b ON DATEDIFF(a.recordDate, b.recordDate) = 1
WHERE a.temperature > b.temperature;
```

**📌 Reference Problems:**
- 197. Rising Temperature
- 1141. User Activity for the Past 30 Days I

---

### 7.3 Date Formatting for Grouping

```sql
-- Group by year-month
SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month,
       country,
       COUNT(*) AS trans_count
FROM Transactions
GROUP BY DATE_FORMAT(trans_date, '%Y-%m'), country;
```

**📌 Reference Problems:** 1193. Monthly Transactions I

---

## 8. Conditional Logic (CASE WHEN)

### 8.1 Basic CASE WHEN

```sql
SELECT id,
       CASE 
           WHEN x + y > z AND x + z > y AND y + z > x THEN 'Yes'
           ELSE 'No'
       END AS triangle
FROM Triangle;
```

**📌 Reference Problems:** 610. Triangle Judgement

---

### 8.2 CASE WHEN with Aggregation

```sql
-- Conditional counting
SELECT 
    COUNT(CASE WHEN state = 'approved' THEN 1 END) AS approved_count,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total
FROM Transactions;

-- Percentage calculation
SELECT 
    ROUND(100.0 * SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS immediate_percentage
FROM Delivery;
```

**📌 Reference Problems:**
- 1193. Monthly Transactions I
- 1174. Immediate Food Delivery II

---

### 8.3 IF Function (MySQL shorthand)

```sql
-- IF(condition, true_value, false_value)
SELECT IF(stock = 0, 'Out of Stock', 'In Stock') AS status FROM Products;

-- Equivalent to CASE WHEN
SELECT 
    CASE WHEN stock = 0 THEN 'Out of Stock' ELSE 'In Stock' END AS status 
FROM Products;
```

---

## 9. UNION & Set Operations

### 9.1 UNION vs UNION ALL

```sql
-- UNION: Removes duplicates (slower)
SELECT city FROM Customers
UNION
SELECT city FROM Suppliers;

-- UNION ALL: Keeps duplicates (faster)
SELECT city FROM Customers
UNION ALL
SELECT city FROM Suppliers;
```

---

### 9.2 Combining Different Results

```sql
-- Combine results from different queries
(SELECT name AS results FROM MovieRating ... ORDER BY ... LIMIT 1)
UNION ALL
(SELECT title AS results FROM MovieRating ... ORDER BY ... LIMIT 1);
```

**📌 Reference Problems:** 1341. Movie Rating, 602. Friend Requests II: Who Has the Most Friends

---

## 9.5 CTE (Common Table Expressions)

> 💡 CTEs make complex queries readable, maintainable, and reusable. Master this for senior-level SQL interviews!

### Why Use CTE?

| Benefit | Description |
|---------|-------------|
| **Readability** | Break complex queries into logical steps |
| **Reusability** | Reference the same subquery multiple times |
| **Recursion** | Handle hierarchical data (org charts, trees) |
| **Debugging** | Test each part independently |

---

### 9.5.1 Basic CTE Syntax

```sql
WITH cte_name AS (
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
SELECT * FROM cte_name;
```

**Example: Find above-average salary employees**

```sql
-- Without CTE (nested subquery - hard to read)
SELECT name, salary
FROM Employee
WHERE salary > (SELECT AVG(salary) FROM Employee);

-- With CTE (cleaner)
WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal FROM Employee
)
SELECT e.name, e.salary
FROM Employee e, avg_salary
WHERE e.salary > avg_salary.avg_sal;
```

---

### 9.5.2 Multiple CTEs (Chained)

```sql
WITH 
-- Step 1: Get first login date for each user
first_login AS (
    SELECT player_id, MIN(event_date) AS first_date
    FROM Activity
    GROUP BY player_id
),
-- Step 2: Find users who logged in the next day
retained_users AS (
    SELECT f.player_id
    FROM first_login f
    JOIN Activity a ON f.player_id = a.player_id
        AND a.event_date = DATE_ADD(f.first_date, INTERVAL 1 DAY)
)
-- Step 3: Calculate retention rate
SELECT ROUND(COUNT(DISTINCT r.player_id) / COUNT(DISTINCT f.player_id), 2) AS fraction
FROM first_login f
LEFT JOIN retained_users r ON f.player_id = r.player_id;
```

**📌 Reference Problems:** 550. Game Play Analysis IV

---

### 9.5.3 CTE vs Subquery vs Temp Table

| Feature | CTE | Subquery | Temp Table |
|---------|-----|----------|------------|
| Scope | Single query | Single location | Session |
| Reusability in query | ✅ Multiple times | ❌ Once | ✅ Multiple queries |
| Recursion | ✅ Yes | ❌ No | ❌ No |
| Performance | Same as subquery | Same as CTE | Can be indexed |
| Readability | ✅ Best | ❌ Nested mess | ✅ Good |

**When to use what:**
- **CTE**: Complex logic, need to reference result multiple times in ONE query
- **Subquery**: Simple, one-time use
- **Temp Table**: Need to reuse across multiple queries, or need indexes

---

### 9.5.4 Recursive CTE (Hierarchical Data)

**Scenario:** Organization chart, category trees, bill of materials.

```sql
-- Find all employees under a manager (all levels)
WITH RECURSIVE org_chart AS (
    -- Base case: Start with the top manager
    SELECT employee_id, name, manager_id, 1 AS level
    FROM Employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: Find direct reports
    SELECT e.employee_id, e.name, e.manager_id, oc.level + 1
    FROM Employees e
    JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart ORDER BY level, name;
```

**Example: Generate number sequence**
```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 10
)
SELECT * FROM numbers;
-- Result: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
```

**Example: Generate date range**
```sql
WITH RECURSIVE dates AS (
    SELECT '2024-01-01' AS date
    UNION ALL
    SELECT DATE_ADD(date, INTERVAL 1 DAY)
    FROM dates
    WHERE date < '2024-01-31'
)
SELECT * FROM dates;
```

---

### 9.5.5 CTE for Running Totals & Comparisons

```sql
-- Compare each month to previous month
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM Orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
with_previous AS (
    SELECT 
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS prev_revenue
    FROM monthly_sales
)
SELECT 
    month,
    revenue,
    prev_revenue,
    ROUND(100.0 * (revenue - prev_revenue) / prev_revenue, 2) AS growth_pct
FROM with_previous;
```

---

### 9.5.6 CTE for De-duplication Logic

```sql
-- Keep only the latest record per user
WITH ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY updated_at DESC) AS rn
    FROM UserProfiles
)
SELECT user_id, email, name, updated_at
FROM ranked
WHERE rn = 1;
```

---

### 9.5.7 CTE Best Practices

```sql
-- ✅ GOOD: Clear naming, logical steps
WITH 
active_users AS (
    SELECT user_id FROM Logins WHERE login_date >= '2024-01-01'
),
user_orders AS (
    SELECT user_id, COUNT(*) AS order_count FROM Orders GROUP BY user_id
)
SELECT au.user_id, COALESCE(uo.order_count, 0) AS orders
FROM active_users au
LEFT JOIN user_orders uo ON au.user_id = uo.user_id;

-- ❌ BAD: Meaningless names, everything in one CTE
WITH t1 AS (
    SELECT * FROM Logins WHERE login_date >= '2024-01-01'
)
SELECT ... -- Hard to understand
```

**Naming conventions:**
- Use descriptive names: `monthly_revenue`, `first_purchase`, `active_customers`
- Avoid: `t1`, `t2`, `temp`, `cte1`

---

## 10. Real-World Business Scenarios

> 💼 This section covers 35 common business scenarios you'll encounter in real jobs and interviews.

### Quick Reference Table

| # | Scenario | Key Technique | Common In |
|---|----------|---------------|-----------|
| 10.1 | Moving Average | Window Function `ROWS BETWEEN` | Finance, E-commerce |
| 10.2 | User Retention | Subquery + Date Math | Product Analytics |
| 10.3 | Historical Pricing | Subquery + MAX date | E-commerce, Finance |
| 10.4 | Weighted Average | SUM(a*b)/SUM(b) | Finance, Analytics |
| 10.5 | First Action per User | ROW_NUMBER / MIN subquery | Product Analytics |
| 10.6 | Immediate vs Scheduled | CASE WHEN + percentage | Delivery, Logistics |
| 10.7 | Monthly Summary | DATE_FORMAT + CASE WHEN | Reporting |
| 10.8 | Conversion Rate | LEFT JOIN + conditional count | Marketing |
| 10.9 | YoY/MoM Growth | LAG window function | Finance, Reporting |
| 10.10 | Active Users | DISTINCT + date range | Product Analytics |
| 10.11 | Top N per Group | DENSE_RANK + PARTITION BY | HR, Sales |
| 10.12 | Running Balance | SUM() OVER (ORDER BY) | Finance |
| 10.13 | Did X but Not Y | LEFT JOIN + IS NULL | Marketing, Product |
| 10.14 | Employee Hierarchy | Self JOIN | HR Systems |
| 10.15 | Network Analysis | UNION ALL + aggregation | Social Platforms |
| 10.16 | Funnel Analysis | Conditional COUNT | Marketing, Product |
| 10.17 | Session Duration | Self JOIN / Pivot | Product Analytics |
| 10.18 | Cohort Analysis | Date grouping + JOIN | Product, Marketing |
| 10.19 | Inventory Tracking | Conditional SUM | E-commerce, Retail |
| 10.20 | Consecutive Streaks | ROW_NUMBER date trick | Gaming, Engagement |
| 10.21 | Gap Detection | LAG + comparison | Data Quality, Finance |
| 10.22 | Pivot Table | CASE WHEN aggregation | Reporting |
| 10.23 | Unpivot | UNION ALL | Data Transformation |
| 10.24 | Find Duplicates | GROUP BY + HAVING | Data Quality |
| 10.25 | Percentile/Median | ROW_NUMBER + math | Statistics, HR |
| 10.26 | Compare to Benchmark | Subquery / Window AVG | Performance Review |
| 10.27 | Customer LTV | Aggregation + date math | E-commerce, SaaS |
| 10.28 | RFM Analysis | NTILE + multiple metrics | Marketing |
| 10.29 | Churn Analysis | Date diff + categorization | SaaS, Subscription |
| 10.30 | A/B Test Analysis | Group comparison | Product, Marketing |
| 10.31 | Time Zone | CONVERT_TZ | Global Operations |
| 10.32 | Business Hours | DAYOFWEEK + HOUR | Operations, Support |
| 10.33 | Subscription/MRR | Conditional SUM + status | SaaS |
| 10.34 | Geo Distance | Haversine formula | Location Services |
| 10.35 | Recommendations | Self JOIN on orders | E-commerce |

---

### 10.1 Moving Average (Past N Days Average)

**Scenario:** Calculate the 7-day moving average of sales/prices/revenue.

```sql
-- Method 1: Window Function with ROWS BETWEEN
SELECT 
    visited_on,
    SUM(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS total_amount,
    ROUND(AVG(amount) OVER (ORDER BY visited_on ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg_amount
FROM Customer;

-- Method 2: Self Join (when window functions not available)
SELECT 
    c1.visited_on,
    SUM(c2.amount) AS total_amount,
    ROUND(AVG(c2.amount), 2) AS avg_amount
FROM Customer c1
JOIN Customer c2 ON c2.visited_on BETWEEN DATE_SUB(c1.visited_on, INTERVAL 6 DAY) AND c1.visited_on
GROUP BY c1.visited_on
HAVING COUNT(DISTINCT c2.visited_on) = 7;  -- Ensure we have full 7 days
```

**📌 Reference Problems:** 1321. Restaurant Growth

---

### 10.2 User Retention Rate (Day 1 Retention)

**Scenario:** Calculate percentage of users who return the day after their first login.

```sql
SELECT 
    ROUND(
        COUNT(DISTINCT CASE WHEN a.event_date = DATE_ADD(first_login, INTERVAL 1 DAY) THEN a.player_id END) * 100.0 /
        COUNT(DISTINCT a.player_id)
    , 2) AS retention_rate
FROM Activity a
JOIN (
    SELECT player_id, MIN(event_date) AS first_login
    FROM Activity
    GROUP BY player_id
) first_logins ON a.player_id = first_logins.player_id;
```

**📌 Reference Problems:** 550. Game Play Analysis IV

---

### 10.3 Price at a Specific Date (Historical Pricing)

**Scenario:** Find the product price at a given date (e.g., for invoicing, reporting).

```sql
-- Get price as of '2019-08-16', default to 10 if no price change before that date
SELECT 
    p.product_id,
    COALESCE(t.new_price, 10) AS price
FROM (SELECT DISTINCT product_id FROM Products) p
LEFT JOIN (
    SELECT product_id, new_price
    FROM Products
    WHERE (product_id, change_date) IN (
        SELECT product_id, MAX(change_date)
        FROM Products
        WHERE change_date <= '2019-08-16'
        GROUP BY product_id
    )
) t ON p.product_id = t.product_id;
```

**📌 Reference Problems:** 1164. Product Price at a Given Date

---

### 10.4 Weighted Average Price

**Scenario:** Calculate average selling price weighted by quantity sold.

```sql
SELECT 
    p.product_id,
    ROUND(SUM(p.price * u.units) / SUM(u.units), 2) AS average_price
FROM Prices p
JOIN UnitsSold u ON p.product_id = u.product_id
    AND u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;
```

**📌 Reference Problems:** 1251. Average Selling Price

---

### 10.5 First Purchase / First Action per User

**Scenario:** Find each user's first order, first login, first transaction.

```sql
-- Method 1: Subquery
SELECT *
FROM Orders
WHERE (user_id, order_date) IN (
    SELECT user_id, MIN(order_date)
    FROM Orders
    GROUP BY user_id
);

-- Method 2: Window Function (more flexible)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_date) AS rn
    FROM Orders
) t
WHERE rn = 1;
```

**📌 Reference Problems:** 1070. Product Sales Analysis III, 1174. Immediate Food Delivery II

---

### 10.6 Immediate vs Scheduled Orders Rate

**Scenario:** Calculate percentage of orders where delivery was on the same day as order.

```sql
-- Overall rate
SELECT 
    ROUND(100.0 * SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS immediate_percentage
FROM Delivery;

-- First order immediate rate (more complex)
SELECT 
    ROUND(100.0 * SUM(CASE WHEN order_date = customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS immediate_percentage
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM Delivery
) t
WHERE rn = 1;
```

**📌 Reference Problems:** 1174. Immediate Food Delivery II

---

### 10.7 Monthly/Weekly Transaction Summary

**Scenario:** Generate monthly report with approved vs total transactions.

```sql
SELECT 
    DATE_FORMAT(trans_date, '%Y-%m') AS month,
    country,
    COUNT(*) AS trans_count,
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY DATE_FORMAT(trans_date, '%Y-%m'), country;
```

**📌 Reference Problems:** 1193. Monthly Transactions I

---

### 10.8 Confirmation/Conversion Rate

**Scenario:** Calculate user confirmation rate, signup-to-purchase conversion rate.

```sql
SELECT 
    s.user_id,
    ROUND(
        COALESCE(SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END) / NULLIF(COUNT(c.action), 0), 0)
    , 2) AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c ON s.user_id = c.user_id
GROUP BY s.user_id;
```

**📌 Reference Problems:** 1934. Confirmation Rate

---

### 10.9 Year-over-Year (YoY) / Month-over-Month (MoM) Growth

**Scenario:** Compare current period performance with previous period.

```sql
-- Month-over-Month revenue growth
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM Orders
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) OVER (ORDER BY month), 2) AS growth_rate
FROM monthly_revenue;
```

---

### 10.10 Active Users in Past N Days

**Scenario:** Count unique users who performed an action in the last 30 days.

```sql
SELECT 
    activity_date AS day,
    COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN DATE_SUB('2019-07-27', INTERVAL 29 DAY) AND '2019-07-27'
GROUP BY activity_date;
```

**📌 Reference Problems:** 1141. User Activity for the Past 30 Days I

---

### 10.11 Ranking within Category (Top N per Group)

**Scenario:** Find top 3 earners in each department, top products per category.

```sql
SELECT department, name, salary
FROM (
    SELECT 
        d.name AS department,
        e.name,
        e.salary,
        DENSE_RANK() OVER (PARTITION BY e.departmentId ORDER BY e.salary DESC) AS rnk
    FROM Employee e
    JOIN Department d ON e.departmentId = d.id
) ranked
WHERE rnk <= 3;
```

**📌 Reference Problems:** 185. Department Top Three Salaries

---

### 10.12 Cumulative Sum / Running Balance

**Scenario:** Calculate account balance over time, inventory running total.

```sql
SELECT 
    account_id,
    transaction_date,
    amount,
    SUM(amount) OVER (PARTITION BY account_id ORDER BY transaction_date) AS running_balance
FROM Transactions;
```

---

### 10.13 Find Users Who Did X but Not Y

**Scenario:** Customers who visited but didn't purchase, users who signed up but never logged in.

```sql
-- Customers who visited but made no transaction
SELECT 
    v.customer_id,
    COUNT(v.visit_id) AS count_no_trans
FROM Visits v
LEFT JOIN Transactions t ON v.visit_id = t.visit_id
WHERE t.transaction_id IS NULL
GROUP BY v.customer_id;
```

**📌 Reference Problems:** 1581. Customer Who Visited but Did Not Make Any Transactions

---

### 10.14 Employee Hierarchy (Manager Reports)

**Scenario:** Count direct reports, find employees whose manager left.

```sql
-- Employees whose manager left the company
SELECT e.employee_id
FROM Employees e
LEFT JOIN Employees m ON e.manager_id = m.employee_id
WHERE e.salary < 30000 
  AND e.manager_id IS NOT NULL
  AND m.employee_id IS NULL;

-- Count direct reports per manager
SELECT 
    m.employee_id,
    m.name,
    COUNT(e.employee_id) AS reports_count,
    ROUND(AVG(e.age), 0) AS average_age
FROM Employees e
JOIN Employees m ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.name;
```

**📌 Reference Problems:** 1978. Employees Whose Manager Left the Company, 1731. The Number of Employees Which Report to Each Employee

---

### 10.15 Friend/Follower Network Analysis

**Scenario:** Count friends/followers, find most connected users.

```sql
-- Count total friends (bidirectional relationship)
SELECT id, SUM(cnt) AS num
FROM (
    SELECT requester_id AS id, COUNT(*) AS cnt FROM RequestAccepted GROUP BY requester_id
    UNION ALL
    SELECT accepter_id AS id, COUNT(*) AS cnt FROM RequestAccepted GROUP BY accepter_id
) t
GROUP BY id
ORDER BY num DESC
LIMIT 1;
```

**📌 Reference Problems:** 602. Friend Requests II: Who Has the Most Friends

---

### 10.16 Funnel Analysis (Multi-Step Conversion)

**Scenario:** Track user journey through multiple steps (view → add to cart → purchase).

```sql
-- Calculate conversion at each funnel stage
WITH funnel AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN action = 'view' THEN user_id END) AS viewed,
        COUNT(DISTINCT CASE WHEN action = 'add_to_cart' THEN user_id END) AS added_to_cart,
        COUNT(DISTINCT CASE WHEN action = 'purchase' THEN user_id END) AS purchased
    FROM UserActions
)
SELECT 
    viewed,
    added_to_cart,
    purchased,
    ROUND(100.0 * added_to_cart / viewed, 2) AS view_to_cart_rate,
    ROUND(100.0 * purchased / added_to_cart, 2) AS cart_to_purchase_rate,
    ROUND(100.0 * purchased / viewed, 2) AS overall_conversion_rate
FROM funnel;
```

---

### 10.17 Session Analysis (Time Between Actions)

**Scenario:** Calculate average session duration, time between user actions.

```sql
-- Average time between start and end of process
SELECT 
    machine_id,
    ROUND(AVG(end_time - start_time), 3) AS processing_time
FROM (
    SELECT 
        machine_id,
        process_id,
        MAX(CASE WHEN activity_type = 'start' THEN timestamp END) AS start_time,
        MAX(CASE WHEN activity_type = 'end' THEN timestamp END) AS end_time
    FROM Activity
    GROUP BY machine_id, process_id
) t
GROUP BY machine_id;
```

**📌 Reference Problems:** 1661. Average Time of Process per Machine

---

### 10.18 Cohort Analysis (User Segmentation by Sign-up Date)

**Scenario:** Group users by registration month and track their behavior over time.

```sql
-- Revenue by signup cohort
WITH user_cohort AS (
    SELECT 
        user_id,
        DATE_FORMAT(MIN(signup_date), '%Y-%m') AS cohort_month
    FROM Users
    GROUP BY user_id
)
SELECT 
    uc.cohort_month,
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.user_id) AS active_users,
    SUM(o.amount) AS total_revenue
FROM user_cohort uc
JOIN Orders o ON uc.user_id = o.user_id
GROUP BY uc.cohort_month, DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY uc.cohort_month, order_month;
```

---

### 10.19 Inventory / Stock Level Tracking

**Scenario:** Calculate current stock after purchases and sales.

```sql
-- Current inventory level per product
SELECT 
    product_id,
    SUM(CASE WHEN type = 'purchase' THEN quantity ELSE -quantity END) AS current_stock
FROM Inventory
GROUP BY product_id
HAVING current_stock > 0;

-- Products that need restocking (below threshold)
SELECT product_id, current_stock
FROM (
    SELECT 
        product_id,
        SUM(CASE WHEN type = 'in' THEN quantity ELSE -quantity END) AS current_stock
    FROM StockMovement
    GROUP BY product_id
) t
WHERE current_stock < 10;
```

---

### 10.20 Detect Consecutive Events / Streaks

**Scenario:** Find users with N consecutive days of login, winning streaks.

```sql
-- Find users with 3+ consecutive login days
WITH login_groups AS (
    SELECT 
        user_id,
        login_date,
        DATE_SUB(login_date, INTERVAL ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY login_date) DAY) AS grp
    FROM (SELECT DISTINCT user_id, login_date FROM Logins) t
)
SELECT DISTINCT user_id
FROM login_groups
GROUP BY user_id, grp
HAVING COUNT(*) >= 3;
```

**🎯 Key Insight:** The trick is subtracting row_number from date - consecutive dates will have the same result.

---

### 10.21 Detect Gaps in Sequence

**Scenario:** Find missing order numbers, missing dates in a series.

```sql
-- Find gaps in order sequence
SELECT 
    prev_id + 1 AS gap_start,
    curr_id - 1 AS gap_end
FROM (
    SELECT 
        id AS curr_id,
        LAG(id) OVER (ORDER BY id) AS prev_id
    FROM Orders
) t
WHERE curr_id - prev_id > 1;

-- Find dates with no orders
SELECT calendar.date
FROM (
    SELECT DATE_ADD('2023-01-01', INTERVAL n DAY) AS date
    FROM (SELECT ROW_NUMBER() OVER () - 1 AS n FROM Orders LIMIT 365) nums
) calendar
LEFT JOIN Orders o ON calendar.date = o.order_date
WHERE o.order_id IS NULL;
```

---

### 10.22 Pivot Table (Rows to Columns)

**Scenario:** Transform category values into separate columns.

```sql
-- Sales by product category as columns
SELECT 
    month,
    SUM(CASE WHEN category = 'Electronics' THEN sales ELSE 0 END) AS Electronics,
    SUM(CASE WHEN category = 'Clothing' THEN sales ELSE 0 END) AS Clothing,
    SUM(CASE WHEN category = 'Food' THEN sales ELSE 0 END) AS Food
FROM Sales
GROUP BY month;

-- Dynamic attendance/grades pivot
SELECT 
    student_id,
    MAX(CASE WHEN subject = 'Math' THEN score END) AS Math,
    MAX(CASE WHEN subject = 'English' THEN score END) AS English,
    MAX(CASE WHEN subject = 'Science' THEN score END) AS Science
FROM Scores
GROUP BY student_id;
```

---

### 10.23 Unpivot (Columns to Rows)

**Scenario:** Transform multiple columns into rows for easier analysis.

```sql
-- Convert column-based data to rows
SELECT id, 'Q1' AS quarter, Q1 AS revenue FROM Sales
UNION ALL
SELECT id, 'Q2', Q2 FROM Sales
UNION ALL
SELECT id, 'Q3', Q3 FROM Sales
UNION ALL
SELECT id, 'Q4', Q4 FROM Sales;
```

---

### 10.24 Find Duplicates and Their Count

**Scenario:** Identify duplicate records in data quality checks.

```sql
-- Find duplicate emails with count
SELECT email, COUNT(*) AS duplicate_count
FROM Users
GROUP BY email
HAVING COUNT(*) > 1;

-- Find all records that have duplicates
SELECT *
FROM Users
WHERE email IN (
    SELECT email 
    FROM Users 
    GROUP BY email 
    HAVING COUNT(*) > 1
);
```

**📌 Reference Problems:** 196. Delete Duplicate Emails

---

### 10.25 Calculate Percentile / Median

**Scenario:** Find median salary, 90th percentile response time.

```sql
-- Median using window functions
SELECT AVG(salary) AS median_salary
FROM (
    SELECT 
        salary,
        ROW_NUMBER() OVER (ORDER BY salary) AS rn,
        COUNT(*) OVER () AS total
    FROM Employee
) t
WHERE rn IN (FLOOR((total + 1) / 2), CEIL((total + 1) / 2));

-- Percentile rank
SELECT 
    employee_id,
    salary,
    PERCENT_RANK() OVER (ORDER BY salary) AS percentile
FROM Employee;
```

---

### 10.26 Compare to Average / Benchmark

**Scenario:** Find products performing above/below category average.

```sql
-- Products with sales above their category average
SELECT p.product_id, p.product_name, p.sales, cat_avg.avg_sales
FROM Products p
JOIN (
    SELECT category_id, AVG(sales) AS avg_sales
    FROM Products
    GROUP BY category_id
) cat_avg ON p.category_id = cat_avg.category_id
WHERE p.sales > cat_avg.avg_sales;

-- Using window function
SELECT *
FROM (
    SELECT 
        product_id,
        product_name,
        sales,
        AVG(sales) OVER (PARTITION BY category_id) AS category_avg
    FROM Products
) t
WHERE sales > category_avg;
```

---

### 10.27 Customer Lifetime Value (CLV) / Total Spend

**Scenario:** Calculate total customer spend, average order value.

```sql
-- Customer lifetime metrics
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.amount) AS lifetime_value,
    ROUND(AVG(o.amount), 2) AS avg_order_value,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS last_order,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS customer_lifespan_days
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;
```

---

### 10.28 RFM Analysis (Recency, Frequency, Monetary)

**Scenario:** Segment customers based on purchase behavior.

```sql
-- RFM Scoring
WITH rfm AS (
    SELECT 
        customer_id,
        DATEDIFF('2024-01-01', MAX(order_date)) AS recency,
        COUNT(*) AS frequency,
        SUM(amount) AS monetary
    FROM Orders
    GROUP BY customer_id
)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency DESC) AS R_score,    -- Lower recency = better
    NTILE(5) OVER (ORDER BY frequency) AS F_score,       -- Higher frequency = better
    NTILE(5) OVER (ORDER BY monetary) AS M_score         -- Higher monetary = better
FROM rfm;
```

---

### 10.29 Churn Analysis (Inactive Users)

**Scenario:** Identify users who haven't been active in N days.

```sql
-- Users who haven't ordered in 90 days (churned)
SELECT 
    c.customer_id,
    c.customer_name,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURDATE(), MAX(o.order_date)) AS days_since_last_order
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING MAX(o.order_date) < DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    OR MAX(o.order_date) IS NULL;

-- Categorize by activity status
SELECT 
    customer_id,
    CASE 
        WHEN days_inactive <= 30 THEN 'Active'
        WHEN days_inactive <= 90 THEN 'At Risk'
        WHEN days_inactive <= 180 THEN 'Dormant'
        ELSE 'Churned'
    END AS status
FROM (
    SELECT 
        customer_id,
        DATEDIFF(CURDATE(), MAX(order_date)) AS days_inactive
    FROM Orders
    GROUP BY customer_id
) t;
```

---

### 10.30 A/B Test Analysis

**Scenario:** Compare conversion rates between control and test groups.

```sql
-- A/B Test conversion comparison
SELECT 
    test_group,
    COUNT(*) AS total_users,
    SUM(CASE WHEN converted = 1 THEN 1 ELSE 0 END) AS conversions,
    ROUND(100.0 * SUM(converted) / COUNT(*), 2) AS conversion_rate
FROM ABTest
GROUP BY test_group;

-- Statistical significance (simplified)
WITH stats AS (
    SELECT 
        test_group,
        COUNT(*) AS n,
        AVG(converted) AS rate,
        STDDEV(converted) AS std_dev
    FROM ABTest
    GROUP BY test_group
)
SELECT 
    a.rate AS control_rate,
    b.rate AS test_rate,
    b.rate - a.rate AS lift,
    ROUND(100.0 * (b.rate - a.rate) / a.rate, 2) AS lift_percentage
FROM stats a, stats b
WHERE a.test_group = 'control' AND b.test_group = 'test';
```

---

### 10.31 Time Zone Conversion

**Scenario:** Convert timestamps between time zones for global reporting.

```sql
-- Convert UTC to specific timezone
SELECT 
    order_id,
    order_time_utc,
    CONVERT_TZ(order_time_utc, '+00:00', '+08:00') AS order_time_taipei,
    CONVERT_TZ(order_time_utc, '+00:00', '-05:00') AS order_time_new_york
FROM Orders;
```

---

### 10.32 Business Hours Calculation

**Scenario:** Calculate working hours/days excluding weekends.

```sql
-- Filter to business hours only (9 AM - 6 PM, Mon-Fri)
SELECT *
FROM Events
WHERE DAYOFWEEK(event_time) BETWEEN 2 AND 6  -- Mon=2, Fri=6
  AND HOUR(event_time) BETWEEN 9 AND 17;

-- Count business days between two dates
SELECT 
    5 * (DATEDIFF(end_date, start_date) DIV 7) +
    CASE 
        WHEN DAYOFWEEK(start_date) <= DAYOFWEEK(end_date)
        THEN GREATEST(0, LEAST(5, DAYOFWEEK(end_date) - 1) - GREATEST(0, DAYOFWEEK(start_date) - 2))
        ELSE 5 - GREATEST(0, DAYOFWEEK(start_date) - 2) + GREATEST(0, LEAST(5, DAYOFWEEK(end_date) - 1))
    END AS business_days
FROM Projects;
```

---

### 10.33 Subscription / Recurring Revenue

**Scenario:** Calculate MRR (Monthly Recurring Revenue), track subscription status.

```sql
-- Monthly Recurring Revenue
SELECT 
    DATE_FORMAT(billing_date, '%Y-%m') AS month,
    SUM(CASE WHEN plan_type = 'monthly' THEN amount ELSE amount / 12 END) AS MRR
FROM Subscriptions
WHERE status = 'active'
GROUP BY DATE_FORMAT(billing_date, '%Y-%m');

-- Active subscriptions at a point in time
SELECT COUNT(*) AS active_subscriptions
FROM Subscriptions
WHERE start_date <= '2024-01-15'
  AND (end_date IS NULL OR end_date > '2024-01-15');
```

---

### 10.34 Geographic Analysis (Distance Calculation)

**Scenario:** Find nearby stores, calculate distance between coordinates.

```sql
-- Haversine formula for distance (km)
SELECT 
    store_id,
    store_name,
    (6371 * ACOS(
        COS(RADIANS(user_lat)) * COS(RADIANS(store_lat)) * 
        COS(RADIANS(store_lng) - RADIANS(user_lng)) +
        SIN(RADIANS(user_lat)) * SIN(RADIANS(store_lat))
    )) AS distance_km
FROM Stores
CROSS JOIN (SELECT 25.0330 AS user_lat, 121.5654 AS user_lng) user_loc
HAVING distance_km <= 5
ORDER BY distance_km;
```

---

### 10.35 Recommendation System (Users Who Bought X Also Bought Y)

**Scenario:** Find frequently bought together products.

```sql
-- Products frequently bought together
SELECT 
    o1.product_id AS product_a,
    o2.product_id AS product_b,
    COUNT(*) AS co_purchase_count
FROM OrderItems o1
JOIN OrderItems o2 ON o1.order_id = o2.order_id AND o1.product_id < o2.product_id
GROUP BY o1.product_id, o2.product_id
ORDER BY co_purchase_count DESC
LIMIT 10;

-- Users who bought product A also bought
SELECT 
    product_id,
    COUNT(DISTINCT user_id) AS buyer_count
FROM Orders
WHERE user_id IN (
    SELECT DISTINCT user_id 
    FROM Orders 
    WHERE product_id = 123  -- Product A
)
AND product_id != 123
GROUP BY product_id
ORDER BY buyer_count DESC;
```

---

## 11. SQL Traps & Gotchas (面試陷阱題)

> ⚠️ These subtle differences can make or break your interview. Master these to avoid common mistakes!

### Quick Reference: Common Traps

| Trap | Wrong | Correct | Why |
|------|-------|---------|-----|
| NULL comparison | `col != 'X'` | `col != 'X' OR col IS NULL` | NULL != 'X' returns NULL, not TRUE |
| UNION vs UNION ALL | Using UNION ALL when duplicates matter | UNION for distinct results | UNION ALL keeps duplicates |
| COUNT(*) vs COUNT(col) | Using interchangeably | Know the difference | COUNT(col) excludes NULL |
| BETWEEN inclusivity | Assuming exclusive | Know it's inclusive | BETWEEN 1 AND 3 includes 1 and 3 |
| GROUP BY with SELECT | SELECT non-aggregated columns | Only SELECT grouped/aggregated cols | SQL standard requirement |
| Division by zero | `a / b` | `a / NULLIF(b, 0)` | Avoid runtime errors |

---

### 11.1 UNION vs UNION ALL ⚠️ High Frequency

**The Difference:**
- `UNION`: Removes duplicates (slower, implicit DISTINCT)
- `UNION ALL`: Keeps all rows including duplicates (faster)

```sql
-- Example data:
-- Table A: (1), (2), (3)
-- Table B: (2), (3), (4)

SELECT * FROM A UNION SELECT * FROM B;
-- Result: 1, 2, 3, 4 (4 rows - duplicates removed)

SELECT * FROM A UNION ALL SELECT * FROM B;
-- Result: 1, 2, 3, 2, 3, 4 (6 rows - all kept)
```

**When you MUST use UNION (not UNION ALL):**

```sql
-- ❌ WRONG: Friend count with UNION ALL double-counts mutual friendships
SELECT id, COUNT(*) AS friend_count
FROM (
    SELECT requester_id AS id FROM Friendships
    UNION ALL  -- WRONG if same pair appears twice!
    SELECT accepter_id AS id FROM Friendships
) t
GROUP BY id;

-- ✅ Scenario where UNION ALL is correct: counting ALL appearances
-- (e.g., when requester_id and accepter_id are guaranteed unique pairs)
```

**When you MUST use UNION ALL (not UNION):**

```sql
-- Scenario: Combine results that SHOULD have duplicates
-- Movie with highest avg rating + User who rated the most
-- These could be the same name, and that's valid!

(SELECT name FROM ... ORDER BY avg_rating DESC LIMIT 1)
UNION ALL  -- Must use ALL - same name in both is valid!
(SELECT name FROM ... ORDER BY rating_count DESC LIMIT 1);
```

**📌 Reference Problems:** 
- 1341. Movie Rating (UNION ALL needed - same person could win both)
- 602. Friend Requests II (UNION ALL for counting both directions)

---

### 11.2 NULL Handling Traps ⚠️ Most Common Trap

**Trap 1: NULL in WHERE comparisons**

```sql
-- Table: Customer (id, referee_id)
-- Data: (1, NULL), (2, 2), (3, 1), (4, NULL)
-- Find customers NOT referred by id=2

-- ❌ WRONG: Misses NULL values!
SELECT * FROM Customer WHERE referee_id != 2;
-- Returns: (3, 1) -- Missing (1, NULL) and (4, NULL)!

-- ✅ CORRECT: Handle NULL explicitly
SELECT * FROM Customer WHERE referee_id != 2 OR referee_id IS NULL;
-- Returns: (1, NULL), (3, 1), (4, NULL)
```

**Trap 2: NULL in NOT IN subquery**

```sql
-- ❌ DANGEROUS: If subquery contains NULL, returns NO rows!
SELECT * FROM A WHERE id NOT IN (SELECT id FROM B);
-- If B contains NULL, this returns EMPTY!

-- ✅ CORRECT: Use NOT EXISTS
SELECT * FROM A 
WHERE NOT EXISTS (SELECT 1 FROM B WHERE B.id = A.id);

-- ✅ Or filter NULLs in subquery
SELECT * FROM A WHERE id NOT IN (SELECT id FROM B WHERE id IS NOT NULL);
```

**Trap 3: NULL in aggregations**

```sql
-- COUNT(*) vs COUNT(column)
-- Data: (1, 'A'), (2, NULL), (3, 'B')

SELECT COUNT(*) FROM t;        -- Returns 3 (counts all rows)
SELECT COUNT(name) FROM t;     -- Returns 2 (excludes NULL)
SELECT COUNT(DISTINCT name) FROM t;  -- Returns 2 (excludes NULL)

-- AVG ignores NULL
SELECT AVG(value) FROM t;  -- Only averages non-NULL values
```

**Trap 4: NULL in CASE WHEN**

```sql
-- ❌ WRONG: NULL won't match
CASE status WHEN NULL THEN 'Unknown' END  -- Never matches!

-- ✅ CORRECT: Use IS NULL
CASE WHEN status IS NULL THEN 'Unknown' ELSE status END
```

**📌 Reference Problems:** 584. Find Customer Referee, 577. Employee Bonus

---

### 11.3 COUNT Variations ⚠️ Tricky in Interviews

```sql
-- Given: Employee table with some NULL bonus values
-- Data: (1, 'Alice', 1000), (2, 'Bob', NULL), (3, 'Carol', 500)

SELECT 
    COUNT(*) AS total_rows,           -- 3
    COUNT(bonus) AS non_null_bonus,   -- 2 (excludes NULL)
    COUNT(DISTINCT bonus) AS unique_bonuses,  -- 2 (1000, 500)
    SUM(CASE WHEN bonus IS NULL THEN 1 ELSE 0 END) AS null_count  -- 1
FROM Employee;
```

**Trap: Using wrong COUNT for percentage calculations**

```sql
-- Calculate percentage of confirmed actions
-- ❌ WRONG: Dividing wrong counts
SELECT user_id,
       COUNT(CASE WHEN action = 'confirmed' THEN 1 END) / COUNT(*) AS rate
FROM Actions
GROUP BY user_id;

-- ✅ CORRECT: Be explicit about what you're counting
SELECT user_id,
       ROUND(
           SUM(CASE WHEN action = 'confirmed' THEN 1 ELSE 0 END) * 1.0 / 
           COUNT(*)
       , 2) AS rate
FROM Actions
GROUP BY user_id;
```

**📌 Reference Problems:** 1934. Confirmation Rate

---

### 11.4 BETWEEN Inclusivity Trap

```sql
-- BETWEEN is INCLUSIVE on both ends!
SELECT * FROM Orders WHERE amount BETWEEN 100 AND 200;
-- Equivalent to: amount >= 100 AND amount <= 200
-- INCLUDES 100 and 200!

-- Date BETWEEN trap
SELECT * FROM Events WHERE event_date BETWEEN '2024-01-01' AND '2024-01-31';
-- ⚠️ If event_date has time component, '2024-01-31 15:00:00' is EXCLUDED
-- because '2024-01-31 15:00:00' > '2024-01-31 00:00:00'

-- ✅ CORRECT for dates with time:
SELECT * FROM Events 
WHERE event_date >= '2024-01-01' AND event_date < '2024-02-01';
```

---

### 11.5 GROUP BY Traps

**Trap 1: Selecting non-aggregated columns**

```sql
-- ❌ WRONG: Which name will MySQL pick? Undefined behavior!
SELECT department_id, name, MAX(salary)
FROM Employees
GROUP BY department_id;

-- ✅ CORRECT: Use window function or subquery
SELECT department_id, name, salary
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
    FROM Employees
) t
WHERE rn = 1;
```

**Trap 2: HAVING vs WHERE confusion**

```sql
-- ❌ WRONG: Can't use aggregate in WHERE
SELECT department_id, COUNT(*)
FROM Employees
WHERE COUNT(*) > 5  -- ERROR!
GROUP BY department_id;

-- ✅ CORRECT: Use HAVING for aggregate conditions
SELECT department_id, COUNT(*)
FROM Employees
GROUP BY department_id
HAVING COUNT(*) > 5;

-- ⚡ Performance tip: Filter in WHERE when possible (before grouping)
-- ❌ Slower
SELECT department_id, COUNT(*)
FROM Employees
GROUP BY department_id
HAVING department_id != 'HR';

-- ✅ Faster
SELECT department_id, COUNT(*)
FROM Employees
WHERE department_id != 'HR'
GROUP BY department_id;
```

**📌 Reference Problems:** 596. Classes With at Least 5 Students

---

### 11.6 JOIN Traps

**Trap 1: INNER JOIN losing data**

```sql
-- Find all employees and their bonus (some may not have bonus)
-- ❌ WRONG: Loses employees without bonus
SELECT e.name, b.amount
FROM Employees e
INNER JOIN Bonus b ON e.id = b.employee_id;

-- ✅ CORRECT: Use LEFT JOIN to keep all employees
SELECT e.name, COALESCE(b.amount, 0) AS amount
FROM Employees e
LEFT JOIN Bonus b ON e.id = b.employee_id;
```

**Trap 2: Duplicate rows from JOIN**

```sql
-- If relationship is one-to-many, JOIN creates duplicates
-- Employee (id=1) has 3 orders → 3 rows after JOIN

-- ✅ Use DISTINCT or aggregate to handle duplicates
SELECT DISTINCT e.name FROM Employees e JOIN Orders o ON e.id = o.employee_id;
-- Or
SELECT e.name, COUNT(o.id) AS order_count
FROM Employees e JOIN Orders o ON e.id = o.employee_id
GROUP BY e.id, e.name;
```

**Trap 3: Self-join comparison direction**

```sql
-- Find employees earning more than their manager
-- ❌ WRONG direction
SELECT e.name
FROM Employees e
JOIN Employees m ON e.id = m.manager_id  -- Wrong! This finds managers
WHERE e.salary > m.salary;

-- ✅ CORRECT: e.manager_id = m.id (employee's manager)
SELECT e.name
FROM Employees e
JOIN Employees m ON e.manager_id = m.id
WHERE e.salary > m.salary;
```

**📌 Reference Problems:** 577. Employee Bonus, 181. Employees Earning More Than Their Managers

---

### 11.7 Date Function Traps

**Trap 1: DATEDIFF argument order**

```sql
-- MySQL: DATEDIFF(date1, date2) = date1 - date2
SELECT DATEDIFF('2024-01-15', '2024-01-10');  -- Returns 5
SELECT DATEDIFF('2024-01-10', '2024-01-15');  -- Returns -5

-- ⚠️ Different databases have different argument orders!
-- SQL Server: DATEDIFF(unit, start, end)
```

**Trap 2: DATE vs DATETIME comparison**

```sql
-- If column is DATETIME, comparing to DATE can miss records
-- ❌ WRONG: Misses '2024-01-15 08:30:00'
SELECT * FROM Events WHERE event_time = '2024-01-15';

-- ✅ CORRECT: Use DATE() or range
SELECT * FROM Events WHERE DATE(event_time) = '2024-01-15';
-- Or (better for index usage)
SELECT * FROM Events 
WHERE event_time >= '2024-01-15' AND event_time < '2024-01-16';
```

**Trap 3: Adding days to find "next day"**

```sql
-- ❌ WRONG: Adding 1 directly doesn't work
SELECT * FROM Logs WHERE date = date + 1;  -- Syntax error or wrong logic

-- ✅ CORRECT: Use DATE_ADD or INTERVAL
SELECT * FROM Logs WHERE date = DATE_ADD(other_date, INTERVAL 1 DAY);
-- Or for comparison
SELECT a.* FROM Logs a JOIN Logs b ON a.date = DATE_ADD(b.date, INTERVAL 1 DAY);
```

**📌 Reference Problems:** 197. Rising Temperature

---

### 11.8 Subquery Traps

**Trap 1: Returning multiple rows when scalar expected**

```sql
-- ❌ ERROR: Subquery returns more than 1 row
SELECT * FROM Employees WHERE salary > (SELECT salary FROM Employees WHERE dept = 'IT');

-- ✅ CORRECT: Use aggregate or ANY/ALL
SELECT * FROM Employees WHERE salary > (SELECT MAX(salary) FROM Employees WHERE dept = 'IT');
SELECT * FROM Employees WHERE salary > ALL (SELECT salary FROM Employees WHERE dept = 'IT');
```

**Trap 2: Empty subquery result**

```sql
-- What if no employees in IT department?
SELECT * FROM Employees WHERE salary > (SELECT MAX(salary) FROM Employees WHERE dept = 'IT');
-- Returns NOTHING because NULL comparison

-- ✅ CORRECT: Handle NULL case
SELECT * FROM Employees 
WHERE salary > COALESCE((SELECT MAX(salary) FROM Employees WHERE dept = 'IT'), 0);
```

**Trap 3: Correlated vs Non-correlated performance**

```sql
-- ❌ SLOW: Correlated subquery runs for EACH row
SELECT e.name, e.salary,
    (SELECT AVG(salary) FROM Employees WHERE dept = e.dept) AS dept_avg
FROM Employees e;

-- ✅ FASTER: Join with subquery result
SELECT e.name, e.salary, d.dept_avg
FROM Employees e
JOIN (
    SELECT dept, AVG(salary) AS dept_avg FROM Employees GROUP BY dept
) d ON e.dept = d.dept;
```

---

### 11.9 ORDER BY Traps

**Trap 1: ORDER BY in subquery is ignored**

```sql
-- ❌ ORDER BY inside subquery/view is often ignored
SELECT * FROM (
    SELECT * FROM Products ORDER BY price DESC
) t
LIMIT 10;  -- Order NOT guaranteed!

-- ✅ CORRECT: ORDER BY in outermost query
SELECT * FROM (
    SELECT * FROM Products
) t
ORDER BY price DESC
LIMIT 10;
```

**Trap 2: ORDER BY with UNION**

```sql
-- ❌ WRONG: ORDER BY applies only to last SELECT
SELECT name FROM A ORDER BY name
UNION
SELECT name FROM B;  -- ORDER BY is ignored!

-- ✅ CORRECT: Wrap in subquery or use at end
SELECT * FROM (
    SELECT name FROM A
    UNION
    SELECT name FROM B
) t
ORDER BY name;
```

**Trap 3: NULL sorting behavior**

```sql
-- NULLs sort first (ASC) or last (DESC) depending on database
-- MySQL: NULLs are considered lowest values

SELECT * FROM Products ORDER BY price ASC;   -- NULLs first
SELECT * FROM Products ORDER BY price DESC;  -- NULLs last

-- ✅ Explicit control:
SELECT * FROM Products ORDER BY price IS NULL, price ASC;  -- NULLs last in ASC
```

---

### 11.10 LIMIT / OFFSET Traps

**Trap 1: Second highest without handling ties/nulls**

```sql
-- Find second highest salary
-- ❌ WRONG: Fails if duplicate highest or less than 2 rows
SELECT salary FROM Employees ORDER BY salary DESC LIMIT 1 OFFSET 1;

-- ✅ CORRECT: Use DISTINCT and handle empty result
SELECT (
    SELECT DISTINCT salary FROM Employees ORDER BY salary DESC LIMIT 1 OFFSET 1
) AS SecondHighestSalary;  -- Returns NULL if doesn't exist
```

**Trap 2: OFFSET is 0-indexed**

```sql
-- OFFSET 0 = first row (same as no offset)
-- OFFSET 1 = skip first row, start from second
SELECT * FROM t LIMIT 5 OFFSET 0;  -- Rows 1-5
SELECT * FROM t LIMIT 5 OFFSET 5;  -- Rows 6-10
```

**📌 Reference Problems:** 176. Second Highest Salary

---

### 11.11 String Comparison Traps

**Trap 1: Case sensitivity**

```sql
-- MySQL default (utf8_general_ci) is case-INSENSITIVE
SELECT * FROM Users WHERE name = 'john';  -- Matches 'John', 'JOHN'

-- ✅ Force case-sensitive comparison
SELECT * FROM Users WHERE BINARY name = 'john';  -- Only matches 'john'
SELECT * FROM Users WHERE name COLLATE utf8_bin = 'john';
```

**Trap 2: Trailing spaces**

```sql
-- MySQL ignores trailing spaces in CHAR comparisons!
SELECT 'abc' = 'abc  ';  -- Returns 1 (true) in MySQL!

-- ✅ Use LIKE or explicit length check
SELECT * FROM t WHERE name LIKE 'abc';  -- No trailing space match
SELECT * FROM t WHERE name = 'abc' AND LENGTH(name) = 3;
```

**Trap 3: LIKE wildcard escaping**

```sql
-- Find strings containing '%' or '_'
-- ❌ WRONG: % and _ are wildcards
SELECT * FROM t WHERE text LIKE '%10% off%';  -- Matches too much!

-- ✅ CORRECT: Escape wildcards
SELECT * FROM t WHERE text LIKE '%10\% off%' ESCAPE '\';
```

---

### 11.12 Division and Rounding Traps

**Trap 1: Integer division**

```sql
-- ❌ WRONG: Integer division truncates
SELECT 5 / 2;  -- Returns 2 in some databases, 2.5 in others

-- ✅ CORRECT: Force decimal
SELECT 5 / 2.0;
SELECT 5 * 1.0 / 2;
SELECT CAST(5 AS DECIMAL) / 2;
```

**Trap 2: Division by zero**

```sql
-- ❌ ERROR or returns NULL
SELECT 100 / 0;

-- ✅ CORRECT: Use NULLIF
SELECT 100 / NULLIF(divisor, 0) FROM t;  -- Returns NULL if divisor is 0
```

**Trap 3: ROUND precision**

```sql
-- ROUND(x, n) rounds to n decimal places
SELECT ROUND(3.14159, 2);  -- 3.14
SELECT ROUND(3.145, 2);    -- 3.15 or 3.14? (Depends on banker's rounding!)

-- ✅ For consistent results, consider TRUNCATE
SELECT TRUNCATE(3.149, 2);  -- Always 3.14
```

**📌 Reference Problems:** 1211. Queries Quality and Percentage, 1193. Monthly Transactions I

---

### 11.13 DISTINCT Traps

**Trap 1: DISTINCT applies to entire row**

```sql
-- DISTINCT applies to ALL selected columns together
SELECT DISTINCT col1, col2 FROM t;
-- Returns unique combinations of (col1, col2), not unique col1 and unique col2

-- If you want unique col1 with any col2:
SELECT col1, MAX(col2) FROM t GROUP BY col1;
```

**Trap 2: DISTINCT with ORDER BY**

```sql
-- ❌ ERROR in strict SQL: ORDER BY column must be in SELECT
SELECT DISTINCT category FROM Products ORDER BY price;  -- Error!

-- ✅ CORRECT: Include in SELECT or use subquery
SELECT DISTINCT category FROM Products ORDER BY category;
-- Or
SELECT category FROM (
    SELECT category, MIN(price) AS min_price FROM Products GROUP BY category
) t ORDER BY min_price;
```

---

### 11.14 Ranking Function Traps

**Trap: RANK vs DENSE_RANK vs ROW_NUMBER**

```sql
-- Data: Scores 100, 100, 90, 80
-- ROW_NUMBER(): 1, 2, 3, 4 (always unique)
-- RANK():       1, 1, 3, 4 (ties get same rank, next rank skipped)
-- DENSE_RANK(): 1, 1, 2, 3 (ties get same rank, no skip)

-- ❌ Using wrong function for "top 3"
-- If you use RANK() and top 2 are tied, 3rd place is rank 3
-- If you use DENSE_RANK() and top 2 are tied, you get 3 people

-- Question asks "top 3 salaries" (unique salary values) → DENSE_RANK
-- Question asks "top 3 employees" (exactly 3 people) → ROW_NUMBER
```

**📌 Reference Problems:** 185. Department Top Three Salaries

---

### 11.15 EXISTS vs IN Performance Trap

```sql
-- IN: Evaluates subquery completely, then checks membership
-- EXISTS: Stops at first match (can be faster)

-- When to use IN:
-- - Small subquery result set
-- - Need to match against specific values

-- When to use EXISTS:
-- - Large subquery result set
-- - Just need to check existence
-- - Subquery has NULL values (see NULL trap above)

-- ❌ SLOW for large subqueries
SELECT * FROM Orders WHERE customer_id IN (SELECT id FROM Customers WHERE country = 'US');

-- ✅ FASTER for large tables
SELECT * FROM Orders o WHERE EXISTS (
    SELECT 1 FROM Customers c WHERE c.id = o.customer_id AND c.country = 'US'
);
```

---

### Summary: Interview Trap Checklist

Before submitting your answer, check:

| Category | Question to Ask |
|----------|-----------------|
| NULL | Did I handle NULL in WHERE/NOT IN/calculations? |
| UNION | Do I need deduplication? UNION vs UNION ALL? |
| COUNT | Am I counting rows (*) or non-null values (column)? |
| JOIN | LEFT JOIN to keep all records? Handling duplicates? |
| GROUP BY | Only selecting grouped/aggregated columns? |
| BETWEEN | Remembering it's inclusive? Date time issues? |
| DISTINCT | Understanding it applies to entire row? |
| Subquery | Will it return NULL or multiple rows? |
| Division | Handling zero divisor? Integer vs decimal? |
| ORDER BY | Is it in the right place (outermost query)? |
| RANK | Using correct ranking function for the requirement? |

---

### 11.16 Additional Traps: Edge Cases

**Trap 1: Empty Result vs NULL Result**

```sql
-- Scenario: Find second highest salary when table has only 1 row
-- ❌ WRONG: Returns empty result set
SELECT DISTINCT salary FROM Employees ORDER BY salary DESC LIMIT 1 OFFSET 1;
-- Returns: (empty)

-- ✅ CORRECT: Return NULL for "no result"
SELECT (
    SELECT DISTINCT salary FROM Employees ORDER BY salary DESC LIMIT 1 OFFSET 1
) AS SecondHighestSalary;
-- Returns: NULL

-- This matters because problem often asks for NULL, not empty!
```

**📌 Reference:** 176. Second Highest Salary

---

**Trap 2: Self-Join with Same Row Matching**

```sql
-- Scenario: Find consecutive numbers (same number appearing 3+ times in a row)
-- ❌ WRONG: May match same row with itself
SELECT DISTINCT l1.num
FROM Logs l1, Logs l2, Logs l3
WHERE l1.num = l2.num AND l2.num = l3.num;
-- This doesn't ensure consecutive IDs!

-- ✅ CORRECT: Ensure consecutive IDs
SELECT DISTINCT l1.num
FROM Logs l1
JOIN Logs l2 ON l1.id = l2.id - 1
JOIN Logs l3 ON l2.id = l3.id - 1
WHERE l1.num = l2.num AND l2.num = l3.num;
```

**📌 Reference:** 180. Consecutive Numbers

---

**Trap 3: DELETE with Self-Reference**

```sql
-- Scenario: Delete duplicate emails, keeping smallest id
-- ❌ WRONG in MySQL: Can't reference same table being deleted
DELETE FROM Person WHERE id NOT IN (
    SELECT MIN(id) FROM Person GROUP BY email
);
-- Error: You can't specify target table 'Person' for update in FROM clause

-- ✅ CORRECT: Use JOIN instead
DELETE p1 FROM Person p1
JOIN Person p2 ON p1.email = p2.email AND p1.id > p2.id;

-- ✅ Alternative: Wrap subquery
DELETE FROM Person WHERE id NOT IN (
    SELECT * FROM (SELECT MIN(id) FROM Person GROUP BY email) AS temp
);
```

**📌 Reference:** 196. Delete Duplicate Emails

---

**Trap 4: COALESCE vs IFNULL vs NVL**

```sql
-- Different databases use different NULL handling functions
-- MySQL: IFNULL(a, b) or COALESCE(a, b, c, ...)
-- SQL Server: ISNULL(a, b) or COALESCE(a, b, c, ...)
-- Oracle: NVL(a, b) or COALESCE(a, b, c, ...)

-- COALESCE returns first non-NULL value (works in all databases)
SELECT COALESCE(col1, col2, col3, 'default') FROM t;

-- Trap: IFNULL only takes 2 arguments
SELECT IFNULL(a, b, c);  -- ERROR in MySQL!
SELECT COALESCE(a, b, c); -- ✅ CORRECT
```

---

**Trap 5: Aggregate with No Rows**

```sql
-- What happens when there are no matching rows?
-- COUNT returns 0
-- SUM/AVG/MIN/MAX return NULL

SELECT COUNT(*) FROM Orders WHERE 1=0;  -- Returns 0
SELECT SUM(amount) FROM Orders WHERE 1=0;  -- Returns NULL
SELECT AVG(amount) FROM Orders WHERE 1=0;  -- Returns NULL

-- ✅ Handle in calculations
SELECT COALESCE(SUM(amount), 0) FROM Orders WHERE 1=0;  -- Returns 0
SELECT COALESCE(AVG(amount), 0) FROM Orders WHERE 1=0;  -- Returns 0
```

---

**Trap 6: Window Function in WHERE Clause**

```sql
-- ❌ WRONG: Can't use window function in WHERE
SELECT * FROM Employees 
WHERE ROW_NUMBER() OVER (ORDER BY salary DESC) <= 3;
-- Error!

-- ✅ CORRECT: Use subquery or CTE
SELECT * FROM (
    SELECT *, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM Employees
) t
WHERE rn <= 3;

-- Or with CTE
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM Employees
)
SELECT * FROM ranked WHERE rn <= 3;
```

---

**Trap 7: Multiple Conditions with OR and NULL**

```sql
-- Scenario: Find products that are either low_fats='Y' or recyclable='Y'
-- But what if one column is NULL?

-- ❌ POTENTIAL ISSUE:
SELECT * FROM Products WHERE low_fats = 'Y' OR recyclable = 'Y';
-- If low_fats is NULL, low_fats = 'Y' is NULL (not FALSE)
-- But OR with TRUE on other side still works

-- The real trap is with AND:
SELECT * FROM Products WHERE low_fats = 'Y' AND recyclable != 'N';
-- If recyclable is NULL, recyclable != 'N' is NULL
-- And TRUE AND NULL = NULL, row excluded!

-- ✅ CORRECT: Handle NULL explicitly
SELECT * FROM Products 
WHERE low_fats = 'Y' AND (recyclable != 'N' OR recyclable IS NULL);
```

---

**Trap 8: Aliasing in Same SELECT Clause**

```sql
-- ❌ WRONG: Can't use alias defined in same SELECT
SELECT 
    price * quantity AS total,
    total * 0.1 AS tax  -- ERROR: 'total' not recognized!
FROM OrderItems;

-- ✅ CORRECT: Use subquery or repeat expression
SELECT 
    total,
    total * 0.1 AS tax
FROM (
    SELECT price * quantity AS total FROM OrderItems
) t;

-- Or repeat the calculation
SELECT 
    price * quantity AS total,
    price * quantity * 0.1 AS tax
FROM OrderItems;
```

---

**Trap 9: LIKE with NULL**

```sql
-- NULL LIKE 'pattern' returns NULL, not FALSE
SELECT * FROM Users WHERE name LIKE 'A%';
-- Rows with NULL name are excluded

-- If you want NULL names too:
SELECT * FROM Users WHERE name LIKE 'A%' OR name IS NULL;
```

---

**Trap 10: Implicit Type Conversion**

```sql
-- ❌ SLOW: Index may not be used due to type conversion
SELECT * FROM Users WHERE phone = 1234567890;  -- phone is VARCHAR
-- MySQL converts VARCHAR to INT, can't use index!

-- ✅ CORRECT: Match types
SELECT * FROM Users WHERE phone = '1234567890';

-- Same with dates:
-- ❌ WRONG
SELECT * FROM Orders WHERE DATE(created_at) = '2024-01-15';  -- Function prevents index

-- ✅ CORRECT (when possible)
SELECT * FROM Orders WHERE created_at >= '2024-01-15' AND created_at < '2024-01-16';
```

---

### 11.17 Common Mistake Patterns in LeetCode SQL

| Problem Pattern | Common Mistake | Correct Approach |
|-----------------|---------------|------------------|
| "Find X that doesn't exist in Y" | Using INNER JOIN | Use LEFT JOIN + IS NULL |
| "Second highest/Nth value" | Not handling ties or empty | Use DENSE_RANK or subquery with NULL wrapper |
| "Count per group including zero" | Missing groups with zero count | Use LEFT JOIN or CROSS JOIN |
| "Compare with previous row" | Using wrong self-join condition | Ensure proper id-1 or LAG() |
| "Calculate percentage" | Integer division | Multiply by 100.0 first |
| "Find records with all/any" | Confusing logic | Use HAVING COUNT = (SELECT COUNT) for "all" |
| "Combine two results" | Using UNION when both should appear | Use UNION ALL if same value is valid |

---

## 12. Common Patterns & Tricks

### 10.1 Find Second/Nth Highest Value

```sql
-- Method 1: LIMIT OFFSET
SELECT DISTINCT salary
FROM Employee
ORDER BY salary DESC
LIMIT 1 OFFSET 1;

-- Method 2: Subquery (handles no result case)
SELECT MAX(salary) AS SecondHighestSalary
FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);

-- Method 3: Window Function
SELECT salary
FROM (
    SELECT salary, DENSE_RANK() OVER (ORDER BY salary DESC) AS rnk
    FROM Employee
) ranked
WHERE rnk = 2;
```

**📌 Reference Problems:** 176. Second Highest Salary

---

### 10.2 Find Records with MAX in Each Group

```sql
-- Method 1: Subquery
SELECT *
FROM Sales
WHERE (product_id, year) IN (
    SELECT product_id, MIN(year)
    FROM Sales
    GROUP BY product_id
);

-- Method 2: Window Function
SELECT product_id, year, quantity, price
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY year) AS rn
    FROM Sales
) t
WHERE rn = 1;
```

**📌 Reference Problems:** 1070. Product Sales Analysis III

---

### 10.3 Handle "Return NULL if No Result"

```sql
-- Wrap in subquery to return NULL instead of empty
SELECT (
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;
```

---

### 10.4 Delete Duplicates (Keep One)

```sql
-- Delete duplicate emails, keeping the smallest id
DELETE p1
FROM Person p1
JOIN Person p2 ON p1.email = p2.email
WHERE p1.id > p2.id;
```

**📌 Reference Problems:** 196. Delete Duplicate Emails

---

### 10.5 Swap Values / Exchange Seats

```sql
-- Swap adjacent rows (odd ↔ even)
SELECT 
    CASE 
        WHEN id % 2 = 1 AND id = (SELECT MAX(id) FROM Seat) THEN id
        WHEN id % 2 = 1 THEN id + 1
        ELSE id - 1
    END AS id,
    student
FROM Seat
ORDER BY id;
```

**📌 Reference Problems:** 626. Exchange Seats

---

### 10.6 Cumulative Sum with Condition

```sql
-- Find last person that fits in elevator (cumulative weight ≤ 1000)
SELECT person_name
FROM (
    SELECT person_name,
           SUM(weight) OVER (ORDER BY turn) AS cumulative_weight
    FROM Queue
) t
WHERE cumulative_weight <= 1000
ORDER BY cumulative_weight DESC
LIMIT 1;
```

**📌 Reference Problems:** 1204. Last Person to Fit in the Bus

---

### 10.7 Find Customers Who Bought ALL Products

```sql
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product);
```

**📌 Reference Problems:** 1045. Customers Who Bought All Products

---

### 10.8 Generate Categories Even When Empty

```sql
-- Use UNION to create all categories, then LEFT JOIN
SELECT 'Low Salary' AS category, 
       COUNT(CASE WHEN income < 20000 THEN 1 END) AS accounts_count
FROM Accounts
UNION
SELECT 'Average Salary', COUNT(CASE WHEN income BETWEEN 20000 AND 50000 THEN 1 END)
FROM Accounts
UNION
SELECT 'High Salary', COUNT(CASE WHEN income > 50000 THEN 1 END)
FROM Accounts;
```

**📌 Reference Problems:** 1907. Count Salary Categories

---

## 13. Interview Frequently Asked Topics

### 🔥 Top Interview Questions by Concept

| Concept | Key Problems | Difficulty |
|---------|--------------|------------|
| NULL Handling | 584, 577 | Easy |
| Self Join | 197, 180, 1731 | Medium |
| Finding Nth Highest | 176, 185 | Medium |
| Window Functions | 185, 1321 | Medium-Hard |
| Subqueries | 1978, 550 | Medium |
| Date Operations | 197, 1141 | Easy-Medium |
| String Functions | 1667, 1517 | Easy-Medium |
| Aggregation + HAVING | 596, 570 | Easy-Medium |

---

### 💡 Common Interview Questions

1. **"Find the second highest salary"** → 176
2. **"Find employees earning more than their manager"** → Related to Self Join
3. **"Find customers who never ordered"** → LEFT JOIN + IS NULL pattern
4. **"Find consecutive records"** → 180 (Self Join or Window Functions)
5. **"Calculate running total"** → Window Function with SUM() OVER
6. **"Find top N per group"** → 185 (DENSE_RANK)
7. **"Handle NULL values"** → 584, Always use IS NULL/IS NOT NULL
8. **"Delete duplicates"** → 196

---

### ⚠️ Common Mistakes to Avoid

1. **NULL comparisons with `=` or `!=`**
   - ❌ `WHERE col != value` misses NULLs
   - ✅ `WHERE col != value OR col IS NULL`

2. **Using aggregate functions in WHERE**
   - ❌ `WHERE COUNT(*) > 5`
   - ✅ `HAVING COUNT(*) > 5`

3. **Not handling empty results**
   - ❌ Query returns empty set
   - ✅ Wrap in subquery to return NULL

4. **GROUP BY with non-aggregated columns**
   - All non-aggregated columns in SELECT must be in GROUP BY

5. **DISTINCT with ORDER BY**
   - ORDER BY columns should be in SELECT when using DISTINCT

---

## 14. Problems by Category

### Select
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 1757 | Recyclable and Low Fat Products | Easy | WHERE, AND |
| 584 | Find Customer Referee | Easy | NULL handling |
| 595 | Big Countries | Easy | OR, multiple conditions |
| 1148 | Article Views I | Easy | DISTINCT, self-comparison |
| 1683 | Invalid Tweets | Easy | LENGTH() |

### Basic Joins
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 1378 | Replace Employee ID With The Unique Identifier | Easy | LEFT JOIN |
| 1068 | Product Sales Analysis I | Easy | INNER JOIN |
| 1581 | Customer Who Visited but Did Not Make Any Transactions | Easy | LEFT JOIN + IS NULL |
| 197 | Rising Temperature | Easy | Self Join, DATEDIFF |
| 1661 | Average Time of Process per Machine | Easy | Self Join |
| 577 | Employee Bonus | Easy | LEFT JOIN, NULL |
| 1280 | Students and Examinations | Medium | CROSS JOIN, LEFT JOIN |
| 570 | Managers with at Least 5 Direct Reports | Medium | Self Join, HAVING |
| 1934 | Confirmation Rate | Medium | LEFT JOIN, conditional aggregation |

### Basic Aggregate Functions
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 620 | Not Boring Movies | Easy | MOD, ORDER BY |
| 1251 | Average Selling Price | Easy | Weighted average |
| 1075 | Project Employees I | Easy | AVG, ROUND |
| 1633 | Percentage of Users Attended a Contest | Easy | COUNT, percentage |
| 1211 | Queries Quality and Percentage | Easy | AVG, conditional |
| 1193 | Monthly Transactions I | Medium | DATE_FORMAT, CASE |
| 1174 | Immediate Food Delivery II | Medium | Subquery, percentage |
| 550 | Game Play Analysis IV | Medium | Subquery, retention |

### Sorting and Grouping
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 2356 | Number of Unique Subjects Taught by Each Teacher | Easy | COUNT DISTINCT |
| 1141 | User Activity for the Past 30 Days I | Easy | Date range, GROUP BY |
| 1070 | Product Sales Analysis III | Medium | Subquery, first record |
| 596 | Classes With at Least 5 Students | Easy | HAVING |
| 1729 | Find Followers Count | Easy | GROUP BY, ORDER BY |
| 619 | Biggest Single Number | Easy | HAVING COUNT = 1 |
| 1045 | Customers Who Bought All Products | Medium | HAVING COUNT = total |

### Advanced Select and Joins
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 1731 | The Number of Employees Which Report to Each Employee | Easy | Self Join |
| 1789 | Primary Department for Each Employee | Easy | UNION / CASE |
| 610 | Triangle Judgement | Easy | CASE WHEN |
| 180 | Consecutive Numbers | Medium | Self Join |
| 1164 | Product Price at a Given Date | Medium | Subquery, COALESCE |
| 1204 | Last Person to Fit in the Bus | Medium | Window function, cumulative |
| 1907 | Count Salary Categories | Medium | UNION, categories |

### Subqueries
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 1978 | Employees Whose Manager Left the Company | Easy | NOT IN subquery |
| 626 | Exchange Seats | Medium | CASE, subquery |
| 1341 | Movie Rating | Medium | UNION, subqueries |
| 1321 | Restaurant Growth | Medium | Window function |
| 602 | Friend Requests II: Who Has the Most Friends | Medium | UNION ALL |
| 585 | Investments in 2016 | Medium | Correlated subquery |
| 176 | Second Highest Salary | Medium | Subquery, NULL handling |
| 185 | Department Top Three Salaries | Hard | DENSE_RANK, Window |

### Advanced String Functions / Regex / Clause
| # | Problem | Difficulty | Key Concept |
|---|---------|------------|-------------|
| 1667 | Fix Names in a Table | Easy | CONCAT, UPPER, LOWER |
| 1484 | Group Sold Products By The Date | Easy | GROUP_CONCAT |
| 1327 | List the Products Ordered in a Period | Easy | Date filtering |
| 196 | Delete Duplicate Emails | Easy | DELETE with JOIN |
| 1517 | Find Users With Valid E-Mails | Easy | REGEXP |
| 1527 | Patients With a Condition | Easy | LIKE / REGEXP |

---

## 15. Performance Optimization

> ⚡ Writing correct SQL is step one. Writing FAST SQL is what separates junior from senior engineers.

### 14.1 Understanding Query Execution Order

```
FROM        → Which tables to use
JOIN        → Combine tables
WHERE       → Filter rows (before grouping)
GROUP BY    → Create groups
HAVING      → Filter groups (after grouping)
SELECT      → Choose columns
DISTINCT    → Remove duplicates
ORDER BY    → Sort results
LIMIT       → Limit output rows
```

**🎯 Key Insight:** Filtering early (in WHERE) is always faster than filtering late (in HAVING or after SELECT).

---

### 14.2 Index Fundamentals

**What is an Index?**
- Like a book's index - helps find data without scanning every row
- Speeds up: WHERE, JOIN, ORDER BY, GROUP BY
- Costs: Extra storage, slower INSERT/UPDATE/DELETE

**Columns to Index:**
```sql
-- ✅ Good candidates for indexing
- Primary keys (auto-indexed)
- Foreign keys (used in JOINs)
- Columns in WHERE clauses
- Columns in ORDER BY
- Columns with high selectivity (many unique values)

-- ❌ Poor candidates
- Columns with few unique values (e.g., gender, status)
- Columns rarely used in queries
- Small tables (full scan is fast enough)
```

**Check if index is used:**
```sql
EXPLAIN SELECT * FROM Orders WHERE customer_id = 100;
-- Look for "Using index" or "ref" vs "ALL" (full table scan)
```

---

### 14.3 Query Optimization Techniques

#### 14.3.1 Use WHERE Instead of HAVING

```sql
-- ❌ SLOW: Filters after grouping
SELECT department, COUNT(*) 
FROM Employees
GROUP BY department
HAVING department != 'HR';

-- ✅ FAST: Filters before grouping
SELECT department, COUNT(*)
FROM Employees
WHERE department != 'HR'
GROUP BY department;
```

---

#### 14.3.2 Avoid SELECT *

```sql
-- ❌ SLOW: Fetches all columns
SELECT * FROM Orders WHERE status = 'pending';

-- ✅ FAST: Only fetch what you need
SELECT order_id, customer_id, amount 
FROM Orders WHERE status = 'pending';
```

**Why it matters:**
- Less data transferred
- Can use covering indexes
- Clearer intent

---

#### 14.3.3 EXISTS vs IN vs JOIN

```sql
-- Scenario: Find customers who have orders

-- Option 1: IN (loads all order customer_ids into memory)
SELECT * FROM Customers 
WHERE customer_id IN (SELECT customer_id FROM Orders);

-- Option 2: EXISTS (stops at first match - often faster)
SELECT * FROM Customers c
WHERE EXISTS (SELECT 1 FROM Orders o WHERE o.customer_id = c.customer_id);

-- Option 3: JOIN (can be fastest with proper indexes)
SELECT DISTINCT c.* 
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id;
```

**When to use what:**

| Method | Best When |
|--------|-----------|
| `IN` | Subquery returns small result set |
| `EXISTS` | Subquery returns large result set, just checking existence |
| `JOIN` | Need data from both tables, have proper indexes |

---

#### 14.3.4 Avoid Functions on Indexed Columns

```sql
-- ❌ SLOW: Function prevents index use
SELECT * FROM Orders 
WHERE YEAR(order_date) = 2024;

-- ✅ FAST: Index can be used
SELECT * FROM Orders 
WHERE order_date >= '2024-01-01' AND order_date < '2025-01-01';

-- ❌ SLOW: Function on column
SELECT * FROM Users WHERE LOWER(email) = 'test@example.com';

-- ✅ FAST: Store lowercase or use case-insensitive collation
SELECT * FROM Users WHERE email = 'test@example.com';  -- If CI collation
```

---

#### 14.3.5 Use UNION ALL Instead of UNION

```sql
-- ❌ SLOW: Removes duplicates (sorts entire result)
SELECT city FROM Customers
UNION
SELECT city FROM Suppliers;

-- ✅ FAST: Keeps duplicates (no sorting needed)
SELECT city FROM Customers
UNION ALL
SELECT city FROM Suppliers;

-- Use UNION only when you truly need deduplication
```

---

#### 14.3.6 Limit Early with Subqueries

```sql
-- ❌ SLOW: Joins everything, then limits
SELECT c.name, COUNT(o.order_id)
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
ORDER BY COUNT(o.order_id) DESC
LIMIT 10;

-- ✅ FASTER: Find top customers first, then get details
SELECT c.name, t.order_count
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM Orders
    GROUP BY customer_id
    ORDER BY order_count DESC
    LIMIT 10
) t
JOIN Customers c ON t.customer_id = c.customer_id;
```

---

#### 14.3.7 Optimize JOINs

```sql
-- ✅ Best practices for JOINs:

-- 1. Join on indexed columns
SELECT * FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;  -- Both should be indexed

-- 2. Filter before joining
SELECT * 
FROM (SELECT * FROM Orders WHERE status = 'pending') o
JOIN Customers c ON o.customer_id = c.customer_id;

-- 3. Put smaller table first (in some databases)
SELECT * FROM SmallTable s
JOIN LargeTable l ON s.id = l.small_id;
```

---

#### 14.3.8 Avoid Correlated Subqueries When Possible

```sql
-- ❌ SLOW: Runs subquery for EACH row in outer query
SELECT e.name, e.salary
FROM Employees e
WHERE e.salary > (
    SELECT AVG(salary) FROM Employees WHERE department = e.department
);

-- ✅ FAST: Calculate once, then join
SELECT e.name, e.salary
FROM Employees e
JOIN (
    SELECT department, AVG(salary) AS avg_sal
    FROM Employees
    GROUP BY department
) d ON e.department = d.department
WHERE e.salary > d.avg_sal;

-- ✅ FAST: Window function (even cleaner)
SELECT name, salary
FROM (
    SELECT name, salary, AVG(salary) OVER (PARTITION BY department) AS avg_sal
    FROM Employees
) t
WHERE salary > avg_sal;
```

---

### 14.4 Pagination Optimization

```sql
-- ❌ SLOW: OFFSET scans and discards rows
SELECT * FROM Products ORDER BY id LIMIT 10 OFFSET 10000;
-- Must scan 10,010 rows!

-- ✅ FAST: Keyset pagination (seek method)
SELECT * FROM Products 
WHERE id > 10000  -- Last seen ID
ORDER BY id 
LIMIT 10;

-- For complex sorting, use composite conditions
SELECT * FROM Products
WHERE (created_at, id) > ('2024-01-15', 500)
ORDER BY created_at, id
LIMIT 10;
```

---

### 14.5 COUNT Optimization

```sql
-- ❌ SLOW: Counts all rows
SELECT COUNT(*) FROM Orders WHERE status = 'pending';

-- ✅ FAST: If you just need "any exist?"
SELECT EXISTS(SELECT 1 FROM Orders WHERE status = 'pending');

-- ✅ For approximate counts (very large tables)
-- MySQL: 
SELECT TABLE_ROWS FROM information_schema.TABLES 
WHERE TABLE_NAME = 'Orders';
```

---

### 14.6 Batch Processing for Large Updates

```sql
-- ❌ DANGEROUS: Locks entire table, may timeout
UPDATE Orders SET status = 'archived' 
WHERE order_date < '2023-01-01';

-- ✅ SAFE: Process in batches
-- Repeat until 0 rows affected:
UPDATE Orders SET status = 'archived'
WHERE order_date < '2023-01-01' AND status != 'archived'
LIMIT 1000;
```

---

### 14.7 Query Analysis Tools

```sql
-- MySQL: Analyze query execution plan
EXPLAIN SELECT * FROM Orders WHERE customer_id = 100;

-- Extended information
EXPLAIN ANALYZE SELECT * FROM Orders WHERE customer_id = 100;

-- Show actual execution time (MySQL 8.0+)
EXPLAIN FORMAT=JSON SELECT * FROM Orders WHERE customer_id = 100;
```

**What to look for in EXPLAIN:**

| Warning Sign | Meaning | Fix |
|--------------|---------|-----|
| `type: ALL` | Full table scan | Add index on WHERE columns |
| `rows: large number` | Many rows examined | Better filtering, add index |
| `Using filesort` | Extra sorting step | Index on ORDER BY columns |
| `Using temporary` | Temp table created | Optimize GROUP BY, DISTINCT |
| `Using where` with no index | Filtering without index | Add appropriate index |

---

### 14.8 Common Anti-Patterns to Avoid

```sql
-- ❌ Anti-pattern 1: OR on different columns (can't use single index)
SELECT * FROM Orders WHERE customer_id = 100 OR product_id = 50;
-- ✅ Fix: Use UNION
SELECT * FROM Orders WHERE customer_id = 100
UNION
SELECT * FROM Orders WHERE product_id = 50;

-- ❌ Anti-pattern 2: Leading wildcard
SELECT * FROM Users WHERE name LIKE '%john%';
-- ✅ Fix: Use full-text search or search engine (Elasticsearch)

-- ❌ Anti-pattern 3: Implicit type conversion
SELECT * FROM Users WHERE phone = 1234567890;  -- phone is VARCHAR
-- ✅ Fix: Match types
SELECT * FROM Users WHERE phone = '1234567890';

-- ❌ Anti-pattern 4: SELECT DISTINCT to hide JOIN issues
SELECT DISTINCT c.* FROM Customers c JOIN Orders o ON ...;
-- ✅ Fix: Understand why duplicates occur, fix the logic

-- ❌ Anti-pattern 5: NOT IN with NULLs
SELECT * FROM A WHERE id NOT IN (SELECT id FROM B);  -- Fails if B has NULL
-- ✅ Fix: Use NOT EXISTS or handle NULLs
SELECT * FROM A WHERE NOT EXISTS (SELECT 1 FROM B WHERE B.id = A.id);
```

---

### 14.9 Performance Optimization Checklist

Before deploying any query:

- [ ] Run `EXPLAIN` - no full table scans on large tables?
- [ ] Indexes exist on `WHERE`, `JOIN`, `ORDER BY` columns?
- [ ] Using `WHERE` instead of `HAVING` where possible?
- [ ] `SELECT` only needed columns (no `SELECT *`)?
- [ ] Appropriate use of `EXISTS` vs `IN` vs `JOIN`?
- [ ] No functions on indexed columns in `WHERE`?
- [ ] `UNION ALL` instead of `UNION` when duplicates OK?
- [ ] Pagination using keyset instead of large `OFFSET`?
- [ ] Large updates done in batches?
- [ ] No implicit type conversions?

---

## 📝 Final Tips

1. **Practice SQL execution order:** FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT

2. **Think about edge cases:** NULL values, empty results, ties in ranking

3. **Choose the right tool:**
   - Simple filtering? → WHERE
   - After grouping? → HAVING
   - Row comparison? → Self JOIN or Window Functions
   - Complex logic? → Subqueries or CTEs

4. **Optimize when possible:**
   - EXISTS over IN for large datasets
   - Avoid correlated subqueries when JOIN works
   - Use indexes on columns in WHERE and JOIN conditions

---

**Happy Learning! 🚀**

*Feel free to contribute or suggest improvements!*
