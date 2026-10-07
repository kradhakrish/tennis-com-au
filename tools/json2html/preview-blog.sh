#!/bin/sh
# Previews (and optionally publishes) /blog and every article returned by the article-list endpoint.
# Requires curl and jq.

set -e

if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <org> <site> <branch> [--publish]"
  echo "Example: ADMIN_TOKEN=<token> $0 kradhakrish tennis-com-au main --publish"
  exit 1
fi

ORG="$1"
SITE="$2"
BRANCH="$3"
PUBLISH="$4"

if [ -z "${ADMIN_TOKEN}" ]; then
  echo "Missing ADMIN_TOKEN environment variable."
  exit 1
fi

LIST_ENDPOINT="https://publish-p158407-e1689364.adobeaemcloud.com/graphql/execute.json/tennis-australia/article-list"
IDS=$(curl -sS "${LIST_ENDPOINT}" | jq -r '.data.articleList.items[]._id')

run() {
  # $1 = preview | live, $2 = path
  CODE=$(curl -sS -o /dev/null -w "%{http_code}" -X POST \
    "https://admin.hlx.page/$1/${ORG}/${SITE}/${BRANCH}$2" \
    -H "Authorization: token ${ADMIN_TOKEN}")
  echo "$1 $2 -> ${CODE}"
}

for path in /blog $(printf '%s\n' ${IDS} | sed 's#^#/blog/#'); do
  run preview "${path}"
  if [ "${PUBLISH}" = "--publish" ]; then
    run live "${path}"
  fi
done
