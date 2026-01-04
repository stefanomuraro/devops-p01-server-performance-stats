#!/bin/bash

# Force the script to use periods (.) for decimals
export LC_NUMERIC=C

echo "------------------------------------------"
echo " SERVER PERFORMANCE STATS"
echo " Date: $(date)"
echo "------------------------------------------"

echo -e "\n--- System Information ---"
echo "OS Version:       $(hostnamectl | grep "Operating System" | cut -d: -f2 | xargs)"
echo "Kernel:           $(uname -r)"
echo "Uptime:           $(uptime -p)"
echo "CPU Model Name:   $(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)"
echo "Physical Cores:   $(lscpu | awk '/Core\(s\) per socket/ {c=$4} /Socket\(s\)/ {s=$2} END {print c*s}')"
echo "Threads Per Core: $(lscpu | awk '/Thread\(s\) per core/ {print $4}')"
echo "Logical Cores:    $(nproc)"
echo "Total Memory:     $(free -h | awk '/^Mem:/ {print $2}')"

echo -e "\n--- Security ---"
echo "Logged Users:  $(who | wc -l)"
if [ -f /var/log/auth.log ]; then
    failed_logins=$(grep "password check failed" /var/log/auth.log | wc -l)
    echo "Failed login attempts: $failed_logins"
fi

echo -e "\n--- Total CPU Usage ---"
echo "Used: $(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8 "%"}')"
echo "Load Average: $(uptime | awk -F'load average:' '{ print $2 }' | xargs)"
echo "               (Intervals: 1 min, 5 min, 15 min)"

echo -e "\n--- Total Memory Usage ---"
free -m | awk 'NR==2{printf "Total: %sMB | Used: %sMB | Free: %sMB | Usage: %.2f%%\n", $2, $3, $4, $3*100/$2}'

echo -e "\n--- Total Disk Usage ---"
df -h --total | grep 'total' | awk '{printf "Total: %s | Used: %s | Free: %s | Usage: %s\n", $2, $3, $4, $5}'

echo -e "\n--- Top 5 Processes by CPU Usage ---"
ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -n 6

echo -e "\n--- Top 5 Processes by Memory Usage ---"
ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 6

echo "------------------------------------------"
