#!/bin/bash

# Read JSON input from stdin
read input

# Parse JSON input to get arguments
KEY_ALIAS=$(echo "$input" | jq -r '.kms_key_alias')
PLAIN_SECRET=$(echo "$input" | jq -r '.plain_secret')
AWS_PROFILE=$(echo "$input" | jq -r '.aws_profile')
ENV=$(echo "$input" | jq -r '.env')
SECRET_NAME=$(echo "$input" | jq -r '.secret_name')
KEEP_COUNT=$(echo "$input" | jq -r '.keep_count  // "3"') # "3" is used as default value

# Directory for credential files
CRED_DIR="../credential_files/$ENV"
OUTPUT_FILE=".encrypted_${SECRET_NAME}"

# Full path for encrypted files
if [ -n "${SECRET_NAME}" ]; then
  FILE_PATH="${CRED_DIR}/${OUTPUT_FILE}"
else 
  echo "Failed to encrypt: SECRET_NAME is missing" >&2
  exit 1
fi

if [ "${AWS_PROFILE}" != "" ]; then
  PROFILE_CONTEXT="--profile ${AWS_PROFILE}"
else
  PROFILE_CONTEXT=""
fi

# Check if KEY_ALIAS is empty
if [ -z "${KEY_ALIAS}" ]; then
  echo "Failed to encrypt ${SECRET_NAME}: KMS Key ID is missing" >&2
  exit 1
fi

# Encrypt the plain text
ENCB64=$(aws kms encrypt --key-id "${KEY_ALIAS}" --plaintext fileb://<(echo -n  "${PLAIN_SECRET}") --output text --query CiphertextBlob ${PROFILE_CONTEXT})
if [ $? -ne 0 ]; then
  echo "Failed to encrypt ${SECRET_NAME}" >&2
  exit 1
fi

# Ensure filesystem cache is cleared before reading files
sync
echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true

TIMESTAMP=$(date +%Y%m%d_%H%M%S%N)

# Save encrypted data to new file
NEW_FILE_PATH="${FILE_PATH}_${TIMESTAMP}"
echo "${ENCB64}" > "${NEW_FILE_PATH}"
echo "Succeed to create encrypted file: ${NEW_FILE_PATH}"

# Delete old files, keeping only the specified number of latest files
find "${CRED_DIR}" -name "${OUTPUT_FILE}_20*" | sort -r | tail -n +$((KEEP_COUNT + 1)) | xargs -r rm

# Output the result as JSON
jq -n --arg key "encrypted_${SECRET_NAME}" --arg value "${ENCB64}" '{($key): $value}'