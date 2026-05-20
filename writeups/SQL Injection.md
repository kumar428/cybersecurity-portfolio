# 🔐 SQL Injection on 192.168.x.x

**Target:** http://192.168.x.x/index.php?id=1 (internal lab)

---

## 🎯 What I Did Today

### 1. Found the Injection Point
- Added a single quote to the `id` parameter (`?id=1'`).  
- The app threw a database error — straight confirmation of SQL injection.

### 2. Bypassed Login (if a login form was present)
- Used `' OR '1'='1` in both username and password.  
- Logged in without valid credentials, bypassing authentication entirely.

### 3. Determined Number of Columns
- Applied `ORDER BY` clauses, increasing the number until an error appeared.  
- Found the exact column count — the first step for a `UNION` attack.

### 4. Extracted Data via UNION
- Crafted `?id=-1 UNION SELECT 1,database(),3--` and got the database name.  
- Enumerated tables and columns from `information_schema`.  
- Dumped user credentials with `CONCAT(username,':',password)`.

### 5. Validated with sqlmap 
- Ran `sqlmap -u "http://192.168.x.x/index.php?id=1" --dbs` — it mirrored my manual findings.  
- Used `--tables`, `--columns`, `--dump` to speed up evidence collection.

---

## 🧠 Key Findings

| Step | Observation | Impact |
|------|-------------|--------|
| **Error triggered** | Single quote caused SQL error | Unsanitised input — open door for SQLi |
| **Login bypass** | `' OR '1'='1` logged straight in | No authentication required |
| **UNION extraction** | Database structure + user data leaked | Full data exposure, password cracking possible |
| **Automation** | sqlmap confirmed manual results | In a real test, both manual & tool evidence are needed |

---

## 💡 Core Takeaway
SQL injection still thrives where developers concatenate user input into queries. A single quote gave me the entire database. Prepared statements would have stopped me instantly — there’s no excuse in 2026.
