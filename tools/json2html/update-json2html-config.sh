#!/bin/sh

set -e

if [ -z "${ADMIN_TOKEN}" ]; then
  echo "Missing ADMIN_TOKEN environment variable."
  echo "Export it first: export ADMIN_TOKEN='<your-admin-token>'"
  exit 1
fi

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <org> <site> <branch>"
  echo "Example: $0 kradhakrish tennis-com-au main"
  exit 1
fi

ORG="$1"
SITE="$2"
BRANCH="$3"

curl -X POST \
  "https://json2html.adobeaem.workers.dev/config/${ORG}/${SITE}/${BRANCH}" \
  -H "Authorization: token ${ADMIN_TOKEN}" \
  -H "Content-Type: application/json" \
  --data-binary "@tools/json2html-blog-config.json"
