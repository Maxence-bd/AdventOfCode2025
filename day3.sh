#!/bin/bash

set -euo pipefail

FILE="day3_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

total=0

while IFS= read -r line; do
    len=${#line}
    best=0
    best1=0
    best2=0

    # tester toutes les paires (i < j)
    for (( i=0; i<len; i++ )); do
        d1=${line:i:1}

        for (( j=i+1; j<len; j++ )); do
            d2=${line:j:1}
            val=$(( 10*d1 + d2 ))

            if (( val > best )); then
                best=$val
                best1=$d1
                best2=$d2
            fi
        done
    done

    # ici, best est le plus grand nombre à 2 chiffres possible sur la ligne
    (( total += best ))

done < "$FILE"

echo "Total : $total"
