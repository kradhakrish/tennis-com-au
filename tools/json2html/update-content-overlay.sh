#!/bin/sh
# Adds the json2html worker as a content overlay on top of the AEM author content source.
# Overlays are only supported by the Configuration Service, not by fstab.yaml.
# If the site has no Configuration Service entry yet, one is created, after which
# fstab.yaml is no longer used for this site.

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

ADMIN="https://admin.hlx.page/config/${ORG}/sites/${SITE}"
SOURCE_URL="https://author-p152232-e1579634.adobeaemcloud.com/bin/franklin.delivery/${ORG}/${SITE}/${BRANCH}"
OVERLAY_URL="https://json2html.adobeaem.workers.dev/${ORG}/${SITE}/${BRANCH}"

CONTENT=$(cat <<EOF
{
  "source": {
    "url": "${SOURCE_URL}",
    "type": "markup",
    "suffix": ".html"
  },
  "overlay": {
    "url": "${OVERLAY_URL}",
    "type": "markup"
  }
}
EOF
)

STATUS=$(curl -sS -o /dev/null -w "%{http_code}" "${ADMIN}.json" -H "x-auth-token: ${ADMIN_TOKEN}")

if [ "${STATUS}" = "200" ]; then
  echo "Site config exists, updating content source and overlay..."
  curl -sS -X POST "${ADMIN}/content.json" \
    -H "x-auth-token: ${ADMIN_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "${CONTENT}"
elif [ "${STATUS}" = "404" ]; then
  echo "No site config found, creating one with content source and overlay..."
  curl -sS -X PUT "${ADMIN}.json" \
    -H "x-auth-token: ${ADMIN_TOKEN}" \
    -H "Content-Type: application/json" \
    --data "{\"version\": 1, \"code\": {\"owner\": \"${ORG}\", \"repo\": \"${SITE}\"}, \"content\": ${CONTENT}}"
else
  echo "Unexpected status ${STATUS} reading ${ADMIN}.json"
  exit 1
fi
echo

echo "Current content config:"
curl -sS "${ADMIN}/content.json" -H "x-auth-token: ${ADMIN_TOKEN}"
echo
