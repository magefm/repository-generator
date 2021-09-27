#!/bin/bash

set -e

tag="$1" # @TODO split all versions at once

(cd sources/magento2; git checkout "$tag")

PACKAGES_JSON=$(php scripts/generate-package-json.php "sources/magento2")
ITEMS=$(echo "$PACKAGES_JSON" | jq -c '.[]')

for ITEM in $ITEMS; do
    path=$(echo "$ITEM" | jq -r '.path')
    name=$(echo "$ITEM" | jq -r '.name')
    ./scripts/split-magento2-package.sh "$path" "$name" "$tag"
done
