# Supermicro IPMI Fan Controller (Docker)

A Docker container that sets and maintains Supermicro server fan profiles using IPMI commands. Inspired by [tigerblue77's Dell iDRAC fan controller](https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker).

## Features

- Set `optimal`, `standard`, `full`, or `manual:<percent>` fan mode
- Monitor CPU temperature via `ipmitool sensor`
- Automatically switches to `FALLBACK_FAN_MODE` if temp exceeds threshold

## Usage

### Docker CLI
```bash
docker run -d \
  --name supermicro-fan-controller \
  --restart unless-stopped \
  -e IPMI_HOST=192.168.1.100 \
  -e IPMI_USER=ADMIN \
  -e IPMI_PASS=ADMIN \
  -e FAN_MODE=manual:20 \
  -e FALLBACK_FAN_MODE=full \
  -e CPU_TEMPERATURE_THRESHOLD=60 \
  -e CHECK_INTERVAL=30 \
  -e VERBOSE=true \
  ghcr.io/YOUR_GITHUB_USERNAME/supermicro-fan-controller:latest

Docker Compose
Use the provided docker-compose.yml.

Environment Variables
Name	Description	Default
IPMI_HOST	Supermicro IPMI IP or "local"	local
IPMI_USER	IPMI username	ADMIN
IPMI_PASS	IPMI password	ADMIN
FAN_MODE	Fan profile: optimal, standard, full, manual:20	optimal
FALLBACK_FAN_MODE	Emergency mode when hot	full
CPU_TEMPERATURE_THRESHOLD	Degrees Celsius before fallback	60
CHECK_INTERVAL	Seconds between checks	60
VERBOSE	Log each loop	false
