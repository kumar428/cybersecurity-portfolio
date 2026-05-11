```markdown
<!-- 
  Modern Security Assessment Report
  Version: 2.0 | Markdown with GitHub Alerts & Mermaid Support
-->

# 🛡️ Network Enumeration & Traffic Analysis  
## *Information Disclosure via Unencrypted HTTP & Stealth SYN Scanning*

[![Lab Environment](https://img.shields.io/badge/Environment-Local_Lab-cyan?style=for-the-badge&logo=vmware)](https://shields.io/)
[![Severity: Medium](https://img.shields.io/badge/Severity-Medium_(CVSS_5.3)-orange?style=for-the-badge&logo=common vulnerabilities)](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator)
[![MITRE: T1046](https://img.shields.io/badge/MITRE-T1046_(Scanning)-red?style=for-the-badge&logo=mitre)](https://attack.mitre.org/techniques/T1046/)
[![MITRE: T1040](https://img.shields.io/badge/MITRE-T1040_(Sniffing)-red?style=for-the-badge&logo=mitre)](https://attack.mitre.org/techniques/T1040/)

---

## 📌 Executive Summary

> **> [!WARNING]**
> **Plaintext HTTP traffic** and **stealth SYN scanning** were observed in a controlled lab environment. Attackers can passively sniff credentials and session data while mapping internal services with minimal logs.

An active assessment revealed:
- ✅ Successful extraction of readable HTTP requests/responses from packet captures
- ✅ Full port mapping (including 80/tcp, 443/tcp, and others) using `nmap -sS` without completing handshakes
- ❌ No encryption applied to web traffic  
- ❌ No detection of half‑open scans by current security controls

---

## 🔄 Attack Walkthrough (Mermaid)

```mermaid
sequenceDiagram
    participant Attacker as 🧑‍💻 Attacker (Kali)
    participant Target as 🎯 Target (192.168.x.x)
    participant Wireshark as 📡 Wireshark (Monitor)

    Note over Attacker,Wireshark: Phase 1 – Stealth Reconnaissance
    Attacker->>Target: SYN packet (port 80)
    Target-->>Attacker: SYN-ACK (port open)
    Attacker->>Target: RST (abort connection) ✂️
    Wireshark->>Wireshark: Captures SYN + SYN-ACK

    Attacker->>Target: SYN packet (port 443)
    Target-->>Attacker: SYN-ACK (port open)
    Attacker->>Target: RST
    Note right of Attacker: Open ports identified without full handshake

    Note over Attacker,Wireshark: Phase 2 – Unencrypted Data Leak
    Attacker->>Target: GET /login HTTP/1.1 (cleartext)
    Target-->>Attacker: HTTP/1.1 200 OK + credentials in body
    Wireshark->>Attacker: "Follow TCP Stream" reveals plaintext 🔓
```

---

## 🔍 Reproduction Steps

### 🧰 Prerequisites
- **Attacker machine:** Kali Linux (with `nmap`, `wireshark`)
- **Target:** Any local device with HTTP service
- **Network:** Access to same broadcast domain / switched network

---

### 1️⃣ Start Packet Capture

Launch Wireshark on the active interface and apply a display filter:

```bash
# Terminal
sudo wireshark -i eth0 -k -f "tcp port 80 or tcp.flags.syn == 1"
```

Or apply inside Wireshark:

```wireshark-filter
http or tcp.flags.syn == 1
```

> **> [!TIP]**
> Use `tcp.flags.syn == 1 and tcp.flags.ack == 0` to isolate initial SYN packets only.

---

### 2️⃣ Perform SYN Scan (Stealth)

```bash
sudo nmap -sS -Pn -p- 192.168.x.x
```

| Option | Description |
|--------|-------------|
| `-sS`  | **Half‑open SYN scan** – never completes handshake |
| `-Pn`  | Skip ICMP host discovery (treat all hosts as up) |
| `-p-`  | Scan all 65535 ports |

📌 *Example output:*
```
PORT     STATE    SERVICE
80/tcp   open     http
443/tcp  open     https
8080/tcp open     http-proxy
```

---

### 3️⃣ Inspect Captured Traffic

Inside Wireshark after the scan and a manual HTTP request:

1. Select any packet with `http` or `[SYN]` flag
2. Right‑click → **Follow** → **TCP Stream**
3. Observe **plaintext** HTTP headers, cookies, or form data

```http
GET /private HTTP/1.1
Host: 192.168.x.x
Cookie: sessionid=abc123
```

> **> [!IMPORTANT]**
> An attacker on the same network can passively retrieve this information without generating any logs on the target.

---

## 📸 Evidence

![Wireshark TCP Stream Showing Cleartext HTTP](assets/wireshark_traffic.png)

> *Replace the path with your actual screenshot. Example of expected finding:*

```text
Hypertext Transfer Protocol
    GET /dashboard HTTP/1.1\r\n
    Host: 192.168.1.100\r\n
    Authorization: Basic YWRtaW46cGFzc3dvcmQ=\r\n   <-- base64 decoded = admin:password
```

---

## 📊 Security Impact

### CVSS v3.1 Score: **5.3 (Medium)**

```plaintext
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:L/I:N/A:N
```

| Metric                | Value               | Rationale                                      |
|-----------------------|---------------------|------------------------------------------------|
| Attack Vector (AV)    | **Network (N)**     | Remotely exploitable over network              |
| Attack Complexity (AC)| **Low (L)**         | No special conditions required                 |
| Privileges Required (PR)| **None (N)**       | No authentication needed to sniff or scan      |
| User Interaction (UI) | **None (N)**        | No user action required                        |
| Scope (S)             | **Unchanged (U)**   | Vulnerable component does not affect others    |
| Confidentiality (C)   | **Low (L)**         | Partial data exposure                          |
| Integrity (I)         | **None (N)**        | No data manipulation                           |
| Availability (A)      | **None (N)**        | No service disruption                          |

### 🚨 Identified Risks

- **Passive reconnaissance** – SYN scans enable full network mapping without connection logs
- **Cleartext credential leakage** – HTTP basic/digest or session cookies easily extracted
- **MITM amplification** – Unencrypted traffic simplifies session hijacking and data injection
- **Compliance violations** – PCI DSS, GDPR, HIPAA require encryption for sensitive data in transit

---

## 🛡️ Recommendations (Checklist)

### 🔐 Enforce Encryption  
- [ ] **Redirect all HTTP → HTTPS** (HSTS preload ready)  
- [ ] Use **TLS 1.2/1.3** only, disable SSLv3/TLS 1.0/1.1  
- [ ] Apply **secure cipher suites** (e.g., `ECDHE+AES-GCM`)  

### 📡 Improve Detection & Response  
- [ ] Enable IDS/IPS rules for SYN scans:  
  ```suricata
  alert tcp $EXTERNAL_NET any -> $HOME_NET any (msg:"Stealth SYN scan"; flags:S; threshold: type both, track by_src, count 10, seconds 5; sid:1000001;)
  ```
- [ ] Configure firewall to log **SYN packets without corresponding ACK**  
- [ ] Deploy **network‑based anomaly detection** for port sweeps  

### 🧹 Reduce Attack Surface  
- [ ] Close unused ports (review `netstat -tulpn`)  
- [ ] Implement **port knocking** or **VPN** for sensitive internal services  
- [ ] Segment **web frontends** from internal databases  

---

## 🧰 Tools Used

| Tool       | Usage                                      | Logo                                                                 |
|------------|--------------------------------------------|----------------------------------------------------------------------|
| **Wireshark** | Capture & analyze frames, follow TCP streams | ![Wireshark](https://img.shields.io/badge/Wireshark-1679A7?logo=wireshark&logoColor=white) |
| **Nmap**      | Half‑open SYN scanning                    | ![Nmap](https://img.shields.io/badge/Nmap-0E83CD?logo=nmap&logoColor=white) |
| **Kali Linux**| Attack platform                           | ![Kali](https://img.shields.io/badge/Kali-557C94?logo=kalilinux&logoColor=white) |

---

## 🧠 MITRE ATT&CK Mapping

| Technique                         | ID      | Tactic            |
|-----------------------------------|---------|-------------------|
| **Network Service Scanning**      | [T1046](https://attack.mitre.org/techniques/T1046/) | Discovery |
| **Network Sniffing**              | [T1040](https://attack.mitre.org/techniques/T1040/) | Credential Access, Discovery |

### 🔗 Additional References
- [CWE-319: Cleartext Transmission of Sensitive Information](https://cwe.mitre.org/data/definitions/319.html)
- [NIST SP 800-115: Technical Guide to Information Security Testing](https://csrc.nist.gov/publications/detail/sp/800-115/final)
- [OWASP – Transport Layer Protection Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html)

---

## 🏷️ Tags

`#Wireshark` `#Nmap` `#TrafficAnalysis` `#CyberSecurity` `#NetworkSecurity` `#VAPT` `#HTTPS-Everywhere` `#StealthScan` `#MITRE`

---

*Report generated by Security Assessment Lab* | **Classification: Internal Use Only**  
*Last updated: 2025‑03‑01*  
```
