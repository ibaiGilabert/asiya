#!/bin/bash


DATAPATH=/home/usuaris/operador/asiya/sample

metrics=( "BLEU" "GTM" "NE" "METEOR" "NIST" "O" "TER" "ROUGE" "SP" "SR" "CP" "DPm" "DP" "DR" "CE")


for i in "${metrics[@]}"
do
    echo "Asiya.pl Asiya.config -v -eval single -metric_set metric_$i -data_path $DATAPATH > $i.report"
    Asiya.pl Asiya.config -v -eval single -metric_set metrics_$i -no_tok > $i.report
done






