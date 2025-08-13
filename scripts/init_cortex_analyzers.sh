#!/bin/sh
set -e

CORTEX_URL="http://cortex:9001/api"
# The API key for the org admin, which we've defined in the .env file
API_KEY=${CORTEX_API_KEY_FOR_THEHIVE}

echo "Waiting for Cortex to be available at ${CORTEX_URL}..."

# Wait for Cortex API to be responsive
until curl -s -f "${CORTEX_URL}/status" > /dev/null; do
  echo "Cortex not ready yet, retrying in 10 seconds..."
  sleep 10
done

echo "Cortex API is up."

# Give it a few more seconds to fully initialize its internal state
sleep 5

echo "Enabling analyzers..."

# List of analyzers to enable that do not require an API key
ANALYZERS_TO_ENABLE="FileInfo_1_0 PE_Info_1_0"

# Get all available analyzers and parse the JSON with `sh` and `grep/sed`
# A container with `jq` would be easier, but we'll stick to basic tools
ANALYZER_LIST_JSON=$(curl -s -H "Authorization: Bearer ${API_KEY}" "${CORTEX_URL}/analyzer")

for ANALYZER_NAME in ${ANALYZERS_TO_ENABLE}; do
  echo "Processing analyzer: ${ANALYZER_NAME}"

  # Extract the ID of the analyzer from the JSON response
  ANALYZER_ID=$(echo "${ANALYZER_LIST_JSON}" | grep -o '{[^}]*"name":"'"${ANALYZER_NAME}"'","id":"[^"]*"' | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

  if [ -n "${ANALYZER_ID}" ]; then
    echo "Found analyzer ${ANALYZER_NAME} with ID: ${ANALYZER_ID}. Enabling it..."

    # Enable the analyzer by its ID
    curl -s -f -X POST \
      -H "Authorization: Bearer ${API_KEY}" \
      -H "Content-Type: application/json" \
      "${CORTEX_URL}/analyzer/${ANALYZER_ID}/enable"

    if [ $? -eq 0 ]; then
      echo "Successfully enabled ${ANALYZER_NAME}."
    else
      echo "Failed to enable ${ANALYZER_NAME}."
    fi
  else
    echo "WARNING: Analyzer ${ANALYZER_NAME} not found in Cortex."
  fi
done

echo "Cortex analyzer initialization complete."
exit 0
