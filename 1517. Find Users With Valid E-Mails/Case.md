# 📧 SQL Case Study: Find Users With Valid E-mails
> **Category:** Data Validation / Regular Expression  
> **Difficulty:** Easy  
> **Tags:** `SQL`, `REGEXP`, `Pattern Matching`

## 1. Problem Description
**Goal:** Find users whose emails satisfy a specific, complex format validation.

**Validation Rules:**
1.  **Prefix:**
    * Must **start with a letter** (upper or lower case).
    * Can contain: letters, digits, underscore `_`, period `.`, or dash `-`.
2.  **Domain:**
    * Must be exactly `@leetcode.com`.

### Table `Users`
| Column Name | Type | Description |
| :--- | :--- | :--- |
| `user_id` | int | Primary Key |
| `name` | varchar | User Name |
| `mail` | varchar | User Email |

### Example Input
| user_id | name | mail |
| :--- | :--- | :--- |
| 1 | Winston | winston@leetcode.com |
| 2 | Jonathan | jonathanisgreat |
| 3 | Annabelle | bella-@leetcode.com |
| 4 | Sally | sally.come@leetcode.com |
| 5 | Marwan | quarz#2020@leetcode.com |
| 6 | David | david69@gmail.com |
| 7 | Shapiro | .shapo@leetcode.com |

### Expected Output
| user_id | name | mail |
| :--- | :--- | :--- |
| 1 | Winston | winston@leetcode.com |
| 3 | Annabelle | bella-@leetcode.com |
| 4 | Sally | sally.come@leetcode.com |

**Explanation:**
* **User 2:** No domain. (Fail)
* **User 5:** Contains `#` (invalid char). (Fail)
* **User 6:** Domain is `@gmail.com` (wrong domain). (Fail)
* **User 7:** Starts with `.` (must start with letter). (Fail)

---

## 💡 Thought Process

### 1. Why `LIKE` is not enough
The standard `LIKE` operator is too simple.
* `LIKE 'a%@leetcode.com'` can check the start and end.
* However, `LIKE` cannot ensure that the *middle* characters are **only** letters, digits, `_`, `.`, or `-`. It cannot forbid special characters like `#` or `!`.

### 2. Regex Construction (MySQL)
We need to build a pattern `REGEXP 'pattern'`. Let's break it down:

* **Start of String:** `^`
* **First Character (Letter):** `[a-zA-Z]`
* **Subsequent Characters (Allowed set):** `[a-zA-Z0-9_.-]*`
    * `*` means "zero or more times".
    * Note: The dash `-` is usually placed at the end of the brackets or escaped to avoid being interpreted as a range (like `a-z`).
* **The Domain:** `@leetcode[.]com`
    * We match `@leetcode`.
    * We match the dot `.`. Since `.` is a special wildcard in Regex (matching any char), we must treat it as a literal. We can use `\.` (escaped) or `[.]` (inside brackets).
    * We match `com`.
* **End of String:** `$`

**Combined Pattern:**
`^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode[.]com$`

---

## 2. Solutions & Implementation

### ✅ Approach: MySQL REGEXP
This uses MySQL's regular expression support to validate the entire string in one go.

```sql
SELECT 
    user_id, 
    name, 
    mail
FROM 
    Users
WHERE 
    mail REGEXP '^[a-zA-Z][a-zA-Z0-9_.-]*@leetcode[.]com$';
```

---

## 3. 🔍 Deep Dive

#### 1. Regex Symbol Cheat Sheet
| Symbol | Meaning |
| :--- | :--- |
| `^` | **Start** of the string. Ensures nothing comes before our pattern. |
| `$` | **End** of the string. Ensures nothing comes after `.com`. |
| `[]` | **Character Class**. Matches any *one* character inside. |
| `a-z` | Range: Any lowercase letter. |
| `0-9` | Range: Any digit. |
| `*` | **Quantifier**. Matches the previous element 0 or more times. |
| `.` | **Literal Dot**. When inside `[]` or escaped `\.`, it matches a real dot. Otherwise, it's a wildcard. |

#### 2. The importance of Anchors (`^` and `$`)
* If we omit `^`: `quarz#2020@leetcode.com` might match if the engine ignores the invalid start.
* If we omit `$`: `winston@leetcode.com.fake` would match because it *contains* the valid pattern.
* Anchors ensure the **entire** string matches the rules strictly.

---

## 4. ⏱️ Time Complexity Analysis

Let $N$ be the number of rows and $L$ be the average length of an email.

| Phase | Operation | Complexity | Note |
| :--- | :--- | :--- | :--- |
| **1. Scanning** | `REGEXP` | $O(N \times L)$ | The database must parse the regex state machine for every character of every email. |

**Performance Note:** Regex in SQL is powerful but generally slower than simple comparison operators. Use it only when necessary (like complex format validation).
