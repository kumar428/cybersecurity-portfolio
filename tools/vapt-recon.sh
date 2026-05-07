#!/bin/bash

# ==========================================
# VAPT RECON TOOL
# Author: Kumar Palanivelu
# Purpose: Beginner VAPT Automation Tool
# ==========================================

echo "==================================="
echo "      VAPT RECON TOOL STARTING"
echo "==================================="

read -p "Enter Target IP: " target

mkdir -p results

echo "[+] Checking target..."

ping -c 2 $target > /dev/null

if [ $? -eq 0 ]; then
    echo "[+] Target is UP"
else
    echo "[-] Target is DOWN"
    exit
fi

echo "[+] Running Nmap scan..."

nmap -sC -sV $target -oN results/nmap.txt

echo "[+] Fetching HTTP headers..."

curl -I http://$target > results/http_headers.txt 2>/dev/null

echo "[+] Extracting open ports..."

grep open results/nmap.txt > results/open_ports.txt

echo "==================================="
echo "SCAN COMPLETED"
echo "Results saved in results/"
echo "==================================="
