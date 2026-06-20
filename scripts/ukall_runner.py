from collections import defaultdict
import pandas as pd

# results = pd.read_csv("./results.tsv", sep="\t")


class GetCombinedCalls:
    def __init__(self, df):
        self.df = df
        genes, ascat_calls, custom_calls = self.get_calls()
        self.discordance = self.get_discordance(genes, ascat_calls, custom_calls)
        self.calls = self.combine_calls()

    def resolve_par1_custom(self):
        genes = ["SHOX", "CRLF2", "IL3RA", "ASMTL", "P2RY8"]
        par1_genes = self.df[self.df["gene_custom"].isin(genes)]
        print(par1_genes)
        shox = (
            ""
            if par1_genes[par1_genes["gene_custom"] == "SHOX"]["status"].empty
            else par1_genes[par1_genes["gene_custom"] == "SHOX"]["status"].values[0]
        )
        crlf2 = (
            ""
            if par1_genes[par1_genes["gene_custom"] == "CRLF2"]["status"].empty
            else par1_genes[par1_genes["gene_custom"] == "CRLF2"]["status"].values[0]
        )
        il3ra = (
            ""
            if par1_genes[par1_genes["gene_custom"] == "IL3RA"]["status"].empty
            else par1_genes[par1_genes["gene_custom"] == "IL3RA"]["status"].values[0]
        )
        asmtl = (
            ""
            if par1_genes[par1_genes["gene_custom"] == "ASMTL"]["status"].empty
            else par1_genes[par1_genes["gene_custom"] == "ASMTL"]["status"].values[0]
        )
        p2ry8 = (
            ""
            if par1_genes[par1_genes["gene_custom"] == "P2RY8"]["status"].empty
            else par1_genes[par1_genes["gene_custom"] == "P2RY8"]["status"].values[0]
        )

        if shox != "DELETION" and crlf2 != "DELETION":
            if il3ra == "DELETION" and asmtl == "DELETION" and p2ry8 == "DELETION":
                return "Yes"
            else:
                return "No"
        else:
            return "No"

    def resolve_par1_ascat(self):
        genes = ["SHOX", "CRLF2", "IL3RA", "ASMTL", "P2RY8"]
        par1_genes = self.df[self.df["gene_ascat"].isin(genes)]
        shox = (
            ""
            if par1_genes[par1_genes["gene_ascat"] == "SHOX"]["call"].empty
            else par1_genes[par1_genes["gene_ascat"] == "SHOX"]["call"].values[0]
        )
        crlf2 = (
            ""
            if par1_genes[par1_genes["gene_ascat"] == "CRLF2"]["call"].empty
            else par1_genes[par1_genes["gene_ascat"] == "CRLF2"]["call"].values[0]
        )
        il3ra = (
            ""
            if par1_genes[par1_genes["gene_ascat"] == "IL3RA"]["call"].empty
            else par1_genes[par1_genes["gene_ascat"] == "IL3RA"]["call"].values[0]
        )
        asmtl = (
            ""
            if par1_genes[par1_genes["gene_ascat"] == "ASMTL"]["call"].empty
            else par1_genes[par1_genes["gene_ascat"] == "ASMTL"]["call"].values[0]
        )
        p2ry8 = (
            ""
            if par1_genes[par1_genes["gene_ascat"] == "P2RY8"]["call"].empty
            else par1_genes[par1_genes["gene_ascat"] == "P2RY8"]["call"].values[0]
        )

        if shox != "DELETION" and crlf2 != "DELETION":
            if il3ra == "DELETION" and asmtl == "DELETION" and p2ry8 == "DELETION":
                return "Yes"
            else:
                return "No"
        else:
            return "No"

    def get_calls(self):
        genes = ["BTG1", "CDKN2A", "CDKN2B", "EBF1", "ETV6", "IKZF1", "PAX5", "RB1"]
        ascat_par1 = self.resolve_par1_ascat()
        custom_par1 = self.resolve_par1_custom()
        ascat_calls = []
        custom_calls = []
        for gene in genes:
            ascat_calls.append(
                "Yes"
                if self.df[self.df["gene_ascat"] == gene]["call"].empty == False
                and self.df[self.df["gene_ascat"] == gene]["call"].values[0]
                == "DELETION"
                else "No"
            )
            custom_calls.append(
                "Yes"
                if self.df[self.df["gene_custom"] == gene]["call"].empty == False
                and self.df[self.df["gene_custom"] == gene]["status"].values[0]
                == "DELETION"
                else "No"
            )
        ascat_calls.append(ascat_par1)
        custom_calls.append(custom_par1)
        genes.append("PAR1")
        (
            a_btg1,
            a_cdkn2a,
            a_cdkn2b,
            a_ebf1,
            a_etv6,
            a_ikzf1,
            a_pax5,
            a_rb1,
            ascat_par1,
        ) = ascat_calls
        (
            c_btg1,
            c_cdkn2a,
            c_cdkn2b,
            c_ebf1,
            c_etv6,
            c_ikzf1,
            c_pax5,
            c_rb1,
            custom_par1,
        ) = custom_calls
        # cna_profile = cal_cna(btg1, cdkn2a, cdkn2b, ebf1, etv6, ikzf1, pax5, rb1, par1)
        return [genes, ascat_calls, custom_calls]

    def get_discordance(self, genes, ascat_calls, custom_calls):
        gene_matches = defaultdict(lambda: {"n_yes": 0, "n_no": 0})
        for index, gene in enumerate(genes):
            print(gene, ascat_calls[index], custom_calls[index])
            if ascat_calls[index] == "No":
                gene_matches[gene]["n_no"] += 1
            elif ascat_calls[index] == "Yes":
                gene_matches[gene]["n_yes"] += 1
            if custom_calls[index] == "No":
                gene_matches[gene]["n_no"] += 1
            elif custom_calls[index] == "Yes":
                gene_matches[gene]["n_yes"] += 1
        return gene_matches

    def combine_calls(self):
        combined_calls = {}
        for key, values in self.discordance.items():
            if values["n_no"] == 2:
                combined_calls[key] = "No"
            if values["n_no"] == 1 and values["n_yes"] == 1:
                combined_calls[key] = "No"
            if values["n_yes"] == 2:
                combined_calls[key] = "Yes"
        return combined_calls


# obj = GetCombinedCalls(results)
