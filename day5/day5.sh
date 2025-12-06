#!/bin/bash


FILE="day5_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

avalaibleIngredients=0

FILERANGE="ranges.txt"
FILEVALUES="values.txt"

grep '-' "$FILE" > "$FILERANGE"
grep -v '-' "$FILE" | sed '/^$/d' > "$FILEVALUES"


#Regarder valeur par valeur dans les chiffres à chercher
partie1() {
    while IFS= read -r VALUES; do
        while IFS= read -r RANGE; do
            IFS='-' read -r start end <<< "$RANGE"
                if (( VALUES>=start && VALUES<=end )); then
                    ((avalaibleIngredients++))
                    break
                fi
        done < "$FILERANGE"
    done < "$FILEVALUES"
    echo $avalaibleIngredients
}

partie2() {
    FILE="day5_input"

    if [[ ! -f "$FILE" ]]; then
        echo "Fichier '$FILE' introuvable" >&2
        return 1
    fi

    # 1. On extrait les ranges
    # 2. On les trie numériquement sur la borne de début
    # 3. On fusionne et on calcule la longueur totale
    total=$(
        grep '-' "$FILE" \
        | sort -n -t'-' -k1,1 \
        | awk -F'-' '
            NR == 1 {
                cur_start = $1
                cur_end   = $2
                next
            }

            {
                start = $1
                end   = $2

                # Si ce range chevauche ou touche l’intervalle courant
                if (start <= cur_end + 1) {
                    if (end > cur_end) cur_end = end
                } else {
                    # On ferme l’intervalle courant
                    total += cur_end - cur_start + 1
                    # On démarre un nouveau
                    cur_start = start
                    cur_end   = end
                }
            }

            END {
                # Ajouter le dernier intervalle
                total += cur_end - cur_start + 1
                print total
            }
        '
    )

    echo "Partie 2 - Total d'IDs fresh : $total"
}






##Partie 1
partie2

