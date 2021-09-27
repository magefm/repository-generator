#!/bin/bash

set -e

prefix="$PWD/packages/magento2"

cd "sources/magento2"

path=$1
name=$2
tag=$3
version=$(cat "$path/composer.json" | jq -r '.version')

if [[ "null" == "$version" ]]; then
    version="$tag"
fi

echo "Splitting $path ($tag) into $name ($version)"

"${OLDPWD}/splitsh-lite/splitsh-lite" \
    -prefix "$path/" \
    -origin "refs/tags/$tag" \
    -target "refs/tags/split-$name-$version" \
    -progress

if [[ ! -d "$prefix/$name" ]]; then
    mkdir -p "$prefix/$name"
    (cd "$prefix/$name"; git init .)
fi

git push -f "$prefix/$name" "split-$name-$version":"$version"
