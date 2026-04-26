if (!require("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
    BiocManager::install("DNAcopy")
}
library(DNAcopy)
library(dplyr)

del_thresh <- -0.6
amp_thresh <- 0.4
min_len_thresh <- 10


data <- read.csv('~/dev/pipeline/executions/test/lift/205030250061_32215.hg38.bed', sep='\t', header = FALSE)

CNA.object <- CNA(data$V9, data$V1, data$V3, data.type = 'logratio', sampleid="205030250061_32215")

smoothed.CNA.object <- smooth.CNA(CNA.object)

segment.smoothed.CNA.object <- segment(smoothed.CNA.object)

write.table(segment.smoothed.CNA.object$output, '205030250061_32215_segments.tsv', sep='\t')

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

write.table(calls, "205030250061_32215.hg38.calls.tsv", sep='\t', row.names=FALSE)

