#!/bin/bash

set -e

# @TODO split all versions at once
reftype="$1"
ref="$2"

(cd sources/magento2; git checkout "$ref")

PACKAGES_JSON=$(php scripts/generate-package-json.php "sources/magento2")
ITEMS=$(echo "$PACKAGES_JSON" | jq -c '.[]')

for ITEM in $ITEMS; do
    path=$(echo "$ITEM" | jq -r '.path')
    name=$(echo "$ITEM" | jq -r '.name')
    ./scripts/split-magento2-package.sh "$path" "$name" "$reftype" "$ref"
done
