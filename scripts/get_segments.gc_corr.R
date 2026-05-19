if (!require("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
    BiocManager::install("DNAcopy")
}
library(DNAcopy)
library(dplyr)
library(optparse)

option_list <- list(
                    make_option(c("-i", "--input"), type = "character", help = "Input BED file"),
                    make_option(c("-s", "--sample"), type = "character", help = "Sample ID")
)

opt <- parse_args(OptionParser(option_list = option_list))
input_file = opt$input
sample_id = opt$sample

del_thresh <- -0.6
amp_thresh <- 0.4
min_len_thresh <- 50


data <- read.csv(input_file, sep='\t', header = FALSE)

CNA.object <- CNA(data$V11, data$V1, data$V3, data.type = 'logratio', sampleid=sample_id)

smoothed.CNA.object <- smooth.CNA(CNA.object)

segment.smoothed.CNA.object <- segment(smoothed.CNA.object, undo.splits = "sdundo", undo.SD=3)

write.table(segment.smoothed.CNA.object$output, paste0(sample_id, '_segments.tsv'), sep='\t')

png(filename = paste0(sample_id, ".png"), width=3600, height=1500)
plot(segment.smoothed.CNA.object, plot.type="s")
dev.off()
png(filename = paste0(sample_id, "_segmeans_over_chrs.png"), width=3600, height=1500)
plot(segment.smoothed.CNA.object, plot.type="p")
dev.off()


seg_o <- data.frame(segment.smoothed.CNA.object$output)

calls <- seg_o %>% as_tibble() %>% filter(num.mark >= min_len_thresh) %>% mutate(call = case_when(seg.mean >= amp_thresh ~ "amp", seg.mean <= del_thresh ~ "del", TRUE ~ "neutral")
)

# calls <- segments$output %>%
#   as_tibble() %>%
#   filter(num.mark >= 10) %>%
#   mutate(
#     call = case_when(
#       seg.mean <= -0.6 ~ "deep_deletion",
#       seg.mean <= -0.3 ~ "deletion",
#       seg.mean >= 0.6 ~ "high_amplification",
#       seg.mean >= 0.3 ~ "amplification",
#       TRUE ~ "neutral"
#     )
#   )

write.table(calls, paste0(sample_id, ".hg38.calls.tsv"), sep='\t', row.names=FALSE, quote=FALSE)

