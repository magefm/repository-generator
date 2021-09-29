#!/bin/bash

set -e -o pipefail

source="$1"

PACKAGESJSON=$(php scripts/generate-package-json.php "$source")

cd "$source"

for PACKAGEJSON in $(echo "$PACKAGESJSON" | jq -c '.[]'); do
    NAME=$(echo "$PACKAGEJSON" | jq -r '.name')
    REPOSITORY=$(echo "$PACKAGEJSON" | jq -r '."repository"')

    echo "Pushing $NAME to $REPOSITORY"

    branches=()
    eval "$(git for-each-ref --shell --format='branches+=(%(refname))' refs/heads/ | grep "refs/heads/split-$NAME-heads-")"
    for branch in "${branches[@]}"; do
        git push "$REPOSITORY" "$branch":"${branch#"refs/heads/split-$NAME-heads-"}"
    done

    tags=()
    eval "$(git for-each-ref --shell --format='tags+=(%(refname))' refs/tags/ | grep "refs/tags/split-$NAME-tags-")"
    for tag in "${tags[@]}"; do
        git push "$REPOSITORY" "$tag":"${tag#"refs/tags/split-$NAME-tags-"}"
    done
done
