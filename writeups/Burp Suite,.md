# 🔐 Burp Suite Day 2 – Sequencer, Decoder, Comparer & Extensions

📍 **Environment:**  Burp Suite Community + Firefox  
🎯 **Target:** `https://demo.testfire.net/login.jsp` (Altoro Mutual – deliberately vulnerable banking app)  
🛠️ **Tools:** Burp Suite (Sequencer, Decoder, Comparer, Repeater), Param Miner (BApp Store)

---

## 🎯 What I Did Today

### 1. Session Token Analysis with Sequencer
- Captured 200+ session cookies (`JSESSIONID`) from the Altoro Mutual login flow.
- Fed them into Sequencer to analyse randomness character by character.
- **Result:** The entropy score came out at **[insert your score here]** bits/byte.
  - If below 8 bits/byte, tokens are predictable, which means session hijacking is possible.

### 2. Payload Encoding with Decoder
- Used Decoder to URL-encode and Base64-encode SQL injection payloads.
- Encoded `' OR '1'='1` into `%27%20OR%20%271%27%3D%271` for safe transport inside a GET parameter.
- Decoded captured cookies and parameters to understand their structure.

### 3. Blind SQLi Detection with Comparer
- Sent two login requests to Repeater:
  - Request 1: username=`admin' AND '1'='1`, password=anything
  - Request 2: username=`admin' AND '1'='2`, password=anything
- Compared the responses in Comparer. Differences in response length, error message, or content revealed the injection’s effect.
- **Observed:** Response to true condition returned a different error message than false condition

### 4. Hidden Parameter Discovery with Param Miner
- Installed **Param Miner** from the BApp Store.
- Right-clicked the target in the site map and selected “Guess hidden parameters”.
- **Discovered hidden parameter(s):** admin`, `test`.
- This is a powerful technique for finding debug endpoints, legacy parameters, or unprotected admin functions.

### 5. SQL Injection Bypass on Login Form
- In Repeater, crafted a login bypass payload: `' OR '1'='1` in the username field.
- Left the password blank or arbitrary.
- **Result:** The server  redirected to dashboard.
- Demonstrated that the application concatenates user input directly into an SQL query without sanitisation.

---

## 🧠 Key Takeaways

| Tool / Technique | What It Does | Why It Matters |
|------------------|--------------|----------------|
| **Sequencer** | Analyses token randomness | Predictable session tokens enable account takeover without credentials |
| **Decoder** | Encodes/decodes payloads | Critical for crafting payloads that survive transport and bypass filters |
| **Comparer** | Diffs two responses | Essential for detecting subtle blind injection vulnerabilities |
| **Param Miner** | Guesses hidden parameters | Finds debug endpoints, forgotten admin panels, and missing access controls |
| **Repeater + SQLi** | Manual injection testing | Confirms SQL injection manually, no scanner required |
| **Session security** | Token strength matters | Weak randomness in a banking app like Altoro is a critical-risk finding |

> 💡 **Core lesson:** Burp Suite’s power isn’t just in intercepting traffic; it’s in the specialised tools that let you analyse randomness, diff responses, and discover hidden attack surface. Together they turn a manual test into a thorough security assessment.

---

## 📸 Proof of Work

| Screenshot | Description |
|------------|-------------|
| ![Sequencer Analysis](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/sequencer_testfire.png) | **Image 1:** Sequencer analysis of JSESSIONID token randomness and entropy |
| ![Decoder Testfire](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/decoder_testfire.png) | **Image 2:** Utilizing Burp Decoder to encode payloads for the Altoro Mutual target |
| ![Comparer Testfire](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/comparer_testfire.png) | **Image 3:** Diffing true vs. false Boolean responses in Burp Comparer to find blind SQLi |
| ![Param Miner Testfire](https://raw.githubusercontent.com/kumar428/cybersecurity-portfolio/main/assets/param_miner_testfire.png) | **Image 4:** Running the Param Miner extension to guess hidden application parameters |
