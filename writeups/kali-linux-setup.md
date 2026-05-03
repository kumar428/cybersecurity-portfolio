
<div align="center">

<br/>

```
██╗  ██╗ █████╗ ██╗     ██╗    ██╗      █████╗ ██████╗
██║ ██╔╝██╔══██╗██║     ██║    ██║     ██╔══██╗██╔══██╗
█████╔╝ ███████║██║     ██║    ██║     ███████║██████╔╝
██╔═██╗ ██╔══██║██║     ██║    ██║     ██╔══██║██╔══██╗
██║  ██╗██║  ██║███████╗██║    ███████╗██║  ██║██████╔╝
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝    ╚══════╝╚═╝  ╚═╝╚═════╝
```

# Project: Kali Linux Virtual Lab Implementation
**An Enterprise-Grade Offensive Security Workstation for VAPT Simulation**

<br/>

![Kali](https://img.shields.io/badge/Kali_Linux-2026.1-557C94?style=for-the-badge&logo=kalilinux&logoColor=white)
![VirtualBox](https://img.shields.io/badge/VirtualBox-7.x-183A61?style=for-the-badge&logo=virtualbox&logoColor=white)
![Status](https://img.shields.io/badge/Status-Active-22c55e?style=for-the-badge)
![Goal](https://img.shields.io/badge/Goal-VAPT_Analyst-orange?style=for-the-badge)

<br/>

> *Virtualization · Network Bridging · Kernel Optimization · Snapshot Management*

<br/>

</div>

---

## Project Overview

As part of my **60-Day VAPT Professional Track**, I architected a dedicated offensive security environment — not a standard install, but a hardened, optimized attacker machine configured to interact with vulnerable targets (e.g., Metasploitable) in a realistic network topology.

**Why this setup?**

- **Bridged Networking** — VM acts as a standalone host on my LAN, enabling real-world Nmap scans
- **Resource Optimized** — XFCE desktop keeps RAM free for Burp Suite and Metasploit
- **Fail-Safe Design** — Golden Image snapshot strategy for instant recovery after high-risk exploitation

---

## Technical Specifications

| Component | Allocation | Rationale |
|-----------|------------|-----------|
| **VirtualBox** | v7.x + Extension Pack | USB 3.0 and NVMe support |
| **vCPU** | 3 Cores | Multi-threaded scanning and brute-forcing |
| **vRAM** | 8 GB | Headroom for JVM-based tools (Burp Suite, etc.) |
| **Disk** | 40 GB VDI | Dynamically allocated — conserves host storage |
| **OS** | Kali Linux 2026.1 | Latest rolling release, full tool repository |

---

## Implementation Workflow

### 1 — Host hardware validation

Verified hardware-assisted virtualisation before deployment to ensure 64-bit guest support and performance stability.

```powershell
# Windows
systeminfo | find "Virtualization"
```
```bash
# Linux
grep -E 'vmx|svm' /proc/cpuinfo
```

BIOS checked — **VT-x / AMD-V** enabled.

---

### 2 — Virtual machine provisioning

Created a custom VM using **Debian 64-bit** architecture with the following key decisions:

- **Network:** Bridged Adapter — VM pulls a unique IP from the router's DHCP pool
- **Storage:** Installer ISO attached for a clean custom build (avoids pre-built VM limitations and hidden configs)

---

### 3 — Operating system installation

- **User model:** Non-root user `offsec` — follows the **Principle of Least Privilege**
- **Desktop:** XFCE — lightweight, leaves maximum resources for tools
- **Partitioning:** Guided, single partition — clean and simple for a lab environment

---

### 4 — Post-install hardening & integration

```bash
# Update all system binaries
sudo apt update && sudo apt full-upgrade -y

# Install kernel headers for driver support
sudo apt install -y linux-headers-$(uname -r) build-essential dkms

# Deploy VirtualBox Guest Additions (clipboard + auto-resize)
sudo mount /dev/cdrom /mnt && sudo /mnt/VBoxLinuxAdditions.run

# Reboot to apply
sudo reboot
```

**Verify Guest Additions loaded:**
```bash
lsmod | grep vboxguest
```

---

## Advanced Configuration

### Host–guest interoperability

| Feature | Config | Mount Point |
|---------|--------|-------------|
| Shared Folder | Auto-mount, Permanent | `/media/sf_Shared` |
| Clipboard | Bidirectional | — |
| Group Permissions | `sudo adduser $USER vboxsf` | — |

The shared folder serves as a secure transfer point for scan reports, loot files, and wordlists between host and VM.

---

### The golden image snapshot

Immediately after full configuration, captured a baseline snapshot:

```
Name         :  Baseline – Fully Hardened
Description  :  Clean Kali 2026.1 · Guest Additions · Shared Folders · Non-root user
Purpose      :  Instant rollback if OS is corrupted during malware analysis or exploitation
```

This is the single most important step — without it, one bad `rm -rf` ends the lab session.

---

## Lab Validation

```
✅ OS Connectivity  :  Successful DHCP lease + external ping
✅ Tool Readiness   :  Nmap · Metasploit · Burp Suite verified
✅ Driver Status    :  Auto-resize and shared clipboard active
✅ Security Model   :  Non-root user with sudo escalation
✅ Snapshot         :  Baseline locked in before any testing
```

---

## Key Takeaways

- **Networking mastery** — NAT vs Bridged vs Host-Only: knowing when each mode matters for network-wide reconnaissance
- **System hardening** — Non-root user model enforced from day one; `sudo` only when required
- **Troubleshooting** — Resolved kernel-header mismatches during Guest Additions installation (DKMS build failure)
- **Lab discipline** — Snapshot before every major experiment; revert instead of reinstall

---

## Next Phase

> This lab is now ready for **Network Reconnaissance & Vulnerability Analysis**
> — Active scanning with Nmap · Service enumeration · Vulnerability mapping with Nessus/OpenVAS

---

<div align="center">

**Project by [kumar428](https://github.com/kumar428)**
&nbsp;·&nbsp;
[Daily Learning Log](https://github.com/kumar428/cybersecurity-portfolio/blob/main/daily-log.md)
&nbsp;·&nbsp;
[Back to Portfolio](https://github.com/kumar428/cybersecurity-portfolio)

<br/>

*Part of the 60-Day VAPT Professional Track*

</div>
