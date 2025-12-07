#!/bin/bash

set -euo pipefail

compterVoisin() {
    local r=$1
    local c=$2
    local nbVoisinLocal=0

    local analyser="${grid[$r]:$c:1}"

    if [[ $analyser != "@" ]]; then
        echo 0
        return
    fi

    for k in -1 0 1; do
        for l in -1 0 1; do
            local LigneRegarde=$((r+k))
            local colonneRegarde=$((c+l))

            # On saute son propre contrôle
            [[ $k -eq 0 && $l -eq 0 ]] && continue

            # On vérifie si on est bien dans la grille
            (( LigneRegarde < 0 || LigneRegarde >= nbLigne )) && continue
            (( colonneRegarde < 0 || colonneRegarde >= nbColonne )) && continue

            local voisin="${grid[$LigneRegarde]:$colonneRegarde:1}"
            if [[ $voisin == "@" ]]; then
                ((nbVoisinLocal++))
            fi
        done
    done
    if (( nbVoisinLocal < 4 )); then
        echo 1
    else
        echo 0
    fi
}

FILE="day4_input"
if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

mapfile -t grid < "$FILE"

nbLigne=$(wc -l < "$FILE")
nbColonne=${#grid[1]}
nbVoisin=0

echo "nb Ligne $nbLigne  Nb colonne $nbColonne"
compteur=0

for ((i=0; i<nbLigne; i++)); do
    for ((j=0; j<nbColonne; j++)); do
        val=$(compterVoisin "$i" "$j")
        nbVoisin=$((nbVoisin + val))
    done
    # petite barre de progression
    echo "$i / $nbLigne"
done

echo "Partie 1 : $nbVoisin rouleaux accessibles"


totalRemoved=0

while :; do
    roundRemoved=0
    to_remove=()

    for ((i=0; i<nbLigne; i++)); do
        for ((j=0; j<nbColonne; j++)); do
            char="${grid[$i]:$j:1}"
            [[ $char != "@" ]] && continue

            val=$(compterVoisin "$i" "$j")
            if (( val == 1 )); then
                to_remove+=("$i:$j")
                ((roundRemoved++))
            fi
        done
    done

    if (( roundRemoved == 0 )); then
        break
    fi

    for coord in "${to_remove[@]}"; do
        I=${coord%%:*}
        J=${coord##*:}

        row="${grid[$I]}"
        prefix="${row:0:$J}"
        suffix="${row:$((J+1))}"
        grid[$I]="${prefix}.${suffix}"
    done

    ((totalRemoved += roundRemoved))
    echo "On retire $roundRemoved rouleaux sur cette passe (total = $totalRemoved)"
done

echo "Partie 2 : $totalRemoved rouleaux peuvent être retirés au total"
