library(GenomicRanges)
library(optparse)

option_list <- list(
                    make_option(c("-s", "--sample"), type = "character", help = "Sample ID"),
                    make_option(c("-l", "--loci"), type = "character", help = "Loci file (BED)")
)

opt <- parse_args(OptionParser(option_list = option_list))
loci_file = opt$loci
sample_id = opt$sample


calls <- read.table(paste0(sample_id, '.hg38.calls.tsv'), header = TRUE)

segments_gr <- GRanges(seqnames = calls$chrom, ranges = IRanges(calls$loc.start, calls$loc.end), seg.mean = calls$seg.mean, call = calls$call)

loci_gr <- rtracklayer::import(loci_file, format = "BED")

hits <- findOverlaps(loci_gr, segments_gr)

result <- cbind(
  as.data.frame(loci_gr[queryHits(hits)]),
  as.data.frame(segments_gr[subjectHits(hits)])
)

write.table(result, paste0(sample_id, '_loci_segment_overlaps.tsv'), sep ='\t', row.names = FALSE, quote = FALSE)

