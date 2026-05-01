Date: May 1, 2026

Focus: Defensive Security Operations & Incident Research

🎯 Today's Goals
[x] Complete the Defensive Security Introduction lab.

[x] Research a real-world data breach for Case Study.

[x] Document the SOC Analyst workflow and technical findings.

🛠️ Tasks & Labs Completed
1. Defensive Security Intro (100% Complete ✅)
Scenario: Protecting "FakeBank" from a live cyber attack.

Action: Analyzed server logs, identified malicious IP (32.122.195.63), and blocked it via Firewall.

Flag: THM{FAKEBANK-SECURED}

Evidence:

🔍 Case Study: Cybersecurity Incident Research
(Intha varam naatandha mukkiyamaana research)

Topic: Tamil Nadu Labour Department Data Breach (2024)
Classification: Professional Case Study / Ethical Hacking Assessment

1. Incident Overview
In May and November 2024, the Tamil Nadu Labour Department’s digital infrastructure suffered two major security breaches.

Scale: Approximately 7.2 million records stolen.

Sensitive Data: Included Names, Addresses, [Aadhaar Redacted], PAN Numbers, and Bank Details.

2. Technical Analysis
The Vector (GSocket): Attackers used GSocket for Reverse Tunneling.

Critical Failure: 1. Firewall Bypass: GSocket initiated outbound connections, bypassing NAT and firewalls.
2. MFA Absence: Lack of Multi-Factor Authentication allowed "root" access via compromised credentials.
3. Persistence: The tunnel acted as a permanent backdoor.

3. Remediation Recommendations
Zero Trust: Implement MFA for all administrative access.

Egress Filtering: Block P2P and tunneling protocols at the firewall level.

Encryption: Sensitive data must be encrypted at rest.

Student Analyst Conclusion: > "The TN Labour Department breach is a classic 'Living off the Land' attack. Traditional perimeter security is insufficient without Identity Management (MFA) and strict Egress monitoring."
