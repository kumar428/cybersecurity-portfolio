# 🔐 CSRF & SSRF on pentest-ground.com:4280

📍 **Environment:** Kali Linux + browser + Burp Suite  
🎯 **Target:** `https://pentest-ground.com:4280/` (intentionally vulnerable web app)  
🛠️ **Tools:** Burp Suite (Proxy, Repeater, Engagement tools, Collaborator), Netcat, Webhook.site

---

## 🎯 What I Did Today

### 1. CSRF – Identifying Missing Protections
- Mapped state-changing requests: password change, profile update, fund transfer (if applicable).
- Checked each request for anti-CSRF tokens. Found that the **profile update** endpoint (`POST /update`) had no token at all.
- Also noted that the session cookie was automatically sent by the browser – meaning a simple auto-submitting form could trigger the action.

### 2. CSRF – Proof-of-Concept Generation
- Right-clicked the vulnerable request in Burp and used **Engagement tools → Generate CSRF PoC**.
- The resulting HTML form recreated the exact request, including all headers the browser would add.
- Saved the PoC as `csrf_poc.html`, opened it in the same browser, and the profile was updated without any user interaction – classic CSRF.

### 3. SSRF – Finding URL Input Vectors
- Searched for features that fetch remote resources: image URL import, webhook test, link preview, or an API proxy.
- The **"Check URL Status"** feature (`POST /fetch?url=`) stood out – it fetched the given URL and displayed the response status.
- Immediately tested with `http://127.0.0.1:80` and received an internal page response – the server was making requests to internal hosts.

### 4. SSRF – Internal Service Discovery
- Probed common internal endpoints: `localhost`, `127.0.0.1:3306` (MySQL), `127.0.0.1:22` (SSH), and cloud metadata endpoints (`169.254.169.254`).
- `http://169.254.169.254/latest/meta-data/` returned AWS instance metadata – a critical finding.
- Also scanned ports by observing differences in response times/errors (time-based detection for closed vs open ports).

### 5. Blind SSRF – Confirming Outbound Connectivity
- Where no response was returned, I used a Burp Collaborator payload and a webhook.site URL as the target.
- The Collaborator received a DNS/HTTP pingback, proving the server made the outbound request.
- This confirmed blind SSRF, which could be used to map internal networks.

---

## 🧠 Key Findings

| Finding | Evidence | Impact |
|---------|----------|--------|
| **CSRF on profile update** | No anti-CSRF token; PoC form successfully changed data | Attacker can force any user to modify their account without consent |
| **CSRF token reuse (if tested)** | Token accepted even after logout | Attacker can pre-generate token and reuse across sessions |
| **SSRF on URL Check** | `http://127.0.0.1` returned internal web page | Access to internal services, metadata endpoints |
| **Cloud metadata access** | `169.254.169.254/latest/meta-data/` dumped instance info | Exposure of IAM credentials, keys, instance details |
| **Blind SSRF confirmed** | Collaborator received pingback | Server makes outbound requests; can scan internal network |
| **Lack of SameSite cookies** | Session cookie sent on cross-site requests | Makes CSRF even easier to exploit |

> 💡 **Core lesson:** CSRF and SSRF are two sides of the same trust problem. CSRF exploits the trust a server has in the user's browser, while SSRF exploits the trust a server has in itself. Both can be devastating.

---

## 📸 Proof of Work

| Screenshot | Description |
|------------|-------------|
| ![CSRF Request](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/csrf_request.png) |  Original vulnerable request (profile update) lacking anti-CSRF protection |
| ![SSRF Test](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/ssrf_test.png) |  SSRF probe to `127.0.0.1` successfully returning internal server responses |

