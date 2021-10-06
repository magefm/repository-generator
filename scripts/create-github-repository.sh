#!/bin/bash

set -eo pipefail

GHTOKENJSON="$(cat github-token.json)"
GHUSER=$(echo "$GHTOKENJSON" | jq -r '.user')
GHTOKEN=$(echo "$GHTOKENJSON" | jq -r '.token')
GHORG=$(echo "$GHTOKENJSON" | jq -r '.organization')

source="$1" # i.e.: "packages/inventory/"
PACKAGES=($(find "$source/magento" -mindepth 1 -maxdepth 1 -type d))

for PACKAGE in "${PACKAGES[@]}"; do
    NAME="${PACKAGE##*/}"
    echo "Creating ${GHORG}/${NAME}"

    RESULT=$(curl --fail -sS \
        -u "${GHUSER}:${GHTOKEN}" \
        -X POST \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/orgs/${GHORG}/repos" \
        -d "{\"name\":\"${NAME}\",\"has_issues\":false,\"has_projects\":false,\"has_wiki\":false}"
    )
done
