# 📈 SQL Challenge: Rising Temperature Analysis
> **Category:** Data Analysis / Self-Join  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `MySQL`, `Date Manipulation`, `Self-Join`

## 1. Problem Description (問題描述)
**Goal:** Write a solution to find all dates' `id` with higher temperatures compared to its previous dates (yesterday).

### Schema: `Weather` Table
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `id` | int | Primary Key (Unique value) |
| `recordDate` | date | The date of the weather record |
| `temperature` | int | The temperature on that day |

*Note: There are no different rows with the same recordDate.*

### Example Input
| id | recordDate | temperature |
| :--- | :--- | :--- |
| 1 | 2015-01-01 | 10 |
| 2 | 2015-01-02 | 25 |
| 3 | 2015-01-03 | 20 |
| 4 | 2015-01-04 | 30 |

### Expected Output
| id |
| :--- |
| 2 |
| 4 |

---
