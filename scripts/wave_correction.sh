#!/usr/bin/bash

bedfile=$1

awk -F '\t' '$9 != "" && $10 != ""' "$bedfile" > clean.bed

echo -e "Name\tChr\tPosition\tGType\tB Allele Freq\tLog R Ratio" > output.bed

cat clean.bed | sed -e 's/\[//g' | sed -e 's/\]//g' | sed -e 's/chr//g' |  awk -F'\t' 'BEGIN{OFS="\t"}{print $4,$1,$3,$8,$10,$9}' >> output.bed
