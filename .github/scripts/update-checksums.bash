#!/usr/bin/env bash

version=$(cat version.txt)

echo "version=$version" >>"$GITHUB_OUTPUT"

systems=("darwin_arm64" "darwin_amd64" "linux_arm64" "linux_amd64")

for system in "${systems[@]}"; do
    sha256=$(nix-prefetch-url "https://d2f391esomvqpi.cloudfront.net/encore-$version-$system.tar.gz")

    sed -i "/$system/c\   \"$system\" = \"$sha256\";" checksums.nix
done
