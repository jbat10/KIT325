#!/bin/bash
cd ../../output

find . -type f ! -name '*.sha256' | while read file; do sha256sum "$file" | sed 's|\ .*/|\ |' > $file.sha256; done