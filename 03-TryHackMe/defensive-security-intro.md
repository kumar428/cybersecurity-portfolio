Defensive Security Introduction
Platform: TryHackMe | Path: Jr Penetration Tester
Date: 30-04-2026 | Difficulty: Beginner | Status: Completed ✅

1. Executive Summary
Intha lab-la "Defensive Security" (Blue Teaming) oda basics-ah practical-ah learn pannuna. Oru corporate bank (FakeBank) mela nadakura live cyber attack-ah SOC (Security Operations Center) analyst-ah irunthu epdi detect panni stop panrathu nu intha lab explain pannuchu.

2. Objective
System logs-ah monitor panni suspicious activity-ah find panrathu.

Attacker-oda IP address-ah identify panrathu.

Firewall rules moolama attack-ah block panni system-ah secure panrathu.

3. Methodology & Findings
3.1 Detection (SOC Monitoring)
Monitoring dashboard-la unusual traffic spike detect aachurukkum. Server logs-la multiple unauthorized login attempts irunthathu.

3.2 Investigation (Log Analysis)
Logs-ah filter panni paatha pothu, oru specific IP address continuous-ah attack pannuratha find pannuna:

Attacker IP: 32.122.195.63

Attack Type: Brute Force / Unauthorized Access.

3.3 Response (Remediation)
Find pannuna IP address-ah bank-oda Firewall-la update panni, traffic-ah block pannuna. Athuku apparam server normal state-ku vanthuchu.

Flag Captured: THM{FAKEBANK-SECURED} ✅

4. Skills Gained
Log Analysis: Raw logs-la irunthu malicious patterns-ah extract panna kathukitta.

Incident Response: Oru attack nadakum pothu step-by-step-ah epdi react pannanum nu purinjikitta.

Firewall Management: IP blocking and security rule configuration.

5. Lab Evidence
6. 
