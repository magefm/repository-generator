#!/bin/bash

set -e -o pipefail


SOURCE="sources/magento2"
DEST="packages/magento2/magento/magento2-base"
TAGS=($(bash scripts/_list-tags.sh "$SOURCE" | egrep -v "(alpha|beta|-RC|-rc)" | sort -V))

IGNORE_PREFIXES=(
    ".git/"
    ".github/"
    "app/code/Magento/"
    "app/design/frontend/"
    "app/design/adminhtml/"
    "app/i18n/"
    "lib/internal/Magento/Framework/"
    "composer.lock"
)

if [[ ! -d "$DEST" ]]; then
    mkdir -p "$DEST"
    (cd "$DEST"; git init .)
fi

for TAG in "${TAGS[@]}"; do
    # skip existing tags on $DEST
    EXISTS=$(cd "$DEST"; git tag -l "$TAG" | wc -l)

    if [[ "$EXISTS" == "1" ]]; then
        echo "Skipping $TAG, already exists on DEST"
        continue
    fi

    echo "Creating magento/magento2-base $TAG"

    # checkout source
    (cd "$SOURCE"; git checkout "$TAG")

    # cleanup dest
    (cd "$DEST"; git rm -rf . || true)

    # populate dest
    find "$SOURCE" -type f -print0 | while read -d $'\0' FILE
    do
        for IGNORE_PREFIX in "${IGNORE_PREFIXES[@]}"; do
            if [[ "$FILE" =~ ^"$SOURCE/$IGNORE_PREFIX" ]]; then
                continue 2
            fi
        done

        DIR="${FILE#"$SOURCE"}"
        FILENAME="${DIR##*/}"
        DIR="${DIR%"$FILENAME"}"

        if [[ ! -d "$DEST$DIR" ]]; then
            mkdir -p "$DEST$DIR"
        fi

        cp "$FILE" "$DEST/${FILE#"$SOURCE/"}"
    done

    # commit
    (
        cd "$DEST";
        git add .;
        git commit -m "Release $TAG";
        git tag "$TAG"
    )
done

exit 1

# @TODO rebuild composer.json
# - package name
# - dependency versions?
# - extra.map
