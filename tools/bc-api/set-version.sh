#!/usr/bin/env bash
# Sets the default manifest version for the Tennis concierge.
# Usage: ./tools/bc-api/set-version.sh <BC_ADMIN_TOKEN> <version>
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: $0 <BC_ADMIN_TOKEN> <version>" >&2
  exit 1
fi

BC_ADMIN_TOKEN="$1"
VERSION="$2"

if ! [[ "$VERSION" =~ ^[0-9]+$ ]]; then
  echo "Version must be a whole number, got: $VERSION" >&2
  exit 1
fi

MANIFEST_ID="c318a4f8-bc66-4d49-8678-987e09023a7a"
IMS_ORG_ID="50071E616706B0A90A495CB0@AdobeOrg"
SANDBOX_ID="98634aec-b3c7-4928-a34a-ecb3c72928c2"

curl --location --request PUT "https://bcos-compiler.corp.ethos10-prod-va7.ethos.adobe.net/v1/manifests/${MANIFEST_ID}/versions/default" \
  --header "Authorization: Bearer ${BC_ADMIN_TOKEN}" \
  --header "x-gw-ims-org-id: ${IMS_ORG_ID}" \
  --header "x-sandbox-id: ${SANDBOX_ID}" \
  --header 'Content-Type: application/json' \
  --data "{ \"version\": ${VERSION} }"
echo
