#!/bin/sh
echo -ne '\033c\033]0;CROCPNG\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/crocpng.x86_64" "$@"
