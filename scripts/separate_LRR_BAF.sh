#!/usr/bin/bash

BED=$1
SAMPLE=$2

echo -e "\tchrs\tpos\t${SAMPLE}" > "${SAMPLE}_Tumor_LRR.txt"
echo -e "\tchrs\tpos\t${SAMPLE}" > "${SAMPLE}_Tumor_BAF.txt"

# 6th col is LRR; 5th is BAF
tail -n+2 "$BED" |  awk -F '\t' 'BEGIN{OFS="\t"} {print $1,$2,$3,$5}' >> "${SAMPLE}_Tumor_BAF.txt"
tail -n+2 "$BED" |  awk -F '\t' 'BEGIN{OFS="\t"} {print $1,$2,$3,$6}' >> "${SAMPLE}_Tumor_LRR.txt"
