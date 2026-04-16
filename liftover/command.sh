#!/usr/bin/bash

# ./liftOver 205030250061_R03C01.to_lift.bed hg19ToHg38.over.chain.gz 205030250061_R03C01.hg38.bed 205030250061_R03C01.hg38.unmapped.bed
#
SAMPLE=$1

./liftOver "$SAMPLE.bed" hg19ToHg38.over.chain.gz "${SAMPLE}.hg38.bed"  "${SAMPLE}.hg38.unmapped.bed" -bedPlus=3 -tab > "liftover_${SAMPLE}.log"  2>&1
