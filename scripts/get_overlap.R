library(GenomicRanges)

calls <- read.table('./205030250061_32215.hg38.calls.tsv', header = TRUE)
summary(calls)
segments_gr <- GRanges(seqnames = calls$chrom, ranges = IRanges(calls$loc.start, calls$loc.end), seg.mean = calls$seg.mean, call = calls$call)

loci_gr <- rtracklayer::import("loci.hg38.bed", format = "BED")

hits <- findOverlaps(loci_gr, segments_gr)

result <- cbind(
  as.data.frame(loci_gr[queryHits(hits)]),
  as.data.frame(segments_gr[subjectHits(hits)])
)

write.table(result, 'loci_segment_overlaps.tsv', sep ='\t', row.names = FALSE, quote = FALSE)

