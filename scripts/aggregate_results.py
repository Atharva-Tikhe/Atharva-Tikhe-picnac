import pandas as pd
from argparse import ArgumentParser

arg_parser = ArgumentParser(
    usage="This script aggregates results from ASCAT gene calls and custom CBS calls."
)

arg_parser.add_argument("--ascat", help="ascat TSV path", required=True)
arg_parser.add_argument("--custom", help="custom TSV path", required=True)
arg_parser.add_argument("--output", help="output TSV path", required=True)

args = vars(arg_parser.parse_args())

ascat = pd.read_csv(args["ascat"], sep="\t")

custom = pd.read_csv(args["custom"], sep="\t")

custom_numeric = custom.select_dtypes(include=["int64", "float64"]).columns
custom_numeric

custom[custom_numeric] = custom[custom_numeric].astype(str)

ascat_numeric = ascat.select_dtypes(include=["int64", "float64"]).columns
ascat[ascat_numeric] = ascat[ascat_numeric].astype(str)

ascat.index = ascat["gene"]

custom.index = custom["gene"]

export = ascat.join(custom, how="outer", lsuffix="_ascat", rsuffix="_custom")

export.to_csv(args["output"], sep="\t", index=False)
