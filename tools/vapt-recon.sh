#!/bin/bash

# ==========================================
# VAPT DAILY RECON SCRIPT
# Safe – no intrusive brute-force by default
# ==========================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}   DAILY VAPT RECON AUTOMATION${NC}"
echo -e "${GREEN}===================================${NC}"

read -p "Enter Target (IP or Domain): " target

if [ -z "$target" ]; then
    echo -e "${RED}[-] Target empty. Exiting.${NC}"
    exit 1
fi

outdir="recon_${target}"
mkdir -p "$outdir"
echo -e "${GREEN}[+] Output folder: ${outdir}/${NC}"

# ---------- Ping Check ----------
echo -e "${YELLOW}[*] Checking if target is alive...${NC}"
ping -c 2 "$target" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[+] Target is UP${NC}"
else
    echo -e "${RED}[-] Target appears DOWN. Still scanning...${NC}"
fi

# ---------- WHOIS ----------
echo -e "${YELLOW}[*] Running WHOIS...${NC}"
if command -v whois &> /dev/null; then
    whois "$target" > "$outdir/whois.txt"
    echo -e "${GREEN}[+] WHOIS saved${NC}"
else
    echo -e "${RED}[-] whois missing. Skipping.${NC}"
fi

# ---------- Subdomain Enumeration ----------
echo -e "${YELLOW}[*] Gathering subdomains...${NC}"
subs_file="$outdir/subdomains.txt"
> "$subs_file"

if command -v subfinder &> /dev/null; then
    subfinder -d "$target" -all -silent >> "$subs_file"
    echo -e "${GREEN}[+] subfinder done${NC}"
else
    echo -e "${RED}[-] subfinder not installed.${NC}"
fi

if command -v assetfinder &> /dev/null; then
    assetfinder --subs-only "$target" >> "$subs_file"
    echo -e "${GREEN}[+] assetfinder done${NC}"
else
    echo -e "${RED}[-] assetfinder not installed.${NC}"
fi

if [ -s "$subs_file" ]; then
    sort -u "$subs_file" -o "$subs_file"
    count=$(wc -l < "$subs_file")
    echo -e "${GREEN}[+] Total unique subdomains: $count${NC}"
else
    echo -e "${YELLOW}[!] No subdomains found.${NC}"
fi

# ---------- Live Subdomain Check ----------
live_file="$outdir/live_subdomains.txt"
if [ -s "$subs_file" ]; then
    echo -e "${YELLOW}[*] Probing live subdomains...${NC}"
    if command -v httpx &> /dev/null; then
        httpx -l "$subs_file" -silent -o "$live_file"
        livecount=$(wc -l < "$live_file" 2>/dev/null || echo 0)
        echo -e "${GREEN}[+] Live subdomains: $livecount${NC}"
    else
        echo -e "${RED}[-] httpx not installed. Skipping live check.${NC}"
    fi
else
    echo -e "${YELLOW}[!] No subdomains to check.${NC}"
fi

# ---------- Nmap ----------
echo -e "${YELLOW}[*] Running Nmap (service + scripts + fast)...${NC}"
if command -v nmap &> /dev/null; then
    if [ -f "$live_file" ] && [ -s "$live_file" ]; then
        nmap -sV -sC -T4 --open -iL "$live_file" -oN "$outdir/nmap_scan.txt"
    else
        nmap -sV -sC -T4 --open "$target" -oN "$outdir/nmap_scan.txt"
    fi
    echo -e "${GREEN}[+] Nmap scan saved${NC}"
else
    echo -e "${RED}[-] nmap missing. Skipping.${NC}"
fi

# ---------- Netcat Quick Port Check ----------
echo -e "${YELLOW}[*] Quick Netcat port check (80,443,22)...${NC}"
if command -v nc &> /dev/null; then
    for port in 80 443 22; do
        nc -zv -w 2 "$target" $port &> /dev/null
        if [ $? -eq 0 ]; then
            echo -e "  ${GREEN}Port $port: OPEN${NC}" | tee -a "$outdir/nc_ports.txt"
        else
            echo -e "  ${RED}Port $port: CLOSED/FILTERED${NC}" | tee -a "$outdir/nc_ports.txt"
        fi
    done
else
    echo -e "${RED}[-] netcat missing.${NC}"
fi

# ---------- WhatWeb ----------
echo -e "${YELLOW}[*] WhatWeb technology detection...${NC}"
if command -v whatweb &> /dev/null; then
    whatweb -a 3 "$target" --color=never -v > "$outdir/whatweb.txt"
    echo -e "${GREEN}[+] WhatWeb results saved${NC}"
else
    echo -e "${RED}[-] whatweb missing.${NC}"
fi

# ---------- Nikto ----------
echo -e "${YELLOW}[*] Nikto quick web scan (may take time)...${NC}"
if command -v nikto &> /dev/null; then
    nikto -h "$target" -ssl -Tuning x -o "$outdir/nikto.txt" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Nikto scan saved${NC}"
    else
        echo -e "${RED}[-] Nikto scan failed (maybe no HTTP service).${NC}"
    fi
else
    echo -e "${RED}[-] nikto not installed.${NC}"
fi

# ---------- Directory Brute-force ----------
echo -e "${YELLOW}[*] Directory busting (auto-selecting best tool)...${NC}"
wordlist="/usr/share/wordlists/dirb/common.txt"
if [ ! -f "$wordlist" ]; then
    echo -e "${RED}[-] Wordlist $wordlist missing. Skipping directory scan.${NC}"
else
    tool_used=""
    if command -v gobuster &> /dev/null; then
        tool_used="gobuster"
        gobuster dir -u "https://$target" -w "$wordlist" -t 40 -x php,html,js -l -e -b 404 -o "$outdir/dirs_gobuster.txt"
    elif command -v ffuf &> /dev/null; then
        tool_used="ffuf"
        ffuf -u "https://$target/FUZZ" -w "$wordlist" -e .php,.html -mc 200,301 -t 50 -o "$outdir/dirs_ffuf.json"
    elif command -v dirsearch &> /dev/null; then
        tool_used="dirsearch"
        dirsearch -u "https://$target" -e php,html,js -t 50 --simple-report="$outdir/dirs_dirsearch.txt"
    elif command -v wfuzz &> /dev/null; then
        tool_used="wfuzz"
        wfuzz -c -u "https://$target/FUZZ" -w "$wordlist" --hc 404 -f "$outdir/dirs_wfuzz.txt" > /dev/null 2>&1
    else
        echo -e "${RED}[-] No directory brute-forcing tool found (gobuster/ffuf/dirsearch/wfuzz).${NC}"
    fi
    if [ -n "$tool_used" ]; then
        echo -e "${GREEN}[+] Directory scan completed using $tool_used${NC}"
    fi
fi

# ---------- Manual Tools Reminder ----------
echo -e "${YELLOW}==========================================${NC}"
echo -e "${YELLOW}      MANUAL TOOLS (NOT AUTO‑RUN)${NC}"
echo -e "${YELLOW}==========================================${NC}"
echo -e "If you find a dynamic parameter, use:"
echo -e "${GREEN}  sqlmap -u \"https://$target/page?id=1\" --batch --dbs${NC}"
echo -e "For SSH brute-force (example):"
echo -e "${GREEN}  hydra -L users.txt -P pass.txt -t 4 ssh://$target${NC}"
echo -e "For Web login brute:"
echo -e "${GREEN}  hydra -l admin -P pass.txt $target http-post-form \"/login:username=^USER^&password=^PASS^:Invalid\"${NC}"

# ---------- Summary ----------
echo -e "${GREEN}===================================${NC}"
echo -e "${GREEN}   DAILY RECON COMPLETED!${NC}"
echo -e "${GREEN}   All results are in: ${outdir}/${NC}"
echo -e "${GREEN}===================================${NC}"
