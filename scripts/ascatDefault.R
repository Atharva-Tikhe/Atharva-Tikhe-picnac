library(ASCAT)
library(optparse)
library(dplyr)
library(GenomicRanges)
option_list <- list(
                    make_option(c("-i", "--input"), type = "character", help = "Input BED file"),
                    make_option(c("-s", "--sample"), type = "character", help = "Sample ID")
)

opt <- parse_args(OptionParser(option_list = option_list))
input_file = opt$input
sample_id = opt$sample

ascat.bc <- ascat.loadData(Tumor_LogR_file=paste0(sample_id, '_Tumor_LRR.txt'), Tumor_BAF_file=paste0(sample_id,'_Tumor_BAF.txt'), Germline_LogR_file=NULL, Germline_BAF_file=NULL, genomeVersion = "hg38")

ascat.plotRawData(ascat.bc, img.prefix="Raw_Data_")
ascat.gg <- ascat.predictGermlineGenotypes(ascat.bc, platform="IlluminaCytoSNP850k")
ascat.bc.seg <- ascat.aspcf(ascat.bc, ascat.gg = ascat.gg)
ascat.plotSegmentedData(ascat.bc.seg, img.prefix = "Segmented_Data_")
ascat.output <- ascat.runAscat(ascat.bc.seg)

segments <- ascat.output$segments

write.table(segments, 'segments.tsv', quote = FALSE, row.names = FALSE)

panel <- read.table('/home/atharva/opt/panel_genes.bed', sep = '\t', stringsAsFactors = FALSE, header = 1)

seg_gr <- GRanges(seqnames = paste0("chr", segments$chr), 
                  ranges = IRanges(start = segments$startpos,
                                   end = segments$endpos),
                  nMajor = segments$nMajor,
                  nMinor = segments$nMinor)
gene_gr <- GRanges(seqnames = panel$chr, 
                   ranges = IRanges(panel$start, panel$end), 
                   gene = panel$gene)

hits <- findOverlaps(gene_gr, seg_gr)

subHits <- subjectHits(hits)

df <- data.frame(
  gene = mcols(gene_gr)$gene[queryHits(hits)],
  chr = as.character(seqnames(seg_gr)[subHits]),
  start = start(seg_gr)[subjectHits(hits)],
  end = end(seg_gr)[subjectHits(hits)],
  nMajor = mcols(seg_gr)$nMajor[subjectHits(hits)],
  nMinor = mcols(seg_gr)$nMinor[subjectHits(hits)]
)

df$TCN <- df$nMajor + df$nMinor

df$seg_length <- df$end - df$start

gene_level <- df %>% group_by(gene) %>% slice_max(seg_length, n = 1) %>% ungroup()

gene_level$call <- ifelse(
  gene_level$TCN <= 1, "DELETION",
  ifelse(gene_level$TCN >= 3, "AMPLIFICATION", "NEUTRAL")
)
gene_level$LOH <- gene_level$nMinor == 0

write.table(
  gene_level,
  paste0(sample_id, "_gene_level_ascat_calls.tsv"),
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

