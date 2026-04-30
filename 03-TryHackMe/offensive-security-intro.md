# Lab Report: Offensive Security Introduction
**Platform:** TryHackMe | **Path:** Pre Security → Introduction to Cyber Security
**Date:** 29-04-2026 | **Difficulty:** Beginner | **Status:** Completed

---

## 1. Executive Summary

This lab provided a hands-on introduction to offensive security by simulating an ethical hacking scenario against a fictitious banking application (FakeBank). The objective was to identify and exploit security misconfigurations within a controlled, legal environment — replicating the mindset and methodology used by real-world penetration testers.

Three distinct vulnerabilities were identified and exploited across four tasks, resulting in unauthorized access to an administrative function and successful manipulation of account balances.

---

## 2. Scope and Objectives

| Item | Detail |
|------|--------|
| Target | FakeBank Web Application (http://fakebank.thm) |
| Authorization | Full — TryHackMe controlled environment |
| Objective | Identify hidden pages and exploit access control weaknesses |
| Rules of Engagement | Legal, sandboxed environment only |

---

## 3. Methodology

This engagement followed the standard penetration testing lifecycle:

```
Reconnaissance → Scanning/Enumeration → Exploitation → Reporting
```

---

## 4. Findings

### 4.1 Information Disclosure — Account Data Visible Without Authentication

**Severity:** Low
**Location:** http://fakebank.thm (Homepage)

**Description:**
The bank account number (8881) was displayed directly on the homepage dashboard without any authentication requirement, exposing sensitive financial information to unauthenticated users.

**Evidence:**
- Account number 8881 visible in plain text on landing page
- No session or authentication check present

**Remediation:**
Implement session-based authentication before rendering any account-specific data. All sensitive fields should require a valid, verified session token.

---

### 4.2 Broken Access Control — Unauthenticated Access to Admin Function

**Severity:** High
**Location:** http://fakebank.thm/bank-transfer

**Description:**
A hidden administrative page (/bank-transfer) was discovered via directory enumeration. This page allowed any user — authenticated or not — to transfer funds to any account without authorization or identity verification.

**Discovery Method:**
```bash
dirb http://fakebank.thm
```

**Output:**
```
+ http://fakebank.thm/images         [Status: 200]
+ http://fakebank.thm/bank-transfer  [Status: 200]
```

**Remediation:**
Restrict access to administrative endpoints using role-based access control (RBAC). All sensitive operations must require verified session tokens and authorization checks server-side.

---

### 4.3 Business Logic Flaw — Unrestricted Fund Transfer

**Severity:** Critical
**Location:** http://fakebank.thm/bank-transfer

**Description:**
Once the admin panel was accessed, it was possible to transfer an arbitrary amount to any account without any validation, approval workflow, or transaction limit. This resulted in a direct modification of account balances.

**Exploitation Steps:**
1. Navigated to http://fakebank.thm/bank-transfer
2. Selected target account: 8881
3. Entered transfer amount: $3,000
4. Clicked "Deposit Money"
5. Balance changed from -$1,232.32 to +$1,767.68
6. Flag displayed: `BANK-HACKED`

**Remediation:**
Implement server-side transaction validation, multi-factor approval for large transfers, and audit logging for all financial operations.

---

## 5. Vulnerability Summary

| ID | Vulnerability | Severity | Location |
|----|--------------|----------|----------|
| V-01 | Information Disclosure | Low | Homepage |
| V-02 | Broken Access Control | High | /bank-transfer |
| V-03 | Business Logic Flaw | Critical | /bank-transfer |

---

## 6. Tools Used

| Tool | Purpose |
|------|---------|
| dirb | Directory brute-forcing to discover hidden endpoints |
| Browser | Manual navigation and form interaction |

---

## 7. Key Learnings

- Hidden pages are not protected by obscurity alone — always enumerate directories
- Broken Access Control consistently ranks in the OWASP Top 10 most critical vulnerabilities
- Business logic flaws require deep understanding of application workflow, not just technical exploits
- Offensive security methodology: recon → enumeration → exploitation → documentation

---

## 8. Personal Reflection

**Understood well:**
- How directory enumeration reveals hidden attack surface
- Why access control must be enforced server-side, not just UI-side

**Needs improvement:**
- Understanding defensive countermeasures for each vulnerability type
- Practicing tool usage (dirb, gobuster) more independently

---

## 9. References

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- TryHackMe Room: https://tryhackme.com/room/offensivesecurityintro
- Broken Access Control: https://owasp.org/Top10/A01_2021-Broken_Access_Control/

---


