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
