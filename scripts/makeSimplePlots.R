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
                    make_option(c("-l", "--lrr"), type = "character", help = "LRR/BAF file(bed)"),
                    make_option(c("-s", "--seg"), type = "character", help = "Segments file (bed/tsv)"),
                    make_option(c("-p", "--panel"), type = "character", help = "Gene Panel")
)

opt <- parse_args(OptionParser(option_list = option_list))
lrr_file <- opt$lrr
seg_file <- opt$seg
panel <- opt$panel

#lrr_file <- "~/NCL/dissertation/plots/latest/output.bed"

#seg_file <- "~/NCL/dissertation/plots/latest/205549190163_32287.hg38.calls.tsv"

#panel <- "./panel_genes.bed"

padding <- 50000

#dir.create("gene_plots_fast", showWarnings = FALSE)

cat("Loading LRR/BAF...\n")

lrr <- fread(lrr_file)

colnames(lrr)[1:6] <- c("marker", "chr", "pos", "gt", "baf", "lrr")

lrr$chr <- ifelse(
  grepl("^chr", lrr$chr),
  lrr$chr,
  paste0("chr", lrr$chr)
)

cat("Loading segments...\n")

seg <- fread(seg_file)

seg$chrom <- ifelse(
  grepl("^chr", seg$chrom),
  seg$chrom,
  paste0("chr", seg$chrom)
)

gene_df <- fread(panel)

for(i in seq_len(nrow(gene_df))) {
  
  gene_name <- gene_df$gene[i]
  
  chr <- gene_df$chr[i]
  
  gene_start <- gene_df$start[i]
  
  gene_end <- gene_df$end[i]
  
  plot_start <- max(1, gene_start - padding)
  
  plot_end <- gene_end + padding
 
  cat("Plotting:", gene_name, "\n")
  
  lrr_sub <- lrr %>% filter(chr == !!chr, pos >= plot_start, pos <= plot_end)
  
  if(nrow(lrr_sub) == 0) {
    cat("No probes found\n")
    next
  }
  
  seg_sub <- seg %>%
    filter(
      chrom == !!chr,
      loc.end >= plot_start,
      loc.start <= plot_end
    )
  
  p_lrr <- ggplot(lrr_sub, aes(x = pos, y = lrr)) +
    
    geom_point(
      size = 0.6,
      alpha = 0.8
    ) +
    
    geom_hline(
      yintercept = 0,
      linetype = "dashed"
    ) +
    
    # segment means
    geom_segment(
      data = seg_sub,
      aes(
        x = loc.start,
        xend = loc.end,
        y = seg.mean,
        yend = seg.mean
      ),
      inherit.aes = FALSE,
      linewidth = 1.2,
      color = "red"
    ) +
    
    # gene region
    annotate(
      "rect",
      xmin = gene_start,
      xmax = gene_end,
      ymin = -Inf,
      ymax = Inf,
      alpha = 0.08,
      fill = "gold"
    ) +
    
    labs(
      title = gene_name,
      subtitle = paste0(chr, ":", gene_start, "-", gene_end),
      x = NULL,
      y = "LRR"
    ) +
    
    coord_cartesian(
      xlim = c(plot_start, plot_end),
      ylim = c(-2, 2)
    ) +
    
    theme_bw()
  
  p_baf <- ggplot(lrr_sub, aes(x = pos, y = baf)) +
    
    geom_point(
      size = 0.6,
      alpha = 0.8,
      color = "blue"
    ) +
    
    geom_hline(
      yintercept = c(0, 0.5, 1),
      linetype = "dashed"
    ) +
    
    annotate(
      "rect",
      xmin = gene_start,
      xmax = gene_end,
      ymin = -Inf,
      ymax = Inf,
      alpha = 0.08,
      fill = "gold"
    ) +
    
    labs(
      x = "Genomic Position",
      y = "BAF"
    ) +
    
    coord_cartesian(
      xlim = c(plot_start, plot_end),
      ylim = c(0, 1)
    ) +
    
    theme_bw()
  
  combined_plot <- p_lrr / p_baf +
    plot_layout(heights = c(2, 1))
   
  
  out_file <- file.path(
    paste0(gene_name, "_plot.png")
  )
  
  ggsave(
    out_file,
    combined_plot,
    width = 12,
    height = 7
  )
  
  cat("Saved:", out_file, "\n")
}
cat("\nDone.\n")
