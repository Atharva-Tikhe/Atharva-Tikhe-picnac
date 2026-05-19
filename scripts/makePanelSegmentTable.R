suppressPackageStartupMessages({
  library(rtracklayer)
  library(GenomicRanges)
  library(IRanges)
  library(data.table)
  library(dplyr)
  library(ggplot2)
  library(patchwork)
  library(optparse)
})

option_list <- list(
                    make_option(c("-s", "--seg"), type = "character", help = "Segments file (bed/tsv)"),
                    make_option(c("-p", "--panel"), type = "character", help = "Gene Panel")
)

opt <- parse_args(OptionParser(option_list = option_list))
seg_file <- opt$seg
panel <- opt$panel

# gtf_file <- "gencode.v49.annotation.gtf.gz"

#seg_file <- "~/NCL/dissertation/plots/latest/205549190163_32287.hg38.calls.tsv"

seg <- fread(seg_file)

seg$chrom <- ifelse(
  grepl("^chr", seg$chrom),
  seg$chrom,
  paste0("chr", seg$chrom)
)

gene_df <- fread(panel)

gene_gr <- GRanges(
  seqnames = gene_df$chr,
  ranges = IRanges(
    start = gene_df$start,
    end = gene_df$end
  ),
  gene = gene_df$gene
)

seg_gr <- GRanges(
  seqnames = seg$chrom,
  ranges = IRanges(
    start = seg$loc.start,
    end = seg$loc.end
  ),
  segmean = as.numeric(seg$seg.mean)
)

hits <- findOverlaps(gene_gr, seg_gr)

query_idx <- queryHits(hits)
subject_idx <- subjectHits(hits)

overlap_ranges <- pintersect(
  gene_gr[query_idx],
  seg_gr[subject_idx]
)

overlap_width <- width(overlap_ranges)

results <- data.table(
  gene = gene_gr$gene[query_idx],
  gene_chr = as.character(seqnames(gene_gr[query_idx])),
  gene_start = start(gene_gr[query_idx]),
  gene_end = end(gene_gr[query_idx]),
  
  seg_start = start(seg_gr[subject_idx]),
  seg_end = end(seg_gr[subject_idx]),
  
  segmean = seg_gr$segmean[subject_idx],
  
  overlap_bp = overlap_width
)

gene_scores <- results[
  ,
  .(
    weighted_segmean =
      sum(segmean * overlap_bp) / sum(overlap_bp),
    
    total_overlap_bp = sum(overlap_bp),
    
    n_segments = .N
  ),
  by = gene
]

gene_scores[
  ,
  status := fifelse(
    weighted_segmean < -0.25,
    "DELETION",
    fifelse(
      weighted_segmean > 0.15,
      "GAIN",
      "DIPLOID"
    )
  )
]

fwrite(
  gene_scores,
  "panel_gene_scores.tsv",
  sep = "\t"
)


#panel_genes <- c(
#  "IKZF1",
#  "ETV6",
#  "CDKN2A",
#  "CDKN2B",
#  "RB1",
#  "BTG1",
#  "EBF1",
#  "PAX5",
#  "PAR1"
#)

# Run once to make panel_genes.bed
#gtf <- import(gtf_file, feature.type = "gene")
#gtf$gene_name <- as.character(gtf$gene_name)
#genes <- gtf[
#  gtf$gene_name %in% panel_genes
#]
#gene_df <- data.table(
#  gene = genes$gene_name,
#  chr = as.character(seqnames(genes)),
#  start = start(genes),
#  end = end(genes)
#)
#fwrite(
#  gene_df,
#  "panel_genes.bed",
#  sep = "\t"
#)


