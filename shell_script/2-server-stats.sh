#!/bin/bash
while true; do
    IDLE=$(top -n 1 | awk '/Cpu/{print $8}')
    echo "["${IDLE}"]"
    [[ "$IDLE" = *id* ]] || break
done
echo CPU utilisé :$(echo 100 ${IDLE} | awk '{print $1 - $2}') %