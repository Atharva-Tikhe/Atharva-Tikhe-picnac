# First function calculates the number of CNA altered ( as if the altered >=3 it is poor risk)
# Second function calculates the profile
# Third code convert the text input to numeric
# Last bit of the code is the GUI for the code, which shows the input drop list with index
#                ( "No", "Yes", "Inconclusive", "Note done", "Missing"),
#                     1          2                 3                            4                        5

from argparse import ArgumentParser
from pathlib import Path
import pandas as pd
from ukall_runner import GetCombinedCalls

parser = ArgumentParser(description="UKALL-CNA Classifier")

parser.add_argument("-p", "--tsv-path", help="Path to gene TSV")
parser.add_argument("-s", "--sample", help="Sample ID")

args = parser.parse_args()

tsv = Path(args.tsv_path)
sample = args.sample


# calculate number of deleted
def num_altered(btg1, cdkn2a, cdkn2b, ebf1, etv6, ikzf1, par1, pax5, rb1):
    cdkn2ab = "No"  # default
    if cdkn2a == "Yes" or cdkn2b == "Yes":
        cdkn2ab = "Yes"  # merge CDKN2A and B into single CDKN2A/B
    tot_altered = [btg1, cdkn2ab, ebf1, etv6, ikzf1, par1, pax5, rb1].count("Yes")
    return tot_altered


# converting genes
def gene_to_numeric(gene):
    num_gene = 9
    if gene == "Yes":
        num_gene = 1
    elif gene == "No":
        num_gene = 2
    elif gene == "Inconclusive":
        num_gene = 3
    elif gene == "Not done":
        num_gene = 4
    return num_gene


# calculate CNA profile by  20-09-2024
def cal_cna(btg1, cdkn2a, cdkn2b, ebf1, etv6, ikzf1, pax5, rb1, par1):
    btg1_num = gene_to_numeric(btg1)
    cdkn2a_num = gene_to_numeric(cdkn2a)
    cdkn2b_num = gene_to_numeric(cdkn2b)
    ebf1_num = gene_to_numeric(ebf1)
    etv6_num = gene_to_numeric(etv6)
    ikzf1_num = gene_to_numeric(ikzf1)
    par1_num = gene_to_numeric(par1)
    pax5_num = gene_to_numeric(pax5)
    rb1_num = gene_to_numeric(rb1)

    cdkn2ab_num = 2
    if cdkn2a_num == 1 or cdkn2b_num == 1:
        cdkn2ab_num = 1

    # calculate the CNA profile
    uk_cna = "to calculate"
    if num_altered(btg1, cdkn2a, cdkn2b, ebf1, etv6, ikzf1, par1, pax5, rb1) >= 3:
        uk_cna = "Poor risk"
    elif (
        (btg1_num == 2 and cdkn2ab_num == 2)
        and (ebf1_num == 2 and etv6_num == 2)
        and (ikzf1_num == 2 and par1_num == 2)
        and (pax5_num == 2 and rb1_num == 2)
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 1
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 1
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 1
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 1
        and ebf1_num == 2
        and etv6_num == 1
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 1
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 1
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 1
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 1
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        uk_cna == "to calculate"
        and btg1_num != 1
        and cdkn2ab_num == 1
        and ebf1_num != 1
        and etv6_num == 2
        and ikzf1_num != 1
        and par1_num != 1
        and pax5_num != 1
        and rb1_num != 1
    ):
        uk_cna = "Poor risk"
    elif (
        uk_cna == "to calculate"
        and btg1_num != 1
        and cdkn2ab_num != 1
        and ebf1_num != 1
        and etv6_num != 1
        and ikzf1_num != 1
        and par1_num != 1
        and pax5_num != 1
        and rb1_num == 1
    ):
        uk_cna = "Poor risk"
    elif (
        uk_cna == "to calculate"
        and btg1_num != 1
        and cdkn2ab_num != 1
        and ebf1_num != 1
        and etv6_num != 1
        and ikzf1_num != 1
        and par1_num == 1
        and pax5_num != 1
        and rb1_num != 1
    ):
        uk_cna = "Poor risk"
    elif (
        btg1_num != 1
        and cdkn2ab_num != 1
        and ebf1_num == 1
        and etv6_num != 1
        and ikzf1_num != 1
        and par1_num != 1
        and pax5_num != 1
        and rb1_num != 1
    ):
        uk_cna = "Poor risk"
    elif (
        btg1_num != 1
        and cdkn2ab_num != 1
        and ebf1_num != 1
        and etv6_num != 1
        and ikzf1_num == 1
        and par1_num != 1
        and pax5_num != 1
        and rb1_num != 1
    ):
        uk_cna = "Poor risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 1
        and ikzf1_num == 2
        and par1_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 1
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 1
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ):
        uk_cna = "Good risk"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 1
        and ebf1_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and (etv6_num == 3 or etv6_num == 4 or etv6_num == 9):
        uk_cna = "Inconclusive"
    elif (
        (ebf1_num != 1 or ikzf1_num != 1 or par1_num != 1 or rb1_num != 1)
        and (btg1_num == 3 or cdkn2ab_num == 3 or etv6_num == 3 or pax5_num == 3)
        and uk_cna == "to calculate"
    ):
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 3
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 3
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 3
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 3
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        (ebf1_num != 1 or ikzf1_num != 1 or par1_num != 1 or rb1_num != 1)
        and (btg1_num == 4 or cdkn2ab_num == 4 or etv6_num == 4 or pax5_num == 4)
        and uk_cna == "to calculate"
    ):
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 4
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 4
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 4
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 4
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 4
        and cdkn2ab_num == 4
        and ebf1_num == 4
        and etv6_num == 4
        and ikzf1_num == 4
        and par1_num == 4
        and pax5_num == 4
        and rb1_num == 4
    ) and uk_cna == "to calculate":
        uk_cna = "Missing"
    elif (
        btg1_num == 9
        and cdkn2ab_num == 9
        and ebf1_num == 9
        and etv6_num == 9
        and ikzf1_num == 9
        and par1_num == 9
        and pax5_num == 9
        and rb1_num == 9
    ) and uk_cna == "to calculate":
        uk_cna = "Missing"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 9
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 9
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 9
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 9
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 4
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 4
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 4
        and pax5_num == 2
        and rb1_num == 2
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif (
        btg1_num == 2
        and cdkn2ab_num == 2
        and ebf1_num == 2
        and etv6_num == 2
        and ikzf1_num == 2
        and par1_num == 2
        and pax5_num == 2
        and rb1_num == 4
    ) and uk_cna == "to calculate":
        uk_cna = "Inconclusive"
    elif uk_cna == "to calculate":
        uk_cna = "Poor risk"

    return uk_cna


# cna_profile = cal_cna(sl_btg1, sl_cdkn2a, sl_cdkn2b, sl_ebf1, sl_etv6, sl_ikzf1, sl_par1, sl_pax5, sl_rb1)


def run():
    df = pd.read_csv(str(tsv), sep="\t")
    obj = GetCombinedCalls(df)
    calls = obj.calls
    cna_profile = cal_cna(
        calls["BTG1"],
        calls["CDKN2A"],
        calls["CDKN2B"],
        calls["EBF1"],
        calls["ETV6"],
        calls["IKZF1"],
        calls["PAX5"],
        calls["RB1"],
        calls["PAR1"],
    )
    with open("./classifier_result.txt", "w") as f:
        f.writelines(cna_profile)
        print("classifier_result.text written")


run()
