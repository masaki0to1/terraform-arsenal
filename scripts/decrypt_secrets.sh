#!/bin/bash

# Read JSON input from stdin
read input

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq to continue." >&2
    exit 1
fi

# Parse JSON input to get arguments
AWS_PROFILE=$(echo "$input" | jq -r '.aws_profile')
ENV=$(echo "$input" | jq -r '.env')
SECRET_NAME=$(echo "$input" | jq -r '.secret_name')

# Directory for credential files
CRED_DIR="../credential_files/$ENV"
INPUT_FILE=".encrypted_${SECRET_NAME}"
OUTPUT_FILE="${CRED_DIR}/.decrypted_${SECRET_NAME}"

# Full path for encrypted files
if [ -n "${SECRET_NAME}" ]; then
  FILE_PATH="${CRED_DIR}/${INPUT_FILE}"
else
  echo "Failed to decrypt: SECRET_NAME is missing" >&2
  exit 1
fi

if [ "${AWS_PROFILE}" != "" ]; then
  PROFILE_CONTEXT="--profile ${AWS_PROFILE}"
else
  PROFILE_CONTEXT=""
fi

# Ensure filesystem cache is cleared before reading files
sync
if [ -f /proc/sys/vm/drop_caches ]; then
    echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
fi

# Find the latest encrypted file
LATEST_ENCRYPTED_FILE=$(ls -t "${FILE_PATH}_20"* | head -n1)

if [ -z "$LATEST_ENCRYPTED_FILE" ]; then
  echo "Failed to decrypt: No encrypted file found for ${SECRET_NAME}" >&2
  echo "Please check if the FILE_PATH ${FILE_PATH} exists." >&2
  exit 1
else
  echo "Found encrypted file: ${LATEST_ENCRYPTED_FILE}" >&2
fi

# Decrypt the ecrypted data
ENCB64=$(cat "${LATEST_ENCRYPTED_FILE}")

TIMESTAMP=$(date +%Y%m%d_%H%M%S%N)
TMP_FILE="${CRED_DIR}/.tmp_${SECRET_NAME}_${TIMESTAMP}"

echo "$ENCB64" | base64 -d > "${TMP_FILE}"

DECRYPTED=$(aws kms decrypt --ciphertext-blob fileb://"${TMP_FILE}" --output text --query Plaintext ${PROFILE_CONTEXT} | base64 -d | tr -d '\n')

if [ $? -ne 0 ]; then
  echo "Failed to decrypt ${SECRET_NAME}" >&2
  rm "${TMP_FILE}"
  exit 1
fi

# Output decrypted file
# echo -n "${DECRYPTED}" > "${OUTPUT_FILE}"
echo "${SECRET_NAME} = \"${DECRYPTED}\"" > "${OUTPUT_FILE}"

# Clean up temporary file
rm "${TMP_FILE}"

# Output the result as JSON
# jq -n --arg key "decrypted_${SECRET_NAME}" --arg value "${DECRYPTED}" '{($key): $value}'
jq -n --arg key "decrypted_secret" --arg value "${DECRYPTED}" '{($key): $value}'
