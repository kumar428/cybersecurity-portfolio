
# VAPT Recon Script

A single bash script that automates daily VAPT reconnaissance.  
Just enter a target domain or IP, and it runs the most useful commands used in real pentesting and bug bounty.

## 🚀 Quick Start

```bash
git clone https://github.com/kumar-palanivelu-pentester/penetration-tester-portfolio.git
cd penetration-tester-portfolio
chmod +x tools/vapt-recon.sh
./tools/vapt-recon.sh
```

Enter the target when prompted. All results appear inside `recon_<target>/`.

## 📦 Requirements

The script gracefully skips missing tools, so it works even with just `curl` and `nmap`.  
For full power, install:

```bash
sudo apt install nmap curl whois whatweb netcat-openbsd
# Optional but recommended
sudo apt install subfinder httpx assetfinder gobuster nikto
```

Make sure a wordlist exists at `/usr/share/wordlists/dirb/common.txt`. Install it with:

```bash
sudo apt install dirb
```

## 🔧 What the Script Automates

| Step | Tool | Command Used |
|------|------|--------------|
| WHOIS | `whois` | `whois target` |
| Subdomains | `subfinder`, `assetfinder` | `subfinder -d target -all` / `assetfinder --subs-only` |
| Live hosts | `httpx` | `httpx -silent` |
| Port scan | `nmap` | `nmap -sV -sC -T4 --open` |
| Quick ports | `nc` | `nc -zv target 80,443,22` |
| Tech detection | `whatweb` | `whatweb -a 3 target` |
| Web scan | `nikto` | `nikto -h target -ssl -Tuning x` |
| Dir busting | `gobuster` (or ffuf/dirsearch/wfuzz) | Best flags depending on installed tool |

At the end, it also prints manual commands for **SQLMap** and **Hydra** so you can test them interactively.

## ⚠️ Disclaimer

Use only on systems you own or have explicit permission to test.  
Misuse is your own responsibility.
