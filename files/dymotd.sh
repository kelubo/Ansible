# System load
    LOAD1=`cat /proc/loadavg | awk {'print $1'}`
    LOAD5=`cat /proc/loadavg | awk {'print $2'}`
    LOAD15=`cat /proc/loadavg | awk {'print $3'}`

MEMORY=`free -mh | grep "Mem" | awk '{print "used:",$3,"/",$2,"( free: ",$4,")"}'`
MEM_USAGE=`free -m | grep "Mem" | awk '{printf("%3.1f%%", (($3/$2)*100))}'`
DISK=`df -Ph / | awk '/\// {print "used:",$3,"/",$2," ( free:",$4,")"}'`
DISK_USAGE=`df -h / | awk '/\// {print $5}'|grep -v "^$"`

echo "
=========================================================================================
- Release.............: `cat /etc/redhat-release`
- Kernel..............: `uname -r`
- Hostname............: `uname -n`
- Username............: `whoami`
- IP..................: `hostname -I`
- Login Users.........: Total `users | wc -w` user(s)
=========================================================================================
- CPU usage...........: $LOAD1 - $LOAD5 - $LOAD15 (1-5-15 min)
- Memory..............: $MEMORY
- Memory usage........: $MEM_USAGE
=========================================================================================
- Mem info:
`free -mh`

- Disk info:
`df -h`
=========================================================================================
"
