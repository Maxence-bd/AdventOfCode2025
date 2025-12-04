#!/bin/bash

# set -euo pipefail

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

            #On saut son propre controle
            [[ $k -eq 0 && $l -eq 0 ]] && continue

            #On vérifie si on est bien dans la grille
            (( LigneRegarde < 0 || LigneRegarde >= nbLigne )) && continue
            (( colonneRegarde < 0 || colonneRegarde >= nbColonne )) && continue

            local voisin="${grid[$LigneRegarde]:$colonneRegarde:1}"
            if [[ $voisin == "@" ]]; then
                ((nbVoisinLocal++))
            fi
        done
    done
    if (( nbVoisinLocal<4 )); then
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

mapfile -t grid < day4_input

nbLigne=$( wc -l < $FILE )
nbColonne=${#grid[1]}
nbVoisin=0

echo "nb Ligne " $nbLigne " Nb colonne " $nbColonne
compteur=0

for ((i=0;i<$nbLigne;i++)); do
    for ((j=0;j<$nbColonne;j++)); do
        #Vérifier les 8 autours donc [-1;-1] [X;X] [1;1]
#         char="${grid[$i]:$j:1}"
#         echo "$char"
        val=$(compterVoisin "$i" "$j")
        nbVoisin=$((nbVoisin + val))
    done
    compteur+=1
    avance=$((compteur/nbLigne))
    echo "$avance %"
done
echo $nbVoisin

