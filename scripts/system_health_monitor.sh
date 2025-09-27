#!/usr/bin/env bash
# system_health_monitor.sh
# Usage: ./system_health_monitor.sh [-c cpu_threshold] [-m mem_threshold] [-d disk_threshold] [-l logfile]
# Example: ./system_health_monitor.sh -c 80 -m 80 -d 85 -l /var/log/sys_health.log

CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85
LOGFILE="./system_health.log"

while getopts "c:m:d:l:" opt; do
  case "$opt" in
    c) CPU_THRESHOLD="$OPTARG" ;;
    m) MEM_THRESHOLD="$OPTARG" ;;
    d) DISK_THRESHOLD="$OPTARG" ;;
    l) LOGFILE="$OPTARG" ;;
    *) ;;
  esac
done

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

log() {
  echo "$(timestamp) $1" | tee -a "$LOGFILE"
}

# CPU usage (average of 1-minute)
CPU_USAGE=$(top -b -n2 -d0.5 | grep "Cpu(s)" | tail -n1 | awk -F',' '{usage=100-$8}END{printf "%.0f", usage}')
# Alternative: mpstat or /proc/stat based calc
MEM_USAGE=$(free | awk '/Mem/ {printf "%.0f", $3/$2 * 100}')
DISK_USAGE=$(df -h / | awk 'NR==2{gsub("%","",$5); print $5}')

log "INFO - CPU: ${CPU_USAGE}% | MEM: ${MEM_USAGE}% | DISK (root): ${DISK_USAGE}%"

if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
  log "ALERT - CPU usage is ${CPU_USAGE}% which is >= threshold ${CPU_THRESHOLD}%"
fi

if [ "$MEM_USAGE" -ge "$MEM_THRESHOLD" ]; then
  log "ALERT - Memory usage is ${MEM_USAGE}% which is >= threshold ${MEM_THRESHOLD}%"
fi

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
  log "ALERT - Disk usage is ${DISK_USAGE}% which is >= threshold ${DISK_THRESHOLD}%"
fi

# Top 5 CPU processes
log "Top 5 CPU processes:"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | sed '1d' | tee -a "$LOGFILE"
