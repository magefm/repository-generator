#!/bin/bash

set -e

# @TODO split all versions at once
reftype="$1"
ref="$2"
source="sources/security-package"

(cd "$source"; git checkout "$ref")

PACKAGES_JSON=$(php scripts/generate-package-json.php "$source")
ITEMS=$(echo "$PACKAGES_JSON" | jq -c '.[]')

for ITEM in $ITEMS; do
    path=$(echo "$ITEM" | jq -r '.path')
    name=$(echo "$ITEM" | jq -r '.name')
    ./scripts/split-security-package.sh "$path" "$name" "$reftype" "$ref"
done
