#!/bin/bash

# ============================================
# Dynamic MOTD (Message of the Day)
# ============================================
# 功能：登录后显示系统状态信息
# 特点：跨平台兼容，根据操作系统显示相应信息

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

detect_os() {
    if [ -f /etc/redhat-release ]; then
        echo "redhat"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/os-release ]; then
        if grep -qi "centos\|rhel\|xcp-ng\|anolis" /etc/os-release; then
            echo "redhat"
        elif grep -qi "ubuntu\|debian" /etc/os-release; then
            echo "debian"
        else
            echo "unknown"
        fi
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)

get_release() {
    if [ -f /etc/redhat-release ]; then
        cat /etc/redhat-release
    elif [ -f /etc/os-release ]; then
        grep PRETTY_NAME /etc/os-release | sed 's/PRETTY_NAME=//;s/"//g'
    else
        echo "Unknown OS"
    fi
}

get_ip() {
    if command -v hostname &>/dev/null; then
        hostname -I 2>/dev/null | tr ' ' '\n' | grep -v '^127.' | head -1 || hostname -i 2>/dev/null | tr ' ' '\n' | grep -v '^127.' | head -1 || echo "N/A"
    elif command -v ip &>/dev/null; then
        ip addr show | grep inet | grep -v '127.' | grep -v '::1' | head -1 | awk '{print $2}' | cut -d'/' -f1
    else
        echo "N/A"
    fi
}

get_uptime() {
    uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | sed 's/,//'
}

get_cpu_cores() {
    nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo || echo "N/A"
}

get_memory_usage() {
    local total available percent
    read total available <<< $(free -b | grep Mem | awk '{print $2, $7}')
    percent=$(( (total - available) * 100 / total ))
    printf "%d" $percent
}

get_disk_usage() {
    df -h / 2>/dev/null | grep -v Filesystem | awk '{print $5}' | sed 's/%//'
}

get_updates() {
    local updates=0

    if [ "$OS_TYPE" = "debian" ] && command -v apt &>/dev/null; then
        updates=$(apt list --upgradable 2>/dev/null | grep -v "^Listing" | grep -v "^$" | wc -l)
    elif [ "$OS_TYPE" = "redhat" ] && command -v yum &>/dev/null; then
        updates=$(yum check-update 2>/dev/null | grep -v '^$' | grep -v 'Loaded plugins' | grep -v 'base\|updates\|extras\|epel' | wc -l)
    elif [ "$OS_TYPE" = "redhat" ] && command -v dnf &>/dev/null; then
        updates=$(dnf check-update 2>/dev/null | grep -v '^$' | grep -v 'Last metadata' | grep -v 'base\|updates\|extras\|epel' | wc -l)
    fi

    echo "$updates"
}

get_last_reboot() {
    if command -v last &>/dev/null; then
        last reboot -1 2>/dev/null | head -1 | awk '{print $5,$6,$7,$8}' | grep -v '^$' || echo "N/A"
    elif [ -f /var/log/wtmp ]; then
        last reboot -1 2>/dev/null | head -1 | awk '{print $5,$6,$7,$8}' | grep -v '^$' || echo "N/A"
    else
        echo "N/A"
    fi
}

get_process_count() {
    ps aux 2>/dev/null | wc -l || echo "N/A"
}

get_load_percent() {
    if ! command -v bc &>/dev/null; then
        echo "N/A"
        return
    fi

    local load1=$(cat /proc/loadavg | awk '{print $1}')
    local cores=$(get_cpu_cores)
    if [ "$cores" != "N/A" ] && [ "$cores" -gt 0 ]; then
        echo "scale=1; $load1 / $cores * 100" | bc
    else
        echo "N/A"
    fi
}

get_last_logins() {
    if ! command -v last &>/dev/null; then
        return
    fi

    last -5 2>/dev/null | grep -v '^$' | grep -v 'wtmp begins' | head -3 | awk '{printf "%-12s %-20s %-30s\n", $1, $2, $3" "$4" "$5" "$6" "$7" "$8}'
}

RELEASE_INFO=$(get_release)
KERNEL_INFO=$(uname -r)
HOSTNAME_INFO=$(uname -n)
USERNAME_INFO=$(whoami)
IP_INFO=$(get_ip)
LOGIN_USERS_INFO=$(users | wc -w)
UPTIME_INFO=$(get_uptime)
CPU_CORES=$(get_cpu_cores)
PROCESS_COUNT=$(get_process_count)
LOAD_PERCENT=$(get_load_percent)
UPDATES_COUNT=$(get_updates)
LAST_REBOOT=$(get_last_reboot)

LOAD_INFO=$(cat /proc/loadavg)
LOAD1=$(echo "$LOAD_INFO" | awk '{print $1}')
LOAD5=$(echo "$LOAD_INFO" | awk '{print $2}')
LOAD15=$(echo "$LOAD_INFO" | awk '{print $3}')

MEMORY_INFO=$(free -mh)
MEMORY=$(echo "$MEMORY_INFO" | grep "Mem" | awk '{print "used:",$3,"/",$2,"(free:",$7,")"}')
MEM_USAGE=$(get_memory_usage)

DISK_INFO=$(df -Ph /)
DISK=$(echo "$DISK_INFO" | awk '/\// {print "used:",$3,"/",$2,"(free:",$4,")"}')
DISK_USAGE=$(get_disk_usage)

FULL_DISK_INFO=$(df -h)

echo ""
echo -e "${BLUE}=========================================================================================${NC}"
echo -e "${CYAN}  System Information${NC}"
echo -e "${BLUE}=========================================================================================${NC}"
echo -e "${YELLOW}  Release${NC}.............: ${GREEN}$RELEASE_INFO${NC}"
echo -e "${YELLOW}  Kernel${NC}..............: ${GREEN}$KERNEL_INFO${NC}"
echo -e "${YELLOW}  Hostname${NC}............: ${GREEN}$HOSTNAME_INFO${NC}"
echo -e "${YELLOW}  Username${NC}............: ${GREEN}$USERNAME_INFO${NC}"
echo -e "${YELLOW}  IP Address${NC}..........: ${GREEN}$IP_INFO${NC}"
echo -e "${YELLOW}  Uptime${NC}..............: ${GREEN}$UPTIME_INFO${NC}"

if [ "$LAST_REBOOT" != "N/A" ]; then
    echo -e "${YELLOW}  Last Reboot${NC}.........: ${GREEN}$LAST_REBOOT${NC}"
fi

echo -e "${YELLOW}  CPU Cores${NC}...........: ${GREEN}$CPU_CORES${NC}"

if [ "$PROCESS_COUNT" != "N/A" ]; then
    echo -e "${YELLOW}  Processes${NC}...........: ${GREEN}$PROCESS_COUNT${NC}"
fi

echo -e "${YELLOW}  Login Users${NC}.........: ${GREEN}$LOGIN_USERS_INFO user(s)${NC}"

if [ "$UPDATES_COUNT" -gt 0 ] 2>/dev/null; then
    echo -e "${YELLOW}  Available Updates${NC}...: ${RED}$UPDATES_COUNT${NC}"
elif [ "$UPDATES_COUNT" = 0 ]; then
    echo -e "${YELLOW}  Available Updates${NC}...: ${GREEN}0${NC}"
fi

echo -e "${BLUE}-----------------------------------------------------------------------------------------${NC}"
echo -e "${YELLOW}  CPU Load${NC}............: ${CYAN}$LOAD1 - $LOAD5 - $LOAD15${NC} (1-5-15 min)"

if [ "$LOAD_PERCENT" != "N/A" ]; then
    echo -e "${YELLOW}  CPU Load%${NC}...........: ${CYAN}$LOAD_PERCENT%${NC}"
fi

echo -e "${YELLOW}  Memory${NC}..............: ${CYAN}$MEMORY${NC}"

if [ "$MEM_USAGE" -gt 80 ] 2>/dev/null; then
    echo -e "${YELLOW}  Memory Usage${NC}........: ${RED}$MEM_USAGE%${NC}"
else
    echo -e "${YELLOW}  Memory Usage${NC}........: ${GREEN}$MEM_USAGE%${NC}"
fi

echo -e "${YELLOW}  Root Disk${NC}............: ${CYAN}$DISK${NC}"

if [ "$DISK_USAGE" -gt 80 ] 2>/dev/null; then
    echo -e "${YELLOW}  Disk Usage${NC}..........: ${RED}$DISK_USAGE%${NC}"
else
    echo -e "${YELLOW}  Disk Usage${NC}..........: ${GREEN}$DISK_USAGE%${NC}"
fi

echo -e "${BLUE}-----------------------------------------------------------------------------------------${NC}"

if command -v last &>/dev/null; then
    echo -e "${CYAN}  Recent Logins:${NC}"
    get_last_logins || echo "    N/A"
    echo ""
fi

echo -e "${CYAN}  Memory Details:${NC}"
echo "$MEMORY_INFO" | grep -E "^(Mem|Swap)" | awk '{printf "    %-10s %-8s %-8s %-8s %-8s %-8s\n", $1, $2, $3, $4, $5, $6}'
echo -e "${CYAN}  Disk Details:${NC}"
echo "$FULL_DISK_INFO"
echo -e "${BLUE}=========================================================================================${NC}"
echo ""