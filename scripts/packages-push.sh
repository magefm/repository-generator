#!/bin/bash

set -e -o pipefail

CONFIGJSON="$(cat config.json)"
GHREMOTETEMPLATE=$(echo "$CONFIGJSON" | jq -r '.githubRemoteTemplate')

source="$1"

cd "$source"

BRANCHES=()
eval "$(git for-each-ref --shell --format='BRANCHES+=(%(refname))' refs/heads/ | grep "refs/heads/split-magento/")"

for BRANCH in "${BRANCHES[@]}"; do
    NAME=${BRANCH//refs\/heads\/split-magento\/}
    VERSION=${NAME//*-heads-}
    NAME=${NAME//-heads-*}

    REPOSITORY=$(printf "$GHREMOTETEMPLATE" "$NAME")
    echo "Pushing $BRANCH to $REPOSITORY ($VERSION)"
    git push "$REPOSITORY" "$BRANCH":"$VERSION"
done

TAGS=()
eval "$(git for-each-ref --shell --format='TAGS+=(%(refname))' refs/tags/ | grep "refs/tags/split-magento/")"

for TAG in "${TAGS[@]}"; do
    NAME=${TAG//refs\/tags\/split-magento\/}
    VERSION=${NAME//*-tags-}
    NAME=${NAME//-tags-*}

    REPOSITORY=$(printf "$GHREMOTETEMPLATE" "$NAME")
    echo "Pushing $TAG to $REPOSITORY ($VERSION)"
    git push "$REPOSITORY" "$TAG":"$VERSION"
done
