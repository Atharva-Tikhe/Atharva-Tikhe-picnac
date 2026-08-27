"""
UK Copy Number Alteration (UK-CNA) Profile Calculator
Reference: Moorman et al. (2014), Blood 124(9):1434–1444
https://ashpublications.org/blood/article/124/9/1434/73057/
"""

from __future__ import annotations

from enum import Enum

import streamlit as st
from pydantic import BaseModel, computed_field

# ---------------------------------------------------------------------------
# Domain types
# ---------------------------------------------------------------------------


class GeneStatus(str, Enum):
    """Clinical assessment status for a single gene/locus."""

    YES = "Yes"
    NO = "No"
    INCONCLUSIVE = "Inconclusive"
    NOT_DONE = "Not done"
    MISSING = "Missing"

    @property
    def is_altered(self) -> bool:
        return self is GeneStatus.YES

    @property
    def is_uncertain(self) -> bool:
        """Test was attempted but yielded no definitive result."""
        return self in (GeneStatus.INCONCLUSIVE, GeneStatus.NOT_DONE)

    @property
    def is_absent(self) -> bool:
        """No data at all."""
        return self is GeneStatus.MISSING


class CNAProfile(str, Enum):
    GOOD_RISK = "Good risk"
    POOR_RISK = "Poor risk"
    INCONCLUSIVE = "Inconclusive"
    MISSING = "Missing"


# ---------------------------------------------------------------------------
# Input model
# ---------------------------------------------------------------------------


class CNAInput(BaseModel):
    """
    CNA status for the UK panel genes.

    CDKN2A and CDKN2B are submitted individually but classified as a merged
    locus (CDKN2A/B): deleted if *either* allele is deleted.
    """

    btg1: GeneStatus = GeneStatus.MISSING
    cdkn2a: GeneStatus = GeneStatus.MISSING
    cdkn2b: GeneStatus = GeneStatus.MISSING
    ebf1: GeneStatus = GeneStatus.MISSING
    etv6: GeneStatus = GeneStatus.MISSING
    ikzf1: GeneStatus = GeneStatus.MISSING
    par1: GeneStatus = GeneStatus.MISSING
    pax5: GeneStatus = GeneStatus.MISSING
    rb1: GeneStatus = GeneStatus.MISSING

    @computed_field
    @property
    def cdkn2ab(self) -> GeneStatus:
        """Merged CDKN2A/B locus — YES if either is deleted."""
        if self.cdkn2a.is_altered or self.cdkn2b.is_altered:
            return GeneStatus.YES
        return GeneStatus.NO

    @computed_field
    @property
    def num_altered(self) -> int:
        """Count of altered loci (uses the merged CDKN2A/B)."""
        loci = (
            self.btg1,
            self.cdkn2ab,
            self.ebf1,
            self.etv6,
            self.ikzf1,
            self.par1,
            self.pax5,
            self.rb1,
        )
        return sum(g.is_altered for g in loci)

    def classify(self) -> CNAProfile:
        return classify_cna(self)


# ---------------------------------------------------------------------------
# Classifier
# ---------------------------------------------------------------------------


def classify_cna(c: CNAInput) -> CNAProfile:
    """
    Classify the UK-CNA profile.

    Gene roles determine risk:
      - Free genes      (BTG1, ETV6, PAX5):  isolated deletion is not Poor risk.
      - Conditional     (CDKN2AB):           safe only when ETV6 is also deleted;
                                             isolated deletion is Poor risk.
      - Sentinel genes  (EBF1, IKZF1, PAR1, RB1):
                                             any isolated deletion → Poor risk.
    """
    YES = GeneStatus.YES
    NO = GeneStatus.NO

    btg1, cdkn2ab = c.btg1, c.cdkn2ab
    ebf1, etv6 = c.ebf1, c.etv6
    ikzf1, par1 = c.ikzf1, c.par1
    pax5, rb1 = c.pax5, c.rb1

    all_loci = (btg1, cdkn2ab, ebf1, etv6, ikzf1, par1, pax5, rb1)
    sentinels = (ebf1, ikzf1, par1, rb1)

    # 1. No data at all -------------------------------------------------------
    if all(g in (GeneStatus.MISSING, GeneStatus.NOT_DONE) for g in all_loci):
        return CNAProfile.MISSING

    # 2. High alteration burden -----------------------------------------------
    if c.num_altered >= 3:
        return CNAProfile.POOR_RISK

    # 3. Good risk ------------------------------------------------------------
    # All sentinel genes must be unaltered.
    # CDKN2AB is acceptable only when it is either unaltered, or co-deleted
    # with ETV6 (the CDKN2AB/ETV6 Good-risk pattern from Moorman 2014).
    sentinels_clear = all(g == NO for g in sentinels)
    cdkn2ab_safe = (cdkn2ab == NO) or (cdkn2ab == YES and etv6 == YES)

    if sentinels_clear and cdkn2ab_safe:
        return CNAProfile.GOOD_RISK

    # 4. Inconclusive: CDKN2AB deleted but ETV6 is uncertain ------------------
    # Can't confirm the co-deletion Good-risk pattern.
    if cdkn2ab == YES and etv6.is_uncertain and sentinels_clear:
        return CNAProfile.INCONCLUSIVE

    # 5. Inconclusive: uncertain/absent data with no confirmed risk driver -----
    # If no sentinel or CDKN2AB is definitively altered, an uncertain result
    # on any gene could change the classification with complete data.
    no_confirmed_risk_driver = not any(g == YES for g in (cdkn2ab, *sentinels))
    any_uncertain = any(g.is_uncertain or g.is_absent for g in all_loci)

    if no_confirmed_risk_driver and any_uncertain:
        return CNAProfile.INCONCLUSIVE

    # 6. Default --------------------------------------------------------------
    return CNAProfile.POOR_RISK


# ---------------------------------------------------------------------------
# Streamlit UI  (drop-in replacement for the `with cna:` block)
# ---------------------------------------------------------------------------

_PUBLICATION_URL = (
    "https://ashpublications.org/blood/article/124/9/1434/73057/"
    "A-novel-integrated-cytogenetic-and-genomic"
)

_STATUS_OPTIONS = [s.value for s in GeneStatus]


def _selectbox(label: str, key: str, **kwargs) -> GeneStatus:
    value = st.selectbox(label, _STATUS_OPTIONS, key=key, **kwargs)
    return GeneStatus(value)


def render_uk_cna_tab(tab) -> None:
    with tab:
        st.header("UK – Copy Number Alteration Profile")
        st.write(
            "The UK copy number alteration profile (UK-CNA) published in 2014. "
            f"Link to the publication: [Moorman et al., Blood 2014]({_PUBLICATION_URL})"
        )

        col1, col2 = st.columns(2)
        with col1:
            btg1 = _selectbox("*BTG1* deleted?", key="btg1")
            cdkn2a = _selectbox("*CDKN2A* deleted?", key="cdkn2a")
            cdkn2b = _selectbox("*CDKN2B* deleted?", key="cdkn2b")
            ebf1 = _selectbox("*EBF1* deleted?", key="ebf1")
            etv6 = _selectbox("*ETV6* deleted?", key="etv6")
        with col2:
            ikzf1 = _selectbox("*IKZF1* deleted?", key="ikzf1")
            par1 = _selectbox(
                "*PAR1* deleted?",
                key="par1",
                help="*CRLF2*::*P2RY8* fusion detected as PAR1 deletion",
            )
            pax5 = _selectbox("*PAX5* altered?", key="pax5")
            rb1 = _selectbox("*RB1* altered?", key="rb1")

        if st.button("Calculate UK-CNA", key="cna_but"):
            profile = CNAInput(
                btg1=btg1,
                cdkn2a=cdkn2a,
                cdkn2b=cdkn2b,
                ebf1=ebf1,
                etv6=etv6,
                ikzf1=ikzf1,
                par1=par1,
                pax5=pax5,
                rb1=rb1,
            ).classify()

            match profile:
                case CNAProfile.GOOD_RISK:
                    st.success(f"**UK-CNA: {profile.value}**", icon="✅")
                case CNAProfile.POOR_RISK:
                    st.error(f"**UK-CNA: {profile.value}**", icon="⚠️")
                case CNAProfile.INCONCLUSIVE:
                    st.warning(f"**UK-CNA: {profile.value}**", icon="🔍")
                case CNAProfile.MISSING:
                    st.info(f"**UK-CNA: {profile.value}**", icon="ℹ️")
