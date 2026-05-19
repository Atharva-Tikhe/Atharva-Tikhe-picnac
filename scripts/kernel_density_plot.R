library(ggplot2)

calls <- read.csv("~/dev/pipeline/executions/test_undo_wave_corr/205966470077_32349/wave_correction_cbs/205966470077_32349.hg38.calls.tsv", sep = "\t")

calls.seg.means <- calls$seg.mean

ggplot(data.frame(calls.seg.means), aes(x = calls.seg.means)) + 
  geom_density(fill = "steelblue", alpha = 0.4) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") + 
  geom_vline(xintercept = -0.2, linetype = "dashed", color = "blue") +
  labs(title = "Kernel Density of Segment Means (PennCNV correction; SD-Undo=2) (205549190163_32287)", x = "Segment Mean", y = "Density")

calls <- read.csv("~/opt/PennCNV-1.0.5/example/process_bed/205030250086_32217_post_corr.hg38.calls.tsv", sep = "\t")

calls.seg.means <- calls$seg.mean

ggplot(data.frame(calls.seg.means), aes(x = calls.seg.means)) + 
  geom_density(fill = "steelblue", alpha = 0.4) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") + 
  geom_vline(xintercept = -0.2, linetype = "dashed", color = "blue") +
  labs(title = "Kernel Density of Segment Means (PennCNV correction; DNAcopy undo.splits)", x = "Segment Mean", y = "Density")

