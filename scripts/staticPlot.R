suppressPackageStartupMessages({
  library(Gviz)
  library(rtracklayer)
  library(dplyr)
  library(optparse)
  library(GenomicRanges)
})

option_list <- list(
  make_option(c("-l", "--lrr"), type = "character", help = "LRR/BAF file(bed)"),
  make_option(c("-s", "--seg"), type = "character", help = "Segments file (bed/tsv)"),
  make_option(c("-a", '--ascat'), type = "character", help = "ASCAT calls file (tsv)"),
  make_option(c("-g", '--genes'), type = "character", help = "Extracted gene annotations (tsv)"),
  make_option(c("-p", "--panel"), type = "character", help = "Gene Panel")
)

opt <- parse_args(OptionParser(option_list = option_list))
lrr_file <- opt$lrr
seg_file <- opt$seg
ascat_calls_file <- opt$ascat
panel_file <- opt$panel
genes_file <- opt$genes

# lrr_file <- "206617090143_32466/wave_correction_cbs/output.bed"
# seg_file <- "./206617090143_32466/wave_correction_cbs/206617090143_32466.hg38.calls.tsv"
# ascat_calls_file <- "./206617090143_32466/ascat/206617090143_32466_gene_level_ascat_calls.tsv"
# panel_file <- "./panel.ranges.tsv"
# genes_file <- "./jbrowse/gencode.genes.tsv"

lrr <- read.table(lrr_file, sep = '\t', header = 1)
lrr$Chr <- paste0('chr', lrr$Chr)

seg <- read.table(seg_file, sep = '\t', header = 1)
seg$chrom <- paste0('chr', seg$chrom)

genes <- read.csv(genes_file, sep = '\t', header = )
ascat_calls <- as.data.frame(read.csv(ascat_calls_file, sep = '\t'))
panel <- as.data.frame(read.csv(panel_file, sep = '\t', header = FALSE))


# Common
genome <- c('hg38')


plotPAR1 <- function(lrr, seg, ascat, panel, genes) {
  x_from <- 10001
  x_to <- 2800000 #(2781479)

  itrack <- IdeogramTrack(genome = genome, chr = 'chrX')
  gtrack <- GenomeAxisTrack()
  
  # ------ LRR -----
  x_lrr <- lrr %>% filter(Chr == 'chrX')
  
  x_lrr$Start <- x_lrr$Position - 1
  
  gr_lrr <- GRanges(seqnames = x_lrr$Chr, 
                    ranges = IRanges(x_lrr$Start, x_lrr$Position), 
                    lrr = x_lrr$Log.R.Ratio)

  lrr_track <- DataTrack(
    range = gr_lrr,
    chromosome = 'chrX',
    genome = genome,
    name = 'LRR',
    type = 'p',
    col = 'darkgray'
  )
  
  # ------ SEGMENTS -----
  
  flat_segments <- seg %>%
    rowwise() %>%
    do(data.frame(
      chrom = .$chrom,
      pos = c(.$loc.start, .$loc.end),      # Both boundaries get the same value
      seg.mean = c(.$seg.mean, .$seg.mean),
      call = c(.$call, .$call)
    ))
  
  gr_seg <- GRanges(
    seqnames = flat_segments$chrom,
    ranges = IRanges(start = flat_segments$pos, end = flat_segments$pos),
    score = flat_segments$seg.mean
  )
  
  seg_track <- DataTrack(
    range = gr_seg,
    name = "Seg Mean",
    type = c("l"), # "l" for lines, "g" for background grid
    col = "firebrick",  # Line color
    lwd = 4,            # Thick lines for high visibility
    ylim = c(-0.6, 0.2) # Set y-axis bounds to clearly see the drop
  )
  
  lrr_seg_overlay <- OverlayTrack(list(lrr_track, seg_track), name = "Custom CBS")

  # ------ Annots ----
  x_genes <- genes %>% filter(Chromosome == 'chrX')
  genes_gr <- GRanges(
    seqnames = x_genes$Chromosome,
    ranges = IRanges(start = x_genes$Start, end = x_genes$End),
    strand = x_genes$Strand,
    feature = x_genes$gene_type,   # Groups exons/features visually if needed
    gene = x_genes$gene_id,        # Unique gene identifier
    symbol = x_genes$gene_name     # Human-readable labels printed on the plot
  )
  gene_track <- GeneRegionTrack(
    range = genes_gr,
    genome = genome,
    chromosome = 'chrX',
    name = "Genes",
    transcriptAnnotation = "symbol",
    collapseTranscripts = "meta",  # Collapses alternative transcripts into a single line per gene
    shape = "arrow",               # Shows pointing arrows for gene direction/strand
    fill = "darkblue",             # Colour inside the gene blocks
    geneSymbol = TRUE
  )
  
  x_ascat <- ascat %>% filter(chr == 'chrX')
  
  gr_ascat <- GRanges(
    #seqnames = x_ascat$chr,
    #ranges = IRanges(start = x_ascat$start, end = x_ascat$end),
    seqnames = x_lrr$Chr, 
    ranges = IRanges(x_lrr$Start, x_lrr$Position),
    score = x_ascat$TCN
  )
  
  tcn_track <- DataTrack(
    range = gr_ascat,
    name = "ASCAT TCN", 
    type = "l", 
    fill = 'cadetblue',
    col = "darkcyan",
    baseline = 0
    #ylim = c(0, max(4, max(current_ascat$TCN) + 1))
  )
  
  hlgt <- HighlightTrack(
    c(gtrack, gene_track, lrr_seg_overlay, tcn_track),
    start = x_from,
    end = x_to,
    chromosome = 'chrX',
    fill =  "#FFFFA033",
    col =  "#FFCC00"
  )
  
  png(filename = 'PAR1.png', width = 1800, height = 1200, res = 150)
  
  plotTracks(
    #gtrack, current_overlay, gene_track
    c(itrack, hlgt), 
    chromosome = 'chrX',
    from = max(1, x_from - 100000), 
    to = x_to + 100000, 
    sizes = c(0.2, 0.5, 0.6, 0.5 ,0.5),
    main = "Region View: PAR1",
    fontmain = 2,
    cex.main = 1.2
  )
  
  dev.off()
  
  message("Saved plot for gene: PAR1 -> gviz_PAR1.png")
  
  #plotTracks(c(itrack,gtrack, lrr_seg, gene_track), from = from , to = to, sizes = c(0.2, 0.5, 1, 1), main = "PAR1")
  
  
  
}





plotGenes <- function(lrr, seg, ascat, panel, genes) {
  lrr$chr <- paste0('chr', lrr$Chr)
  lrr$Start <- lrr$Position - 1
  
  gr_lrr <- GRanges(seqnames = lrr$chr, 
                    ranges = IRanges(lrr$Start, lrr$Position), 
                    lrr = lrr$Log.R.Ratio)

  
  flat_segments <- seg %>%
    rowwise() %>%
    do(data.frame(
      chrom = .$chrom,
      pos = c(.$loc.start, .$loc.end),      # Both boundaries get the same value
      seg.mean = c(.$seg.mean, .$seg.mean),
      call = c(.$call, .$call)
    ))
  
  gr_seg <- GRanges(
    seqnames = flat_segments$chrom,
    ranges = IRanges(start = flat_segments$pos, end = flat_segments$pos),
    score = flat_segments$seg.mean
  )

  gr_genes <- GRanges(
    seqnames = genes$Chromosome,
    ranges = IRanges(start = genes$Start, end = genes$End),
    strand = genes$Strand,
    feature = genes$gene_type,   # Groups exons/features visually if needed
    gene = genes$gene_id,        # Unique gene identifier
    symbol = genes$gene_name     # Human-readable labels printed on the plot
  )  
  
  padding <- 100000
  
  colnames(panel) <- c('chrom', 'start', 'end', 'gene')
  
  gene_panel <- panel %>% filter(chrom != 'chrX')

  for (i in 1:nrow(gene_panel)) {
    current_gene <- gene_panel$gene[i]
    current_chrom <- gene_panel$chrom[i]
    current_start <- gene_panel$start[i]
    current_end <- gene_panel$end[i]
    
    itrack <- IdeogramTrack(genome = 'hg38', chr = current_chrom)
    gtrack <- GenomeAxisTrack()
    
    plot_from <- max(1, gene_panel$start[i] - padding)
    plot_to <- gene_panel$end[i] + padding
    
    output_filename <- paste0(current_gene, ".png")
    
    png(filename = output_filename, width = 1200, height = 800, res = 150)
    
    current_lrr_track <- DataTrack(
      range = gr_lrr,
      chromosome = current_chrom,
      genome = genome,
      name = paste0(current_gene, '_custom_cbs'),
      type = 'p'
    )
    
    
    current_seg_track <- DataTrack(
      range = gr_seg,
      data = mcols(gr_seg)$score,
      chromosome = current_chrom,
      start = current_start,
      end = current_end,
      name = "Seg Mean",
      type = c("l"), # "l" for lines, "g" for background grid
      col = "firebrick",  # Line colour
      lwd = 4,            # Thick lines for high visibility
      ylim = c(-0.6, 0.2) # Set y-axis bounds to clearly see the drop
    ) 
    
    current_overlay <- OverlayTrack(list(current_lrr_track, current_seg_track) , name = paste0(current_gene, "_custom_cbs"))
    
    
    current_genes <- genes %>% filter(Chromosome == current_chrom)
    
    genes_gr <- GRanges(
      seqnames = current_genes$Chromosome,
      ranges = IRanges(start = current_genes$Start, end = current_genes$End),
      strand = current_genes$Strand,
      feature = current_genes$gene_type,   # Groups exons/features visually if needed
      gene = current_genes$gene_id,        # Unique gene identifier
      symbol = current_genes$gene_name     # Human-readable labels printed on the plot
    )
    
    gene_track <- GeneRegionTrack(
      range = genes_gr,
      genome = genome,
      chromosome = current_chrom,
      name = "Genes",
      transcriptAnnotation = "symbol",
      collapseTranscripts = "meta",  # Collapses alternative transcripts into a single line per gene
      shape = "arrow",               # Shows pointing arrows for gene direction/strand
      fill = "navy",             # Colour inside the gene blocks
      geneSymbol = TRUE
    )
    
    
    current_ascat <- ascat %>% filter(gene == current_gene)
    
    gr_ascat <- GRanges(
      seqnames = current_genes$Chromosome,
      ranges = IRanges(start = current_genes$Start, end = current_genes$End),
      #seqnames = current_ascat$chr,
      #ranges = IRanges(current_ascat$start, current_ascat$end),
      score = current_ascat$TCN
    )
    
    tcn_track <- DataTrack(
      
      range = gr_ascat,
      name = "ASCAT TCN", 
      type = "l", 
      fill = 'cadetblue',
      col = "darkcyan",
      baseline = 0
      #ylim = c(0, max(4, max(current_ascat$TCN) + 1))
    )
    
    current_highlight <- HighlightTrack(
      c(gtrack, gene_track, current_overlay, tcn_track),
      start = current_start,
      end = current_end,
      chromosome = current_chrom,
      fill =  "#FFFFA033",
      col =  "#FFCC00"
    )
    
    plotTracks(
      #gtrack, current_overlay, gene_track
      c(itrack, current_highlight), 
      chromosome = current_chrom,
      from = plot_from, 
      to = plot_to, 
      sizes = c(0.2, 0.5, 1, 0.6 ,0.5),
      main = paste("Gene View:", current_gene), # Adds a clear title to the top
      fontmain = 2,
      cex.main = 1.2
    )
    
    dev.off()
    
    message("Saved plot for gene: ", current_gene, " -> ", output_filename)
    
  }
    
}


plotPAR1(lrr, seg, ascat_calls, panel, genes)
plotGenes(lrr, seg, ascat_calls, panel, genes)


#ascat_calls <- as.data.frame(read.csv('206617090143_32466/ascat/206617090143_32466_gene_level_ascat_calls.tsv', sep = '\t'))
#gene_panel <- as.data.frame(read.csv('panel.ranges.tsv', sep = '\t', header = FALSE))





