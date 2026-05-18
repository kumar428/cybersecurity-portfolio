# 🔐 Burp Suite  – Intercept, Repeater & Intruder

📍 **Environment:** Burp Suite Community + Firefox (proxied)  
🎯 **Target:** `http://192.168.x.x` (local lab machine)  
🛠️ **Tools:** Burp Suite (Proxy, Repeater, Intruder, Target scope), browser

---

## 🎯 What I Did Today

### 1. Proxy & Browser Setup
- Configured Burp Suite’s listener on `127.0.0.1:8080` and pointed Firefox to it.
- Installed the Burp CA certificate in the browser trust store so HTTPS traffic could be intercepted without certificate warnings.

### 2. Intercepting Live Traffic
- Turned on Intercept and captured an HTTP request to the target.
- Edited request headers (User-Agent, Cookie, custom headers) in flight and forwarded to see how the server responded.
- Understood that every parameter the browser sends is visible and editable at the proxy level.

### 3. Repeater – Manual Parameter Manipulation
- Sent a captured login request to Repeater for step-by-step testing.
- Modified the username and password parameters, changed the HTTP method, and tweaked cookie values.
- Tested for basic input reflection and IDOR by incrementing user ID parameters – exactly the kind of manual testing that finds business-logic flaws.

### 4. Intruder – Sniper Attack on Login
- Launched a Sniper attack targeting the password field of the login form.
- Loaded a small wordlist (common passwords) and ran the brute-force.
- Analysed response lengths and status codes to spot the successful login, while noting the importance of rate limiting.

### 5. Target Scope Configuration
- Set the target scope to `192.168.x.x` so that only traffic to this IP appeared in the site map and proxy history.
- Filtered out noise from external domains (Google, Firefox telemetry), keeping the test focused.

### 6. HTTPS Interception with Burp CA
- Exported the Burp CA certificate and imported it into Firefox’s Certificate Manager.
- Confirmed that HTTPS requests to the target were decrypted and visible in the proxy history – a must-have for testing modern web apps.

---

## 🧠 Key Takeaways

| Feature | What It Does | Why It Matters |
|---------|--------------|----------------|
| **Proxy Intercept** | Captures requests between browser and server | Lets you inspect and modify every parameter the client sends |
| **Repeater** | Manually resend modified requests | Precision tool for testing injection, IDOR, and parameter tampering |
| **Intruder** | Automates payload delivery | Speeds up brute-force, fuzzing, and enumeration – but respect rate limits |
| **Target Scope** | Filters traffic to defined hosts | Keeps the testing session clean and avoids out-of-scope assets |
| **Burp CA Certificate** | Trusts Burp as a man-in-the-middle | Decrypts HTTPS for full visibility – essential for web pentesting |
| **Edit & Forward** | Quick modification of live requests | First-line check for client-side trust issues |

> 💡 **Core lesson:** Burp Suite is the command centre for web application testing. Once you can intercept, replay, and automate, you’re no longer just a spectator – you’re actively testing the trust boundaries of the application.

---

## 📸 Proof of Work

| Screenshot | Description |
|:---|:---|
| ![Intercept Request](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/intercept_request.png) |  Intercepting and analyzing live HTTP proxy traffic in Burp Suite |
| ![Repeater Test](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/repeater_test.png) | Isolating and manipulating targeted web requests inside Burp Repeater |
| ![Modified Header](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/modified%20header.png) |  Modifying custom HTTP request headers to bypass access controls |
| ![Intruder Attack](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/intruder_attack.png) |  Configuring fuzzing payloads and executing a Burp Intruder attack |
| ![Scope Setting](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/scope_setting.png) | Defining target scope rules to filter out external third-party traffic |
| ![Burp Certificate](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/burp_cert.png) |  Installing PortSwigger's CA certificate in the browser Certificate Manager |
