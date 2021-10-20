#!/bin/bash

SOURCE="$1"

cd "$SOURCE"

TAGS=()
eval "$(git for-each-ref --shell --format='TAGS+=(%(refname))' refs/tags/ | grep -v "refs/tags/split-")"

for REF in "${TAGS[@]}"; do
    TAG=${REF//refs\/tags\/}
    echo "$TAG"
done
