#!/bin/bash

for FILE in "$@"
do
	EXT=${FILE##*.}
	QUALITY=40 # quality for image (1-100)
	/opt/homebrew/bin/cwebp -q $QUALITY "$FILE" -o "${FILE/%.$EXT/.webp}"
done
