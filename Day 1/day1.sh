#!/bin/bash

FILE="day1_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

dial=50
part1=0
part2=0

while read -r line; do
    # ignorer les lignes vides
    [[ -z "$line" ]] && continue

    dir=${line:0:1}        # L ou R
    steps=${line:1}        # valeur numérique


    if [[ "$dir" == "R" ]]; then

        k0=$(( (100 - dial) % 100 ))
    else
        k0=$(( dial % 100 ))
    fi

    if (( k0 == 0 )); then
        k0=100
    fi

    if (( steps >= k0 )); then
        hits=$(( 1 + (steps - k0) / 100 ))
        (( part2 += hits ))
    fi

    if [[ "$dir" == "R" ]]; then
        dial=$(( dial + steps ))
    else
        dial=$(( dial - steps ))
    fi

    dial=$(( (dial % 100 + 100) % 100 ))

    if (( dial == 0 )); then
        (( part1++ ))
    fi

done < "$FILE"

echo "Part 1: $part1"
echo "Part 2: $part2"
