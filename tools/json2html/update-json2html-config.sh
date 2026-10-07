#!/bin/sh
# Pushes tools/json2html/config.json to the json2html worker for the given branch.

set -e

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <org> <site> <branch> [admin-token]"
  echo "Example: $0 kradhakrish tennis-com-au main"
  echo "The admin token can also be provided via the ADMIN_TOKEN environment variable."
  exit 1
fi

ORG="$1"
SITE="$2"
BRANCH="$3"
ADMIN_TOKEN="${4:-$ADMIN_TOKEN}"

if [ -z "${ADMIN_TOKEN}" ]; then
  echo "Missing admin token: pass it as the 4th argument or export ADMIN_TOKEN."
  exit 1
fi

CONFIG_FILE="$(dirname "$0")/config.json"

curl -sS -X POST \
  "https://json2html.adobeaem.workers.dev/config/${ORG}/${SITE}/${BRANCH}" \
  -H "Authorization: token ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  --data-binary "@${CONFIG_FILE}"
echo
