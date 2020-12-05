#!/usr/bin/env bash

set -eEuo pipefail
# set -x

cd "$(dirname "$0")"

function module() {
    echo "$(basename -s .md "$1")Md"
}

function preamble() {
    echo "module MdPages.$1 exposing (text)


text : String
text =
    \"\"\""
}

function postamble() {
    echo "\"\"\""
}

for FILE in ./*.md; do
    MOD=$(module "$FILE")
    DEST=$MOD.elm

    preamble "$MOD" > "$DEST"
    cat "$FILE"     >> "$DEST"
    postamble       >> "$DEST"
done
