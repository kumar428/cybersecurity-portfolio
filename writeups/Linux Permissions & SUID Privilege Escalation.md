# 🔐 Linux Permissions & SUID Privilege Escalation

📍 **Environment:** Kali Linux + Custom SUID binary  
🛠️ **Tools:** `ls`, `chmod`, `find`, `gcc`

---

## 🎯 What I Did Today

### 1. Decoded `ls -la` Inside Out
- Understood every part of the permission string (`-rwxr-xr-x`).
- Learned what the first character means (`-`, `d`, `l`).
- Spotted special bits: `s` for SUID/SGID, `t` for sticky bit.

### 2. `chmod` — Numeric & Symbolic Mastery
- Applied numeric modes: `750`, `4755`, `2755`, `1777`.
- Used symbolic flags: `u+s`, `g+s`, `+t`.
- Set SUID, SGID, and sticky bit on test files and directories.

### 3. SUID Binary Hunting
- Ran `find / -perm -4000 -type f 2>/dev/null` to list all SUID files.
- Identified dangerous binaries like `find`, `vim`, `bash`.

### 4. Simulated SUID Privilege Escalation
- Compiled a small C program that spawns a root shell.
- Set SUID with `chmod 4755` and executed it — immediate root access.

### 5. Reviewed Critical System File Permissions
- Checked `/etc/passwd` (should be 644).
- Checked `/etc/shadow` (should be 640 or tighter).
- Checked `/etc/sudoers` (must be 440).
- Understood how writable/readable misconfigurations lead to full compromise.

---

## 🧠 Key Takeaways

| Concept | Risk / Impact |
|---------|---------------|
| **SUID bit** | Binary runs as owner (usually root) — misconfigured ones are instant privesc |
| **SGID on directories** | New files inherit group — can leak into sensitive groups |
| **Sticky bit** | Prevents file deletion in world-writable dirs like `/tmp` |
| **Writable `/etc/passwd`** | Attacker adds UID 0 user → full root |
| **Readable `/etc/shadow`** | Exposed password hashes → cracking |
| **Writable `/etc/sudoers`** | Permanent root escalation |
| **find / -perm -4000** | First command in any privilege escalation checklist |

---

## 📸 Proof of Work

| Screenshot | Description |
|------------|-------------|
| `day06_ls_la_basics.png` | Permission strings, ownership, timestamps decoded |
| `day06_chmod_demo.png` | Numeric and symbolic permission changes |
| `day06_suid_sgid_sticky.png` | Files with SUID, SGID, and sticky bit set |
| `day06_find_suid_output.png` | SUID binaries found using `find / -perm -4000` |
| `day06_root_shell_via_suid.png` | Custom C SUID binary exploited → root shell |
| `day06_critical_perms.png` | Permissions of `/etc/passwd`, `/etc/shadow`, `/etc/sudoers` |

---
