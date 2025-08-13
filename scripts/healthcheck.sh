#!/bin/bash

# Healthcheck script for the SOC-Lab environment
# This script checks if the main services are accessible via their web interfaces.

echo "--- SOC-Lab Healthcheck ---"
echo "This script will check the status of all major services."
echo ""

# Function to check a URL and report status
check_service() {
  local name=$1
  local url=$2
  local params=$3

  printf "Checking ${name} at ${url}... "

  # Perform a silent curl, follow redirects (-L), and fail on HTTP errors (-f)
  # We check for the exit code of curl to determine success.
  if curl -s -L -f ${params} "${url}" > /dev/null; then
    printf "\e[32mONLINE\e[0m\n" # Green for ONLINE
  else
    printf "\e[31mOFFLINE\e[0m\n" # Red for OFFLINE
  fi
}

# --- Service Checks ---

# TheHive
check_service "TheHive" "http://localhost:9000"

# Cortex
check_service "Cortex" "http://localhost:9001"

# MinIO Console
check_service "MinIO Console" "http://localhost:9003"

# MISP (on port 8443, with self-signed certificate)
check_service "MISP" "https://localhost:8443" "-k" # -k allows insecure connections

echo ""
echo "--- Healthcheck Complete ---"
echo "Please check the status of each service above."
echo "If all services are ONLINE, the deployment is likely successful."
echo "You can now access the services at their respective URLs."
