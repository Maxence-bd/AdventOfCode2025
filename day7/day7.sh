#!/bin/bash

FILE="day7_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

mapfile -t grid < "$FILE"

nb_lignes=${#grid[@]}
if (( nb_lignes == 0 )); then
    echo "Fichier vide" >&2
    exit 1
fi

nb_colonnes=${#grid[0]}

# Cherche la position de S
start_row=-1
start_col=-1

ligne=${grid[0]}
for ((c=0; c<nb_colonnes; c++)); do
    ch=${ligne:c:1}
    if [[ $ch == "S" ]]; then
        start_row=$r
        start_col=$c
        break 2   # sortir des deux boucles
    fi
done

# Tableau des rayons sur la ligne juste en dessous de S
declare -a cur next

# Initialisation : un rayon uniquement sous S
for ((c=0; c<nb_colonnes; c++)); do
    cur[$c]=0
done
cur[$start_col]=1

split_count=0

for ((r=start_row+1; r<nb_lignes; r++)); do
    # Réinitialiser le tableau next
    unset next
    declare -a next

    for ((c=0; c<nb_colonnes; c++)); do
        # S'il n'y a pas de rayon dans cette colonne, on skip
        if [[ ${cur[$c]:-0} -eq 0 ]]; then
            continue
        fi

        cell=${grid[$r]:$c:1}

        case "$cell" in
            ".")
                # Rayon continue tout droit
                next[$c]=1
                ;;
            "^")
                # Split : on compte, on émet à gauche et à droite
                ((split_count++))
                left=$((c-1))
                right=$((c+1))
                if (( left >= 0 )); then
                    next[$left]=1
                fi
                if (( right < nb_colonnes )); then
                    next[$right]=1
                fi
                ;;
            *)
                # Caractère inconnu -> on le considère comme vide
                next[$c]=1
                ;;
        esac
    done

    # La ligne suivante devient la "courante"
    unset cur
    declare -a cur
    for ((c=0; c<nb_colonnes; c++)); do
        cur[$c]=${next[$c]:-0}
    done
done

echo "$split_count"
