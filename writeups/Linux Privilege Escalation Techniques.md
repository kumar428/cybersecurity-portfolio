# 🔐 Linux Privilege Escalation Techniques

📍 **Environment:** Kali Linux (simulated)  
🛠️ **Tools:** `sudo`, `find`, `vim`, `openssl`, `john`, `nc`

---

## 🎯 What I Did Today

### 1. Kernel Exploit Recon
- Ran `uname -a` and `searchsploit` to check kernel version.
- Understood that kernel exploits can crash production systems, so they’re last resort in a real pentest.

### 2. Sudo Misconfiguration Abuse
- Created a low-priv user and granted `NOPASSWD: /usr/bin/find`.
- Switched to that user and ran `sudo find . -exec /bin/bash \;` → instant root shell.
- Demonstrated why `sudo -l` is always the first command after a foothold.

### 3. Cron Job Hijack
- Added a root cron job that executed a world-writable script (`/tmp/cleanup.sh`).
- Injected a reverse shell into that script.
- Set up a netcat listener and received a root shell within one minute.

### 4. Writable `/etc/passwd`
- Simulated a misconfigured world-writable `/etc/passwd`.
- Generated a password hash with `openssl` and appended a new root-equivalent user.
- Logged in as the new user and confirmed `whoami` returns root.

### 5. Readable `/etc/shadow`
- Made `/etc/shadow` world-readable to simulate a misconfiguration.
- Extracted the root hash and started cracking with `john` and the rockyou wordlist.
- Learned how even a simple misstep can expose all credentials.

### 6. SUID Vim Escape
- Located a SUID `vim` binary with `find / -perm -4000`.
- Escaped to a shell using `vim -c ':!/bin/bash'` – immediate root access.

---

## 🧠 Key Takeaways

| Technique | Risk | Why It Matters |
|-----------|------|----------------|
| **Sudo misconfig** | `NOPASSWD` on dangerous binaries | Single command gives root instantly |
| **SUID binaries** | Uncommon SUID on `vim`, `find`, `bash` | Escalation without passwords |
| **Cron jobs** | Writable scripts called by root | Reverse shell or command injection |
| **/etc/passwd writable** | Anyone can add a root user | Full compromise, no exploit needed |
| **/etc/shadow readable** | Hashes exposed | Offline cracking can reveal passwords |
| **Kernel exploits** | Old unpatched kernel | Can give root but may crash the system |

> 💡 **Core lesson:** Privilege escalation is not about luck – it’s about systematically checking every weak permission, misconfiguration, and accessible sensitive file. In 90% of cases, `sudo -l`, SUID hunt, and file permission checks are enough.

---

## 📸 Proof of Work

| Screenshot | Description |
|:---|:---|
| ![Initial Check](../assets/VirtualBox_kali%20Linux_15_05_2026_20_14_04.png) | Verification of file/directory initial state |
| ![Permission Modification](../assets/VirtualBox_kali%20Linux_15_05_2026_20_19_02.png) |  Changing permissions using numeric/symbolic modes |
| ![SUID/Sticky Bit](../assets/VirtualBox_kali%20Linux_15_05_2026_20_22_51.png) |  Applying SUID and Sticky bits to targets |
| ![Find Command](../assets/VirtualBox_kali%20Linux_15_05_2026_20_23_59.png) |  Using `find` to locate misconfigured SUID binaries |
| ![Exploit Setup](../assets/VirtualBox_kali%20Linux_15_05_2026_20_27_53.png) |  Compiling and preparing the privilege escalation exploit |
| ![Root Access](../assets/VirtualBox_kali%20Linux_15_05_2026_20_27_37.png) |  Successful exploitation and confirmation of root shell |
