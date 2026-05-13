# 🔐 Protocols Deep Dive: DNS, HTTP & FTP

📍 **Environment:** Kali Linux + Metasploitable2  
🛠️ **Tools:** `dig`, `curl`, Wireshark

---

## 🎯 What I Did Today

### 1. DNS Enumeration with `dig`
- Queried **A records** (IPv4), **NS records** (authoritative nameservers), and **PTR records** (reverse DNS).
- Understood how DNS zone transfers can accidentally expose entire internal infrastructures — a massive recon goldmine in pentests.

### 2. HTTP Request/Response Analysis
- Used `curl -v` to inspect raw headers, check for information leaks, and test **HTTP method support**.
- Customised `User-Agent` and injected `X-Forwarded-For` headers to see how the server reacts (IP spoofing attempts).
- Captured a full HTTP stream in Wireshark and followed the TCP stream to see the plaintext request-response cycle.

### 3. FTP: The Danger of Cleartext
- Connected to **Metasploitable2** via FTP.
- Logged in with `anonymous` access — which was embarrassingly left enabled.
- Started a Wireshark capture, filtered with `ftp`, and **saw the password in plaintext** inside the packet bytes.  
  👁️ *Username and password, visible without any decryption.*

---

## 🧠 Key Takeaways

| Protocol | Risk | Why It Matters |
|----------|------|----------------|
| **DNS** | Zone transfer misconfiguration | Reveals all subdomains, internal IPs, and hostnames — a blueprint for attackers. |
| **HTTP** | Verb tampering (`PUT`, `DELETE`) | Poorly configured servers may allow file uploads or data deletion. |
| **FTP** | No encryption | Credentials travel in cleartext — always sniffable. |
| **vsftpd 2.3.4** | Backdoor vulnerability | Specific version on Metasploitable2 contains a known backdoor (port 6200). |

> 💡 **Core lesson:** If a protocol wasn’t designed with encryption, assume it’s already compromised. Always use encrypted alternatives (HTTPS, SFTP, DoH/DoT).

---



## 📸 Proof of Work

| Screenshot | Description |
| :--- | :--- |
| ![DNS Query](../assets/VirtualBox_kali%20Linux_13_05_2026_19_22_17.png) |  DNS Enumeration (dig) |
| ![HTTP Headers](../assets/VirtualBox_kali%20Linux_13_05_2026_20_36_27.png) |  HTTP Request/Response Headers |
| ![Wireshark Stream](../assets/VirtualBox_kali%20Linux_13_05_2026_20_52_29.png) |  Wireshark Packet Analysis |
| ![FTP Login](../assets/VirtualBox_kali%20Linux_13_05_2026_21_02_38.png) |  FTP Authentication Process |
| ![FTP Cleartext](../assets/VirtualBox_kali%20Linux_13_05_2026_21_16_23.png) |  FTP Cleartext Password Capture |

---

## 🔜 Next Steps
- Explore **DNS zone transfer** exploitation (`dig AXFR`)
- Test **HTTP method tampering** with `curl -X PUT`
- Try **vsftpd backdoor exploitation** (with permission on lab)
- Move to **HTTPS/TLS inspection** in Wireshark

---

*Stay curious. Stay ethical. Keep hacking (legally).*  
🕵️‍♂️ #VAPT #CyberSecurity #Wireshark #FTP #DNS
