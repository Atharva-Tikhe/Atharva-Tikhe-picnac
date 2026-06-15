#!/usr/bin/bash

FILE=$1
OUT=$2

tail -n+2 "${FILE}" | awk -F '\t' '{start=$3-1; end = $3; printf("chr%s\t%s\t%s\t%s\n",$2, start, end, $6 )}' > "${OUT}.bedGraph"


awk 'BEGIN{OFS="\t"}
{
  key=$1 FS $2 FS $3
  sum[key]+=$4
  count[key]++
}
END{
  for(k in sum){
    split(k,a,FS)
    print a[1],a[2],a[3],sum[k]/count[k]
  }
}' "${OUT}.bedGraph" | sort -k1,1 -k2,2n | sed -e 's/"//g' > "${OUT}.dedup.sorted.bedGraph"
