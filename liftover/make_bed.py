import pandas as pd
from pathlib import Path
from argparse import ArgumentParser

# logging
import logging
from datetime import datetime

arg_parser = ArgumentParser(
    usage="make_bed.py: Use the TSV generated from gtc to make bed.",
    description="""
    This script converts a TSV to a canonical BED with added column for genomic ranges. Used in the pipeline to prepare inputs for liftOver
    """,
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


class BEDWriter:
    def __init__(self, input_file):
        logging.info("--------- BEGIN ------")
        self.input_file = Path(input_file)
        self.df = pd.read_csv(input_file, sep="\t")
        self.remove_unplaced()
        self.make_bed()
        self.split_and_write()

    def remove_unplaced(self):
        before_control = len(self.df)
        self.df = self.df[(self.df.iloc[:, 2] != 0) & (self.df.iloc[:, 3] != 0)]
        after_control = len(self.df)
        if before_control - after_control != 0:
            logging.warning(
                f"removed {before_control-after_control} unplaced/control probes."
            )

    def make_bed(self):
        self.df_bed = pd.DataFrame(
            {
                "chrom": self.df.iloc[:, 2].astype(str),
                "start": self.df.iloc[:, 3].astype(int) - 1,
                "end": self.df.iloc[:, 3].astype(int),
                "name": self.df.iloc[:, 0],
                "score": 0,
                "strand": ".",
                "genotypes": self.df.iloc[:, 4].astype(int),
                "snps": self.df.iloc[:, 1].astype(str),
                "LRR": self.df.iloc[:, 5],
                "BAF": self.df.iloc[:, 6],
            }
        )

        if len(self.df_bed[self.df_bed["chrom"] == "XY"]) != 0:
            logging.info("removed pseudoautosomal regions (XY)")
            self.df_bed = self.df_bed[self.df_bed["chrom"] != "XY"]
            self.df = self.df[self.df["chrom"] != "XY"]

            if len(self.df) == len(self.df_bed):
                logging.info("rearranged columns for BED")
                logging.info("added start column")
        else:
            logging.error("dataframe shapes do not match after dropping XY!")
            exit(1)

        self.df_bed["chrom"] = self.df_bed["chrom"].apply(
            lambda x: x if x.startswith("chr") else f"chr{x}"
        )

        chrom_order = [f"chr{i}" for i in range(1, 23)] + ["chrX", "chrY", "chrM"]

        self.df_bed["chrom"] = pd.Categorical(
            self.df_bed["chrom"], categories=chrom_order, ordered=True
        )

        self.df_bed = self.df_bed.sort_values(["chrom", "start"])

    def split_and_write(self):
        out = self.input_file.stem + ".bed"

        try:
            logging.info(f"writing bed to {out}")
            # removed headers cuz liftOver complains
            self.df_bed.to_csv(out, sep="\t", index=False, header=False)

        except Exception as e:
            logging.error("could not write output file: {out}")
            raise (e)
        finally:
            logging.info("writing complete")
            logging.info("--------- END ------")


obj = BEDWriter(args["i"])
