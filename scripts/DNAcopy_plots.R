library(ggplot2)
library(DNAcopy)

path <- "~/dev/pipeline/executions/test_gc_corr_high_span/205030250086_32217/"

sample_id <- "205030250086_32217"

# calls <- read.csv("~/dev/pipeline/executions/test_gc_corr_high_span/205030250086_32217/cbs/205030250086_32217.hg38.calls.tsv", sep = "\t")
data <- read.csv("/home/atharva/dev/pipeline/executions/test_gc_corr_high_span/work/7e/4b092e12687b3779ebac16e4f82f01/205030250086_32217.corrected.bed", sep='\t', header = FALSE)

CNA.object <- CNA(data$V9, data$V1, data$V3, data.type = 'logratio', sampleid=sample_id)

smoothed.CNA.object <- smooth.CNA(CNA.object)

segment.smoothed.CNA.object <- segment(smoothed.CNA.object, undo.splits = "sdundo", undo.SD = 3)

write.table(segment.smoothed.CNA.object$output, paste0(path, "/cbs/", sample_id, '_segments.undo.tsv'), sep='\t')

png(filename = paste0(path, "/cbs/" ,sample_id, "_undo.png"), width=3600, height=1500)
plot(segment.smoothed.CNA.object, plot.type="s", chromlist = 9)
dev.off()
