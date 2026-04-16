import pandas as pd
from pathlib import Path
from argparse import ArgumentParser

# logging
import logging
from datetime import datetime

arg_parser = ArgumentParser(
    usage="make_bed.py: Use the TSV generated from gtc to make bed.",
    description="This script converts a TSV to a canonical BED with added column for genomic ranges. Used in the pipeline to prepare inputs for liftOver",
)

arg_parser.add_argument("-i", help="Input TSV", required=True)

args = vars(arg_parser.parse_args())

log_filename = f"log_{datetime.now().strftime('%Y-%m-%d')}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    filename=log_filename,
    filemode="a",
)

df = pd.read_csv(args["i"], sep="\t")
before_control = len(df)
df = df[(df.iloc[:, 2] != 0) & (df.iloc[:, 3] != 0)]
after_control = len(df)
if before_control - after_control != 0:
    logging.warning(f"removed {before_control-after_control} unplaced/control probes.")

df_bed = pd.DataFrame(
    {
        "chrom": df.iloc[:, 2].astype(str),
        "start": df.iloc[:, 3].astype(int) - 1,
        "end": df.iloc[:, 3].astype(int),
        "name": df.iloc[:, 0],
        "score": 0,
        "strand": ".",
        "genotypes": df.iloc[:, 4].astype(int),
        "snps": df.iloc[:, 1].astype(str),
        "LRR": df.iloc[:, 5],
        "BAF": df.iloc[:, 6],
    }
)

if len(df_bed[df_bed["chrom"] == "XY"]) != 0:
    logging.info("removed pseudoautosomal regions (XY)")
    df_bed = df_bed[df_bed["chrom"] != "XY"]
    df = df[df["chrom"] != "XY"]

    if len(df) == len(df_bed):
        logging.info("rearranged columns for BED")
        logging.info("added start column")
    else:
        logging.error("dataframe shapes do not match after dropping XY!")
        exit(1)

df_bed["chrom"] = df_bed["chrom"].apply(
    lambda x: x if x.startswith("chr") else f"chr{x}"
)

chrom_order = [f"chr{i}" for i in range(1, 23)] + ["chrX", "chrY", "chrM"]

df_bed["chrom"] = pd.Categorical(df_bed["chrom"], categories=chrom_order, ordered=True)

df_bed = df_bed.sort_values(["chrom", "start"])

try:
    out = Path(args["i"]).stem + ".bed"
    logging.info(f"writing to {out}")
    # removed headers cuz liftOver complains
    df_bed.to_csv(out, sep="\t", index=False, header=False)

except Exception as e:
    logging.error("could not write output file")
    raise (e)
finally:
    logging.info("writing complete")
    logging.info("--------- Goodbye ------")
