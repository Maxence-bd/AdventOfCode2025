#!/bin/bash
set -euo pipefail

FILE="day2_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

# Partie 1 : séquence répétée exactement deux fois
has_double_repeat() {
    local s=$1
    local len=${#s}

    (( len % 2 )) && return 1  # longueur impaire donc impossible

    local half=$(( len / 2 ))

    [[ "${s:0:half}" == "${s:half}" ]]
}

# Partie 2 : séquence répétée au moins deux fois (motif quelconque)
has_repeated_pattern() {
    local s=$1
    local len=${#s}

    local i j pattern repeat built

    for (( i=1; i<=len/2; i++ )); do
        (( len % i )) && continue

        pattern=${s:0:i}
        repeat=$(( len / i ))
        built=""

        for (( j=0; j<repeat; j++ )); do
            built+="$pattern"
        done

        if [[ "$built" == "$s" ]]; then
            return 0
        fi
    done

    return 1
}

sum_part1=0
sum_part2=0

while IFS= read -r line; do
    # ignorer les lignes vides éventuelles
    [[ -z "$line" ]] && continue

    IFS=',' read -ra RANGES <<< "$line"

    for range in "${RANGES[@]}"; do
        # gérer la virgule finale éventuelle
        [[ -z "$range" ]] && continue

        IFS='-' read -r start end <<< "$range"

        # Boucle sur tous les IDs du range
        for (( id=start; id<=end; id++ )); do
            s=$id

#             # Partie 1
#             if has_double_repeat "$s"; then
#                 (( sum_part1 += id ))
#             fi

            # Partie 2
            if has_repeated_pattern "$s"; then
                (( sum_part2 += id ))
            fi
        done
    done
done < "$FILE"

echo "Partie 1 : $sum_part1"
echo "Partie 2 : $sum_part2"
