#!/bin/bash

set -e -o pipefail

source="$1"

PACKAGESJSON=$(php scripts/generate-package-json.php "$source")

cd "$source"

for PACKAGEJSON in $(echo "$PACKAGESJSON" | jq -c '.[]'); do
    NAME=$(echo "$PACKAGEJSON" | jq -r '.name')
    REPOSITORY=$(echo "$PACKAGEJSON" | jq -r '."repository"')

    echo "Pulling $NAME from $REPOSITORY"

    REFS=($(git ls-remote --heads --tags "$REPOSITORY" | cut -b 42-))

    for REF in "${REFS[@]}"; do
        localreftype="$(echo "$REF" | cut -d '/' -f 2)"
        localref="$(echo "$REF" | cut -d '/' -f 3)"

        LOCALREF="refs/$localreftype/split-$NAME-$localreftype-$localref"
        echo "  $REF => $LOCALREF"

        git fetch "$REPOSITORY" "$REF":"$LOCALREF"
    done
done
