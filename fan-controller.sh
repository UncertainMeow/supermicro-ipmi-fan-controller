#!/bin/bash

set -e

IPMI_HOST="${IPMI_HOST:-local}"
IPMI_USER="${IPMI_USER:-ADMIN}"
IPMI_PASS="${IPMI_PASS:-ADMIN}"
FAN_MODE="${FAN_MODE:-optimal}"
FALLBACK_FAN_MODE="${FALLBACK_FAN_MODE:-full}"
CPU_TEMPERATURE_THRESHOLD="${CPU_TEMPERATURE_THRESHOLD:-60}"
CHECK_INTERVAL="${CHECK_INTERVAL:-60}"
VERBOSE="${VERBOSE:-false}"

log() {
  [ "$VERBOSE" = "true" ] && echo "$(date): $*"
}

ipmi_cmd() {
  if [ "$IPMI_HOST" = "local" ]; then
    ipmitool "$@"
  else
    ipmitool -I lanplus -H "$IPMI_HOST" -U "$IPMI_USER" -P "$IPMI_PASS" "$@"
  fi
}

get_max_cpu_temp() {
  ipmi_cmd sensor | grep -i 'CPU' | grep -i 'Temp' | awk '{print $(NF-1)}' | sort -nr | head -n1
}

set_fan_mode_raw() {
  local MODE="$1"
  local CMD1=""
  local CMD2=""
  case "$MODE" in
    optimal) CMD="raw 0x30 0x45 0x01 0x02" ;;
    standard) CMD="raw 0x30 0x45 0x01 0x00" ;;
    full) CMD="raw 0x30 0x45 0x01 0x01" ;;
    manual:*)
      PERCENT=$(echo "$MODE" | cut -d: -f2)
      HEX=$(printf '0x%02x' "$PERCENT")
      CMD1="raw 0x30 0x45 0x01 0x01"
      CMD2="raw 0x30 0x70 0x66 0x01 0x00 0x30 0x00 $HEX"
      ;;
    *)
      echo "Invalid fan mode: $MODE"
      exit 1
      ;;
  esac

  [ -n "$CMD1" ] && ipmi_cmd $CMD1
  [ -n "$CMD" ] && ipmi_cmd $CMD
  [ -n "$CMD2" ] && ipmi_cmd $CMD2
}

while true; do
  CURRENT_TEMP=$(get_max_cpu_temp)
  log "Current max CPU temp: ${CURRENT_TEMP}°C"

  if [ "$CURRENT_TEMP" -ge "$CPU_TEMPERATURE_THRESHOLD" ]; then
    log "🔥 Temp exceeds threshold ($CPU_TEMPERATURE_THRESHOLD°C) → using fallback fan mode: $FALLBACK_FAN_MODE"
    set_fan_mode_raw "$FALLBACK_FAN_MODE"
  else
    log "🌡️ Temp below threshold → using normal fan mode: $FAN_MODE"
    set_fan_mode_raw "$FAN_MODE"
  fi

  sleep "$CHECK_INTERVAL"
done
