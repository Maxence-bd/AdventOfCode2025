#!/bin/bash
# day4.sh

set -euo pipefail

FILE="day4_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

# Lecture de la grille dans un tableau
mapfile -t grid < "$FILE"

nbLigne=${#grid[@]}
nbColonne=${#grid[0]}

# Tableau parallèle pour stocker les 'x' (rouleaux accessibles déjà trouvés)
declare -a marks
for ((i=0; i<nbLigne; i++)); do
    # Initialise chaque ligne de marks avec des '.' pour la lisibilité
    marks[$i]=$(printf '%*s' "$nbColonne" '' | tr ' ' '.')
done

#######################################
# Fonction: compterVoisin
# Retourne 1 si la case (r,c) est un rouleau '@'
# et a STRICTEMENT moins de 4 voisins '@'.
# Sinon retourne 0.
#######################################
compterVoisin() {
    local r=$1
    local c=$2
    local nbVoisinLocal=0

    # On ne s'intéresse qu'aux rouleaux
    local centre="${grid[$r]:$c:1}"
    if [[ $centre != "@" ]]; then
        echo 0
        return
    fi

    for k in -1 0 1; do
        for l in -1 0 1; do
            # On saute la case centrale
            [[ $k -eq 0 && $l -eq 0 ]] && continue

            local ligneRegarde=$((r+k))
            local colonneRegarde=$((c+l))

            # On vérifie qu'on reste dans la grille
            (( ligneRegarde < 0 || ligneRegarde >= nbLigne )) && continue
            (( colonneRegarde < 0 || colonneRegarde >= nbColonne )) && continue

            local voisin="${grid[$ligneRegarde]:$colonneRegarde:1}"
            if [[ $voisin == "@" ]]; then
                ((nbVoisinLocal++))
            fi
        done
    done

    # Accessible si strictement moins de 4 voisins '@'
    if (( nbVoisinLocal < 4 )); then
        echo 1
    else
        echo 0
    fi
}

#######################################
# Fonction: set_mark
# Met un 'x' dans marks[r][c]
#######################################
set_mark() {
    local r=$1
    local c=$2
    local line="${marks[$r]}"
    marks[$r]="${line:0:c}x${line:c+1}"
}

#######################################
# Fonction: print_frame
# Affiche la grille en une "frame" ASCII :
# - '@' et '.' de la grille
# - 'x' là où marks[][] vaut 'x'
# - surlignage de la case courante (cur_i, cur_j)
#######################################
print_frame() {
    local cur_i=$1
    local cur_j=$2

    # Revenir en haut à gauche sans scroller
    printf '\e[H'

    for ((i=0; i<nbLigne; i++)); do
        for ((j=0; j<nbColonne; j++)); do
            local base_char="${grid[$i]:$j:1}"
            local mark_char="${marks[$i]:$j:1}"

            local display_char
            if [[ $mark_char == "x" ]]; then
                display_char="x"
            else
                display_char="$base_char"
            fi

            if (( i == cur_i && j == cur_j )); then
                # Surligne la case courante (inverse vidéo)
                printf '\e[7m%s\e[0m' "$display_char"
            else
                printf '%s' "$display_char"
            fi
        done
        printf '\n'
    done
}

#######################################
# Programme principal avec animation
#######################################

nbAccessible=0

# Efface l'écran et cache le curseur
printf '\e[2J'
tput civis

# S'assurer qu'on réaffiche le curseur en cas de Ctrl+C ou fin
trap 'tput cnorm; printf "\n"; exit' INT TERM EXIT

for ((i=0; i<nbLigne; i++)); do
    for ((j=0; j<nbColonne; j++)); do
        # Calcul de l'accessibilité
        accessible=$(compterVoisin "$i" "$j")

        if (( accessible == 1 )); then
            ((nbAccessible++))
            set_mark "$i" "$j"
        fi

        # Affichage de la frame actuelle
        print_frame "$i" "$j"

        # Animation : pause entre les frames
        # Pour aller plus vite, diminue le temps (ex: 0.01)
        sleep 0.03
    done
done

# Fin de l'animation : on montre la grille finale et le total
print_frame -1 -1  # -1 -1 => aucune case surlignée
printf "\nRouleaux accessibles : %d\n" "$nbAccessible"

# Fin propre
tput cnorm
trap - INT TERM EXIT
