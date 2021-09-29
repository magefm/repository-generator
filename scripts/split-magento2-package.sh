#!/bin/bash

set -e

prefix="$PWD/packages/magento2"

cd "sources/magento2"

path=$1
name=$2
reftype=$3
ref=$4

if [[ "$reftype" == "branch" ]]; then
    reftype="heads"
    version=$(git rev-parse --abbrev-ref HEAD)
else
    reftype="tags"
    version=$(cat "$path/composer.json" | jq -r '.version')

    if [[ "null" == "$version" ]]; then
        version="$ref"
    fi
fi

echo "Splitting $path (refs/$reftype/$ref) into $name (refs/$reftype/$version)"

localRef="split-$name-$reftype-$version"

if [[ "$reftype" == "tags" && "$(git tag | grep "$localRef" | wc -l)" -eq "1" ]]; then
    echo "Skipping, tag already exists"
    exit 0
fi

"${OLDPWD}/splitsh-lite/splitsh-lite" \
    -prefix "$path/" \
    -origin "refs/$reftype/$ref" \
    -target "refs/$reftype/$localRef" \
    -progress

if [[ ! -d "$prefix/$name" ]]; then
    mkdir -p "$prefix/$name"
    (cd "$prefix/$name"; git init .)
fi

git push -f "$prefix/$name" "$localRef":"$version"
