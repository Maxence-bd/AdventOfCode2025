#!/bin/bash

FILE=$1
MDP=50
compteur=0

if [ -f $1 ]; then
    echo "fichier existe"
    for ligne in $(<$FILE)
    do
        SIGNE=${ligne:0:1}
        VALUE=${ligne:1}
        echo $MDP $SIGNE $VALUE
        if [ "$SIGNE" = "R" ]; then
            (( MDP = (MDP+VALUE)%100 ))
        else
            (( MDP = (MDP-VALUE+100)%100 ))
        fi
        if [ "$MDP" = "0" ]; then
            ((compteur=compteur+1))
        fi
    done

    echo "Nb de à égale à " $compteur
else
    echo "fichier existe pas"
fi
