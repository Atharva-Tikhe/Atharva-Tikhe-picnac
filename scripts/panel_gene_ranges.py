import pandas as pd
import sys

calls = sys.argv[1]
sid = sys.argv[2]

granges = pd.read_csv("~/opt/panel.ranges.tsv", header=None, sep="\t")

granges.columns = ["chr", "start", "end", "gene"]

calls = pd.read_csv(calls, sep="\t")

results = granges.merge(calls)

results.to_csv(f"{sid}_gene_calls.bed", sep="\t", header=False, index=False)
