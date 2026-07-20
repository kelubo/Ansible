#!/bin/bash

# ============================================
# Dynamic MOTD (Message of the Day)
# ============================================
# 功能：登录后显示系统状态信息
# 特点：使用颜色输出，提高可读性

# ---------------------------
# 颜色定义
# ---------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ---------------------------
# 获取系统信息
# ---------------------------
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
        hostname -I 2>/dev/null | tr ' ' '\n' | grep -v '^127.' | head -1 || echo "N/A"
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

# ---------------------------
# 主程序
# ---------------------------
RELEASE_INFO=$(get_release)
KERNEL_INFO=$(uname -r)
HOSTNAME_INFO=$(uname -n)
USERNAME_INFO=$(whoami)
IP_INFO=$(get_ip)
LOGIN_USERS_INFO=$(users | wc -w)
UPTIME_INFO=$(get_uptime)
CPU_CORES=$(get_cpu_cores)

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

# ---------------------------
# 输出格式
# ---------------------------
echo ""
echo -e "${BLUE}=========================================================================================${NC}"
echo -e "${CYAN}  System Information${NC}"
echo -e "${BLUE}=========================================================================================${NC}"
echo -e "${YELLOW}  Release${NC}.............: ${GREEN}$RELEASE_INFO${NC}"
echo -e "${YELLOW}  Kernel${NC}..............: ${GREEN}$KERNEL_INFO${NC}"
echo -e "${YELLOW}  Hostname${NC}............: ${GREEN}$HOSTNAME_INFO${NC}"
echo -e "${YELLOW}  Username${NC}............: ${GREEN}$USERNAME_INFO${NC}"
echo -e "${YELLOW}  IP Address${NC}..........: ${GREEN}$IP_INFO${NC}"
echo -e "${YELLOW}  Login Users${NC}.........: ${GREEN}$LOGIN_USERS_INFO user(s)${NC}"
echo -e "${YELLOW}  Uptime${NC}..............: ${GREEN}$UPTIME_INFO${NC}"
echo -e "${YELLOW}  CPU Cores${NC}...........: ${GREEN}$CPU_CORES${NC}"
echo -e "${BLUE}-----------------------------------------------------------------------------------------${NC}"
echo -e "${YELLOW}  CPU Load${NC}............: ${CYAN}$LOAD1 - $LOAD5 - $LOAD15${NC} (1-5-15 min)"
echo -e "${YELLOW}  Memory${NC}..............: ${CYAN}$MEMORY${NC}"

if [ "$MEM_USAGE" -gt 80 ]; then
    echo -e "${YELLOW}  Memory Usage${NC}........: ${RED}$MEM_USAGE%${NC}"
else
    echo -e "${YELLOW}  Memory Usage${NC}........: ${GREEN}$MEM_USAGE%${NC}"
fi

echo -e "${YELLOW}  Root Disk${NC}............: ${CYAN}$DISK${NC}"

if [ "$DISK_USAGE" -gt 80 ]; then
    echo -e "${YELLOW}  Disk Usage${NC}..........: ${RED}$DISK_USAGE%${NC}"
else
    echo -e "${YELLOW}  Disk Usage${NC}..........: ${GREEN}$DISK_USAGE%${NC}"
fi

echo -e "${BLUE}-----------------------------------------------------------------------------------------${NC}"
echo -e "${CYAN}  Memory Details:${NC}"
echo "$MEMORY_INFO" | grep -E "^(Mem|Swap)" | awk '{printf "    %-10s %-8s %-8s %-8s %-8s %-8s\n", $1, $2, $3, $4, $5, $6}'
echo -e "${CYAN}  Disk Details:${NC}"
echo "$FULL_DISK_INFO"
echo -e "${BLUE}=========================================================================================${NC}"
echo ""