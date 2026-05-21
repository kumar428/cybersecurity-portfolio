# 🔐 Advanced SQL Injection – Blind, Time-Based & WAF Bypass

📍 **Environment:** Kali Linux + Burp Suite + SQLmap  
🎯 **Target:** `http://192.168.x.x/index.php?id=1` 
🛠️ **Tools:** Burp Suite (Repeater, Comparer), SQLmap, tamper scripts

---

## 🎯 What I Did Today

### 1. Boolean Blind SQLi Detection
- Injected `AND 1=1` – the page loaded normally.
- Injected `AND 1=2` – the page changed (different content, missing elements).
- Used Comparer to diff the two responses and confirm the injection was being interpreted.
- This is **Boolean blind** – no visible output, but true/false conditions change the page.

### 2. Time-Based SQLi
- Injected `' AND SLEEP(5)--` (MySQL) – the response took 5+ seconds, confirming SQL execution.
- Also tested `pg_sleep` (PostgreSQL) and `WAITFOR DELAY` (MSSQL) to fingerprint the database.
- Time-based is the slowest but most reliable when no visual feedback exists.

### 3. Manual Data Extraction Principle
- Using time-based inference: `IF(SUBSTRING(database(),1,1)='a', SLEEP(5), 0)` to guess characters.
- This manual method is labour-intensive but proves deep understanding of blind SQLi.

### 4. SQLmap Automation for Blind Techniques
- Ran `sqlmap -u "http://192.168.x.x/index.php?id=1" --technique=T --dbs`.
- The tool used time-based payloads to enumerate databases, tables, and columns.
- Compared results with manual findings to confirm accuracy.

### 5. WAF Bypass with Tamper Scripts
- The target (or a simulated WAF) was blocking simple UNION/AND payloads.
- Applied SQLmap tamper scripts: `--tamper=space2comment,charencode,randomcase`.
- These modified the payloads to evade signature-based filters.
- Manually tested alternative encodings and comment obfuscation (`/**/`, `%09`, etc.).

---

## 🧠 Key Findings

| Technique | Observation | Impact |
|-----------|-------------|--------|
| **Boolean blind** | `1=1` vs `1=2` caused measurable response difference | Confirmed SQLi without visible error – can be used for data extraction |
| **Time-based** | `SLEEP(5)` caused a 5-second delay | Database user is executing arbitrary SQL – full data exposure possible |
| **SQLmap T-technique** | Successfully dumped databases using time-based inference | Automation works even when classic techniques fail |
| **Tamper scripts** | `space2comment` bypassed basic WAF | WAFs that only look for spaces or simple keywords can be evaded |
| **Manual WAF bypass** | Used comments (`/**/`) and newlines to split keywords | Understanding bypass techniques is essential for real-world pentests |

> 💡 **Core lesson:** When a web app gives no obvious error messages, blind SQLi is still possible. Boolean and time-based techniques can extract the entire database. Add a WAF, and you need tampering – but the core logic remains the same.

---

