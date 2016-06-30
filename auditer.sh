#!/bin/bash

trap "{ kill %1 2>/dev/null && print_loc \"\n[-] Ctrl-C pressed. Exiting current program.\" \
|| echo \" [-] Please answer y/n first...\"; }" INT

# COLORS
REDCOL="\e[31m"
GREENCOL="\e[32m"
BLUECOL="\e[34m"
YELLCOL="\e[33m"
UNDERCOL="\e[4m"
BOLDCOL="\e[1m"
NOCOL="\e[0m"

# SCRIPT CONFIG
host="$1"
ask=false

function print_loc {
 printf "$1\n"
}

function runprog {
 prog=$(echo "$1" | cut -d ' ' -f1)
 args=$(echo "$1" | cut -d ' ' -f2-)
 $ask && printf "[?] Run ${BOLDCOL}$prog $args${NOCOL} (y/N)? " && read -e

 if [[ $ask = false || $REPLY =~ ^[Yy]$ ]]; then
  prog=$(which "$prog")
  if  [[ -n "$prog" ]]; then
   print_loc "[+] Running: ${GREENCOL}${BOLDCOL}$prog $args${NOCOL}"
   print_loc "${YELLCOL}${BOLDCOL}============= ${UNDERCOL}$1${NOCOL}${YELLCOL}${BOLDCOL} ================${NOCOL}"
   $prog $args
   print_loc "${YELLCOL}${BOLDCOL}================== END OF OUTPUT ====================\n${NOCOL}"
  else
   print_loc "[-] Not found $prog."
  fi
 fi
}

print_loc "\n${BLUECOL}${BOLDCOL}=========== AUDITER ===========>${NOCOL} n30m1nd @ github\n"

if [[ -z "$host" ]]; then
 print_loc "${REDCOL}${BOLDCOL}[-] No host specified... ${NOCOL}"
 print_loc "[i] Usage: $0 host"
 exit
fi

hostip="$(host $host | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")"
print_loc "[+] Using host: ${REDCOL}${BOLDCOL}$host${NOCOL}"
print_loc "[+] Host's IP:  ${REDCOL}${BOLDCOL}$hostip${NOCOL}"


print_loc "[+] Information gathering, clicky clicky..."
if [[ -n "$hostip" ]]; then
 print_loc "[+] ${YELLCOL}${BOLDCOL}============= OPEN PORTS ============${NOCOL}"
 print_loc "[+] ${BOLDCOL}${GREENCOL}SHODAN${NOCOL} ${UNDERCOL}https://www.shodan.io/host/$hostip${NOCOL}"
 print_loc "[+] ${BOLDCOL}${GREENCOL}CENSYS${NOCOL} ${UNDERCOL}https://censys.io/ipv4/$hostip${NOCOL}"
 print_loc "[+] ${YELLCOL}${BOLDCOL}============== VHOSTS  ==============${NOCOL}"
 print_loc "[+] ${BOLDCOL}${GREENCOL}BINGIP${NOCOL} ${UNDERCOL}https://www.bing.com/search?q=ip:$hostip${NOCOL}"
fi

read -p "[?] Ask yes/no before each program runs (y/N)? " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
 ask=true
fi

# ADD YOUR PROGRAMS TO RUN HERE, FORMAT:
# runprog "program_name" "arguments $host"
runprog "curl -vv http://$hostip:443" 
runprog "nmap -sT --top-ports 100 $host"
runprog "nikto -host $host"
runprog "dirb http://$host /usr/share/wordlists/dirb/big.txt"
# END OF PROGRAMS SECTION


