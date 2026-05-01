library(data.table)
library(dplyr)
library(optparse)

option_list <- list(
                    make_option(c("-i", "--input"), type = "character", help = "Input BED file"),
                    make_option(c("-s", "--sample"), type = "character", help = "Sample ID")
)

opt <- parse_args(OptionParser(option_list = option_list))
input_file = opt$input
sample_id = opt$sample

df <- fread(input_file, sep = "\t")

df[, V3 := as.numeric(V3)]
df[, V9 := as.numeric(V9)]

df <- df[!is.na(V9) & !is.na(V3)]
#setorder(df, Chr, Position)

df[, LRR_corr := NA_real_]

chroms <- unique(df$V1)

for (ch in chroms) {
  cat("Processing ", ch, "\n")

  idx <- which(df$V1 == ch)

  d <- df[idx]

  if(nrow(d) < 100) {
    df[idx, LRR_corr := V9]
    next
  }

  fit <- loess(
               V9 ~ V3,
               data = d,
               span = 0.1,
               family = "symmetric",
               degree = 1, 
               surface = "direct"
        )

  pred <- predict(fit, d$V3)

  if (length(pred) != nrow(d)) {
    stop(paste("Length mismatch in ", ch))
  }

  df[idx, LRR_corr := d$V9 - pred]
}

df[is.na(LRR_corr), LRR_corr := V9]

fwrite(df, paste0(sample_id, ".corrected.bed"), sep = "\t", col.names = FALSE, quote = FALSE)

