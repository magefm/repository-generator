#!/bin/bash

set -eo pipefail

GHTOKENJSON="$(cat github-token.json)"
GHUSER=$(echo "$GHTOKENJSON" | jq -r '.user')
GHTOKEN=$(echo "$GHTOKENJSON" | jq -r '.token')
GHORG=$(echo "$GHTOKENJSON" | jq -r '.organization')

source="$1"
PACKAGESJSON=$(php scripts/generate-package-json.php "$source")

for PACKAGEJSON in $(echo "$PACKAGESJSON" | jq -c '.[]'); do
    NAME=$(echo "$PACKAGEJSON" | jq -r '.name')
    NAME="${NAME#magento/}"

    echo "Creating ${GHORG}/${NAME}"

    RESULT=$(curl --fail -sS \
        -u "${GHUSER}:${GHTOKEN}" \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/orgs/${GHORG}/repos" \
        -d "{\"name\":\"${NAME}\",\"has_issues\":false,\"has_projects\":false,\"has_wiki\":false}"
    )
done
