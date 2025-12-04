#!/bin/bash

set -euo pipefail

FILE="day3_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

total=0


max_joltage_k_number() {
    local s="$1"
    local k="$2"              # nombre de chiffres à garder
    local n=${#s}

    local result=""
    local start=0           # début de la fenêtre
    local need=$k           # chiffres restant à choisir

    local step=1

    echo -e "\n--- Analyse de $s (garder $k chiffres) ---"

    while (( need > 0 )); do
        local max_digit=-1
        local max_pos=$start

        local last_idx=$(( n - need ))

        # Chercher le max dans cette fenêtre
        local i d
        for (( i=start; i<=last_idx; i++ )); do
            d=${s:i:1}
            if (( d > max_digit )); then
                max_digit=$d
                max_pos=$i
            fi
        done

        # Affichage visuel
        echo -en "Étape $step : "
        step=$((step+1))

        # On affiche la chaîne avec la fenêtre en rouge
        for (( i=0; i<n; i++ )); do
            if (( i == max_pos )); then
                # Chiffre choisi → vert
                printf "\e[32m%s\e[0m" "${s:i:1}"
            elif (( i >= start && i <= last_idx )); then
                # Fenêtre → rouge
                printf "\e[31m%s\e[0m" "${s:i:1}"
            else
                # Autres chiffres → normal
                printf "%s" "${s:i:1}"
            fi
        done

        # On ajoute un commentaire
        echo -e "   (fenêtre = ${s:start:last_idx-start+1} / choisi = $max_digit)"

        # Ajouter le max au résultat
        result+="$max_digit"

        # Fenêtre suivante
        start=$(( max_pos + 1 ))
        (( need-- ))
    done

    echo -e "→ Résultat final : \e[32m$result\e[0m\n"
    echo "$result"
}



while IFS= read -r line; do
    max_joltage_k_number $line 12
done < "$FILE"

echo "Total : $total"

