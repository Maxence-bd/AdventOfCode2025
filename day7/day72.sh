#!/bin/bash

set -euo pipefail

FILE="day7_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

# Lecture de la grille
mapfile -t grid < "$FILE"

nb_lignes=${#grid[@]}
(( nb_lignes > 0 )) || { echo "Fichier vide" >&2; exit 1; }
nb_colonnes=${#grid[0]}

# Recherche de S
start_row=-1
start_col=-1
for ((r=0; r<nb_lignes; r++)); do
    ligne=${grid[$r]}
    for ((c=0; c<nb_colonnes; c++)); do
        ch=${ligne:c:1}
        if [[ $ch == "S" ]]; then
            start_row=$r
            start_col=$c
            break 2
        fi
    done
done

if (( start_row == -1 )); then
    echo "Erreur : aucun 'S' trouvé dans la grille" >&2
    exit 1
fi

# cur[c] = nombre de timelines avec un rayon juste au-dessus de la ligne courante
declare -a cur beams new_beams next

for ((c=0; c<nb_colonnes; c++)); do
    cur[$c]=0
done
cur[$start_col]=1   # 1 seule timeline au départ

total_timelines=0

# On propage les rayons vers le bas
for ((r=start_row+1; r<nb_lignes; r++)); do
    # Les timelines entrent dans la ligne r
    unset beams
    declare -a beams
    for ((c=0; c<nb_colonnes; c++)); do
        v=${cur[$c]:-0}
        (( v > 0 )) && beams[$c]=$v || beams[$c]=${beams[$c]:-0}
    done

    # Résolution des splits sur cette ligne jusqu'à stabilité
    while :; do
        changed=0
        unset new_beams
        declare -a new_beams

        for ((c=0; c<nb_colonnes; c++)); do
            v=${beams[$c]:-0}
            cell=${grid[$r]:$c:1}

            if (( v > 0 )) && [[ $cell == "^" ]]; then
                left=$((c-1))
                right=$((c+1))

                # Rayon vers la gauche
                if (( left >= 0 )); then
                    new_beams[$left]=$(( ${new_beams[$left]:-0} + v ))
                else
                    # sort de la grille à gauche -> timelines terminées
                    total_timelines=$(( total_timelines + v ))
                fi

                # Rayon vers la droite
                if (( right < nb_colonnes )); then
                    new_beams[$right]=$(( ${new_beams[$right]:-0} + v ))
                else
                    # sort de la grille à droite -> timelines terminées
                    total_timelines=$(( total_timelines + v ))
                fi

                # Les rayons sur le splitter sont stoppés
                beams[$c]=$(( ${beams[$c]:-0} - v ))
                changed=1
            fi
        done

        # On ajoute les nouveaux rayons créés par les splits
        for ((c=0; c<nb_colonnes; c++)); do
            add=${new_beams[$c]:-0}
            if (( add > 0 )); then
                beams[$c]=$(( ${beams[$c]:-0} + add ))
            fi
        done

        (( changed == 0 )) && break
    done

    if (( r == nb_lignes - 1 )); then
        # Dernière ligne : tout ce qui reste sort par le bas -> timelines terminées
        for ((c=0; c<nb_colonnes; c++)); do
            v=${beams[$c]:-0}
            (( v > 0 )) && total_timelines=$(( total_timelines + v ))
        done

        # Plus de rayons après le bas de la grille
        for ((c=0; c<nb_colonnes; c++)); do
            cur[$c]=0
        done
    else
        # Descente d'une ligne pour tous les rayons restants
        unset next
        declare -a next
        for ((c=0; c<nb_colonnes; c++)); do
            v=${beams[$c]:-0}
            (( v > 0 )) && next[$c]=$v
        done

        unset cur
        declare -a cur
        for ((c=0; c<nb_colonnes; c++)); do
            cur[$c]=${next[$c]:-0}
        done
    fi
done

echo "$total_timelines"
