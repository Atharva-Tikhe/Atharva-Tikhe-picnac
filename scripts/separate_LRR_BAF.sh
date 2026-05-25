#!/usr/bin/bash

BED=$1
SAMPLE=$2

echo -e "\tchrs\tpos\t${SAMPLE}" > "${SAMPLE}_Tumor_LRR.txt"
echo -e "\tchrs\tpos\t${SAMPLE}" > "${SAMPLE}_Tumor_BAF.txt"

# 6th col is LRR; 5th is BAF
# tail -n+2 "$BED" |  awk -F '\t' 'BEGIN{OFS="\t"} {print $1,$2,$3,$5}' >> "${SAMPLE}_Tumor_BAF.txt"
# tail -n+2 "$BED" |  awk -F '\t' 'BEGIN{OFS="\t"} {print $1,$2,$3,$6}' >> "${SAMPLE}_Tumor_LRR.txt"

tail -n+2 "$BED" | sed -e 's/chr//g' |  awk -F '\t' 'BEGIN{OFS="\t"} {print $4,$1,$3,$10}' >> "${SAMPLE}_Tumor_BAF.txt"
tail -n+2 "$BED" | sed -e 's/chr//g' | awk -F '\t' 'BEGIN{OFS="\t"} {print $4,$1,$3,$9}' >> "${SAMPLE}_Tumor_LRR.txt"
