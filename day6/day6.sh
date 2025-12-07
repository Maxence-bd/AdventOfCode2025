#!/bin/bash

# set -euo pipefail

FILE="day6_input"

if [[ ! -f "$FILE" ]]; then
    echo "Fichier '$FILE' introuvable" >&2
    exit 1
fi

mapfile -t grid < "$FILE"

nbLigne=${#grid[@]}
if (( nbLigne == 0 )); then
    echo "Input vide" >&2
    exit 1
fi

nbColonne=0
for ((r=0; r<nbLigne; r++)); do
    (( ${#grid[r]} > nbColonne )) && nbColonne=${#grid[r]}
done

for ((r=0; r<nbLigne; r++)); do
    len=${#grid[r]}
    if (( len < nbColonne )); then
        grid[r]+=$(printf '%*s' "$((nbColonne-len))" "")
    fi
done


segments=()
in_segment=0
start=0

for ((c=0; c<nbColonne; c++)); do
    col_all_space=1
    for ((r=0; r<nbLigne; r++)); do
        ch=${grid[r]:c:1}
        if [[ $ch != " " ]]; then
            col_all_space=0
            break
        fi
    done

    if (( col_all_space )); then
        if (( in_segment )); then
            segments+=("$start:$((c-1))")
            in_segment=0
        fi
    else
        if (( ! in_segment )); then
            in_segment=1
            start=$c
        fi
    fi
done

if (( in_segment )); then
    segments+=("$start:$((nbColonne-1))")
fi


grand_total=0
last_row=$((nbLigne-1))

for seg in "${segments[@]}"; do
    IFS=: read -r s e <<< "$seg"

    op="?"
    for ((c=s; c<=e; c++)); do
        ch=${grid[last_row]:c:1}
        if [[ $ch == "+" || $ch == "*" ]]; then
            op=$ch
            break
        fi
    done

    [[ $op == "?" ]] && continue
    numbers=()
    for ((c=s; c<=e; c++)); do
        digits=""
        for ((r=0; r<last_row; r++)); do
            ch=${grid[r]:c:1}
            if [[ $ch =~ [0-9] ]]; then
                digits+=$ch
            fi
        done
        if [[ -n $digits ]]; then
            numbers+=("$digits")
        fi
    done

    (( ${#numbers[@]} == 0 )) && continue

    result=${numbers[0]}
    for ((i=1; i<${#numbers[@]}; i++)); do
        n=${numbers[i]}
        if [[ $op == "+" ]]; then
            result=$((result + n))
        else
            result=$((result * n))
        fi
    done

    grand_total=$((grand_total + result))
done

echo "$grand_total"
