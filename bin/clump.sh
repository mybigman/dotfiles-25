#!/usr/bin/env bash

# Script for encrypting and decrypting folders, using GPG and tar
# Usage:
#   clump foldername               # packs
#   clump foldername dest          # packs to specific location
#   clump foldername.clump         # unpacks
#   clump foldername.clump dest    # unpacks to specific location

if [ "$#" -eq 0 ]; then
    >&2 echo "Usage: $0 <FILE|DIRECTORY> [DEST]"
    exit 1
fi

EXT="clump"
TARGET="$1"
COMMAND=
if [ -f "$TARGET" ]; then
    COMMAND=unpack
elif [ -d "$TARGET" ]; then
    COMMAND=pack
else
    >&2 echo "Not a valid target: '$TARGET'"
    exit 1
fi

case "$COMMAND" in
    p|pack)
        if [ -f "$TARGET.$EXT" ]; then
            >&2 echo "Destination file already exists"
            exit 2
        fi
        tar -pcvf - "$TARGET" | gpg -c > "$TARGET.$EXT"
        echo "Packed into $TARGET.$EXT"
        ;;
    u|unpack)
        TMPFILE=$(mktemp)
        gpg -d "$TARGET" > "$TMPFILE" && tar -pxvf "$TMPFILE"
        rm -f "$TMPFILE"
        ;;
esac