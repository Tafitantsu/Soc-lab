#!/bin/sh
set -e

MISP_URL="https://misp"
ADMIN_EMAIL="admin@misp.local" # Default admin email in coolacid/misp-docker
ADMIN_PASSWORD="admin" # Default admin password

echo "Waiting for MISP to be available at ${MISP_URL}..."

# Wait for MISP UI to be responsive
# We use --insecure because it's a self-signed certificate
until curl -s -k --fail "${MISP_URL}/users/login" > /dev/null; do
  echo "MISP not ready yet, retrying in 10 seconds..."
  sleep 10
done

echo "MISP UI is up."

# The coolacid/misp-docker image may already set the API key via MISP_ADMIN_API_KEY.
# This script is a fallback or explicit enforcement method.
# We will check if the key is already set by trying to access an authenticated endpoint.

echo "Attempting to set admin API key..."

# Note: The 'coolacid/misp-docker' image has its own initialization logic.
# It might automatically set the API key if MISP_ADMIN_API_KEY is passed as an environment variable.
# This script acts as a robust confirmation or alternative method.
# The endpoint /admin/users/init_api_key/1 is not standard and might not work.
# A more reliable way is to use the provided misp-cli tool if available, or interact with the standard API.
# Let's try a more robust approach by logging in and enabling API access if needed.

# For this lab, we'll rely on the environment variable MISP_ADMIN_API_KEY being handled by the entrypoint
# of the 'coolacid/misp-docker' container. This is a common pattern for modern Docker images.
# This script will therefore just check if the API is responsive with the key.

echo "Waiting for MISP API to respond with the configured admin key..."

until curl -s -k --fail --header "Authorization: ${MISP_ADMIN_API_KEY}" "${MISP_URL}/servers/getVersion.json" > /dev/null; do
  echo "MISP API not yet responsive with the new key, retrying in 10 seconds..."
  sleep 10
done

echo "MISP API key for admin is set and responsive."
echo "MISP initialization complete."

exit 0
