import pandas as pd
from pathlib import Path
import sys

lifted_file = Path(sys.argv[1])
data_file = Path(sys.argv[2])

lifted = pd.read_csv(
    lifted_file, sep="\t", names=["chrom", "start", "end", "name", "score", "strand"]
)

data = pd.read_csv(
    data_file, sep="\t", names=["name", "genotype", "snps", "LRR", "BAF"]
)

final = lifted.merge(data, how="inner", on="name")

final["start"] = final["start"].astype("Int64").astype(str)
final["end"] = final["end"].astype("Int64").astype(str)

chrom_order = [f"chr{i}" for i in range(1, 23)] + ["chrX", "chrY", "chrM"]

final["chrom"] = pd.Categorical(final["chrom"], categories=chrom_order, ordered=True)

final = final.sort_values(["chrom", "start"])

final.to_csv(lifted_file.stem + ".final.bed", sep="\t", index=False, header=False)
