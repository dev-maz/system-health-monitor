#!/usr/bin/env bash

LOG_FILE="./health.log"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=90

ENABLE_LOGGING=true

for arg in "$@"; do
    case "$arg" in
        --no-log)
            ENABLE_LOGGING=false
            ;;
        --help | -h)
            echo "Usage: $0 [--no-log]"
            echo "  --no-log  Disable logging to file"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}

get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}'
}

get_memory_usage() {
    free | awk '/Mem:/ { printf "%.2f", $3/$2 * 100 }'
}

get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | tr -d '%'
}

log_health() {
    CPU=$(get_cpu_usage)
    MEM=$(get_memory_usage)
    DISK=$(get_disk_usage)
    WARNINGS=""

    (( ${CPU%.*} > CPU_THRESHOLD )) && WARNINGS+=" CPU_HIGH"
    (( ${MEM%.*} > MEM_THRESHOLD )) && WARNINGS+=" MEM_HIGH"
    (( $DISK > DISK_THRESHOLD )) && WARNINGS+=" DISK_HIGH"

    OUTPUT="$(timestamp) | CPU: ${CPU}% | MEM: ${MEM}% | DISK: ${DISK}% ${WARNINGS}"

    echo "$OUTPUT"
    if [ "$ENABLE_LOGGING" = true ]; then
    echo "$OUTPUT" >> "$LOG_FILE"
    fi
}

log_health