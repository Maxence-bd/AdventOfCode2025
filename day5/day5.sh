#!/bin/bash

set -euo pipefail

FILE="day5_input"
if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

mapfile -t grid < "$FILE"
grep '-' input.txt > ranges.txt
grep -v '-' input.txt | sed '/^$/d' > values.txt
