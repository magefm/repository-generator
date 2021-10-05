#!/bin/bash

set -e

# @TODO split all versions at once
reftype="$1"
ref="$2"
source="sources/inventory"

if [[ "$reftype" == "tag" && "$ref" == "1.2.2" ]]; then
    echo "1.2.2 was not prepapred for tagging, it's missing the versions on composer.json files."
    exit 1
fi

(cd "$source"; git checkout "$ref")

PACKAGES_JSON=$(php scripts/generate-package-json-inventory.php "$source" "$reftype" "$ref")
ITEMS=$(echo "$PACKAGES_JSON" | jq -c '.[]')

for ITEM in $ITEMS; do
    path=$(echo "$ITEM" | jq -r '.path')
    name=$(echo "$ITEM" | jq -r '.name')
    ./scripts/split-inventory-package.sh "$path" "$name" "$reftype" "$ref"
done
