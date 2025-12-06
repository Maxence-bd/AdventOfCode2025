#!/bin/bash

set -euo pipefail

FILE="day4_input"
if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

# On lit la grille dans un tableau
mapfile -t grid < "$FILE"

nbLigne=${#grid[@]}
nbColonne=${#grid[0]}   # suppose toutes les lignes de même longueur

echo "nb Ligne  $nbLigne  Nb colonne  $nbColonne"

########################################
# compterVoisin r c
# -> echo 1 si (r,c) est un @ avec <4 voisins @
# -> echo 0 sinon
########################################
compterVoisin() {
    local r=$1
    local c=$2
    local nbVoisinLocal=0

    # caractère à cette position
    local analyser="${grid[$r]:$c:1}"

    # si ce n'est pas un @, ce n'est jamais accessible
    if [[ $analyser != "@" ]]; then
        echo 0
        return
    fi

    # on parcourt les 8 voisins
    for k in -1 0 1; do
        for l in -1 0 1; do
            # on saute la case elle-même
            [[ $k -eq 0 && $l -eq 0 ]] && continue

            local LigneRegarde=$((r + k))
            local ColonneRegarde=$((c + l))

            # on sort si hors grille
            (( LigneRegarde < 0 || LigneRegarde >= nbLigne )) && continue
            (( ColonneRegarde < 0 || ColonneRegarde >= nbColonne )) && continue

            local voisin="${grid[$LigneRegarde]:$ColonneRegarde:1}"
            if [[ $voisin == "@" ]]; then
                ((nbVoisinLocal++))
            fi
        done
    done

    # accessible si moins de 4 voisins @
    if (( nbVoisinLocal < 4 )); then
        echo 1
    else
        echo 0
    fi
}

########################################
# setCell r c char
# remplace le caractère de (r,c) par char
########################################
setCell() {
    local r=$1
    local c=$2
    local ch=$3

    local ligne="${grid[$r]}"

    # ATTENTION: pour utiliser une variable comme offset/longueur,
    # il faut bien mettre $c et pas "c" littéral.
    # avant / char / après
    grid[$r]="${ligne:0:$c}${ch}${ligne:$((c+1))}"
}

########################################
# Boucle de simulation
########################################
totalRemoved=0
iteration=0

while :; do
    ((iteration++))
    removedThisRound=0
    toRemove=()

    # 1) repérer les @ accessibles dans l'état actuel
    for ((i=0; i<nbLigne; i++)); do
        for
