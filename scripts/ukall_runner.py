import pandas as pd


class GetCombinedCalls:
    """Convert gene-level ASCAT/custom outputs into classifier Yes/No calls.

    The classifier rules in CNA_working.py expect one Yes/No value per locus.
    This class only prepares those inputs; it does not decide CNA risk.
    """

    TARGET_GENES = ["BTG1", "CDKN2A", "CDKN2B", "EBF1", "ETV6", "IKZF1", "PAX5", "RB1"]
    PAR1_GENES = ["SHOX", "CRLF2", "IL3RA", "ASMTL", "P2RY8"]

    def __init__(self, df):
        self.df = df.copy()
        self.calls = self.combine_calls()

    @staticmethod
    def _normalise(value):
        if pd.isna(value):
            return ""
        return str(value).strip().upper()

    def _has_deletion(self, gene_column, call_column, gene):
        if gene_column not in self.df.columns or call_column not in self.df.columns:
            return False

        rows = self.df[self.df[gene_column] == gene]
        if rows.empty:
            return False

        calls = rows[call_column].map(self._normalise)
        return calls.eq("DELETION").any()

    def _combined_gene_call(self, gene):
        ascat_deleted = self._has_deletion("gene_ascat", "call", gene)
        custom_deleted = self._has_deletion("gene_custom", "status", gene)
        return "Yes" if ascat_deleted or custom_deleted else "No"

    def _par1_call_from(self, gene_column, call_column):
        deleted = {
            gene: self._has_deletion(gene_column, call_column, gene)
            for gene in self.PAR1_GENES
        }

        shox_or_crlf2_deleted = deleted["SHOX"] or deleted["CRLF2"]
        core_par1_deleted = deleted["IL3RA"] and deleted["ASMTL"] and deleted["P2RY8"]

        return core_par1_deleted and not shox_or_crlf2_deleted

    def _combined_par1_call(self):
        ascat_par1 = self._par1_call_from("gene_ascat", "call")
        custom_par1 = self._par1_call_from("gene_custom", "status")
        return "Yes" if ascat_par1 or custom_par1 else "No"

    def combine_calls(self):
        calls = {gene: self._combined_gene_call(gene) for gene in self.TARGET_GENES}
        calls["PAR1"] = self._combined_par1_call()
        return calls
