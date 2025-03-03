#!/bin/bash
while true; do
    IDLE=$(top -n 1 | awk '/Cpu/{print $8}')
    echo "["${IDLE}"]"
    [[ "$IDLE" = *id* ]] || break
done
echo CPU utilisé :$(echo 100 ${IDLE} | awk '{print $1 - $2}') %


MEMORY_USED_READABLE=$(free -h -t | awk '/Total:/{print $3}')
MEMORY_FREE_READABLE=$(free -h -t | awk '/Total:/{print $4}')
TOTAL_MEMORY=$(free -t | awk '/Total:/{print $2}')
MEMORY_USED=$(free -t | awk '/Total:/{print $3}')
MEMORY_FREE=$(free -t | awk '/Total:/{print $4}')
echo "Total Memory : " $TOTAL_MEMORY
echo "Memory Used : " $MEMORY_USED_READABLE "("$(echo $MEMORY_USED $TOTAL_MEMORY | awk '{printf "%.2f",($1 / $2)*100}')%")"
echo "Memory free : " $MEMORY_FREE_READABLE "("$(echo $MEMORY_FREE $TOTAL_MEMORY | awk '{printf "%.2f",($1 / $2)*100}')%")"

function DF_on_mount {
        local MOUNT=$1
        local DISK_USED_READABLE=$(df -h --total $MOUNT| awk '/total/{print $3}')
        local DISK_FREE_READABLE=$(df -h --total $MOUNT| awk '/total/{print $4}')
        local TOTAL_DISK_READABLE=$(df -h --total $MOUNT| awk '/total/{print $2}')
        local TOTAL_DISK=$(df --total $MOUNT| awk '/total/{print $2}')
        local DISK_USED=$(df --total $MOUNT| awk '/total/{print $3}')
        local DISK_FREE=$(df --total $MOUNT| awk '/total/{print $4}')
        [ -z "$MOUNT" ] && MOUNT="Global"
        echo "------" $MOUNT "-------"
        echo "Total Disk : " $TOTAL_DISK_READABLE
        echo "Disk Used : " $DISK_USED_READABLE "("$(echo $DISK_USED $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
        echo "Disk free : " $DISK_FREE_READABLE "("$(echo $DISK_FREE $TOTAL_DISK | awk '{printf "%.2f", ($1 / $2)*100}')%")"
    
}
DF_on_mount

DISK_TO_PARSE=(/ /tmp)

for i in "${DISK_TO_PARSE[@]}"
do 
    echo "$i"
    df -h --total $i
    DF_on_mount $i
done

ps -eo pid,tty,time,cmd,%mem,%cpu --sort=-%mem | head -6
ps -eo pid,tty,time,cmd,%mem,%cpu --sort=-%cpu | head -6
