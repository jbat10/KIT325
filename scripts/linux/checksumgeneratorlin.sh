#!/bin/bash

OUTPUT_DIR="$(cd "$(dirname "$0")/../../output" && pwd)"
cd "$OUTPUT_DIR" || exit 1

find . -maxdepth 10 -type f ! -name '*.sha256' | while read file; do 
    sha256sum "$file" | sed 's|\ .*/|\ |' > "$file.sha256"
done