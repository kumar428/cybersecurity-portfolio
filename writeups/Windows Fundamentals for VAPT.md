# 🔐 Windows Fundamentals for VAPT

📍 **Environment:** Windows 10 VM
🛠️ **Tools:** `cmd`, `systeminfo`, `net`, `whoami`, `wmic`, `icacls`, `schtasks`

---

## 🎯 What I Did Today

### 1. Basic System Recon
- Gathered `systeminfo`, `hostname`, `whoami`.
- Got the full OS name, version, architecture, and logged-in user in one sweep.

### 2. User & Group Enumeration
- Listed all local users with `net user`.
- Dumped the Administrators group with `net localgroup Administrators`.
- Checked group memberships of the current user using `whoami /groups`.
- Spotted high-value groups like **Backup Operators** and **Remote Desktop Users**.

### 3. WMIC System Profiling
- Enumerated OS details, installed hotfixes, running services, and processes.
- `wmic qfe list brief` showed missing patches — each missing KB is a potential kernel exploit.
- `wmic service get name,displayname,pathname,startmode` helped identify unquoted service paths.

### 4. Network & Firewall Checks
- Ran `ipconfig /all` and `netstat -ano` to map network interfaces and active connections.
- Checked firewall rules with `netsh advfirewall show currentprofile`.

### 5. File Permission Audit
- Used `icacls "C:\Program Files"` and other critical directories to spot weak permissions.
- Found a service folder writable by `BUILTIN\Users` — perfect for binary hijacking.

### 6. Scheduled Tasks
- Listed all scheduled tasks with `schtasks /query`.
- Identified a task running as SYSTEM that called a script from a user-writable folder — another escalation vector.

---

## 🧠 Key Takeaways

| Technique | Insight | Why It Matters |
|-----------|--------|----------------|
| `systeminfo` | Quick snapshot of the OS | Shows architecture, hotfixes, and if it’s a DC |
| `net user` & `whoami /groups` | User and group membership | Groups like Backup Operators can lead to disk access and privilege escalation |
| `wmic qfe list brief` | Hotfix enumeration | Missing patches = potential kernel exploits |
| Service paths | Check with `wmic service` | Unquoted paths or weak permissions enable binary hijacking |
| `icacls` | Permission auditing | A world-writable service binary gives SYSTEM access |
| Scheduled tasks | `schtasks /query` | A task running as SYSTEM with a writable script is an instant win |

> 💡 **Core lesson:** Windows enumeration is all about finding weak permissions, missing patches, and misconfigured services. The built-in tools like `wmic` and `icacls` are all you need to start the escalation chain.

---

## 📸 Proof of Work
