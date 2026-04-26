

cyto <- read.table('cytoBand.txt.gz', header = FALSE, sep = '\t' , col.names = c("chrom", "start", "end", "name", "gieStain"))

#CDKN2A/B 9p21.3 PAX5 9p13.2 RB1 13q14.2 ETV6 12p13.2 BTG1 12q24.33 EBF1 5q33.3 PAR1 Xp22.33 / Yp11.31
IKZF1 <- cyto[cyto$name == "p12.2" & cyto$chrom == "chr7", ]
CDKN2AB <- cyto[cyto$name == "p21.3" & cyto$chrom == "chr9", ]
PAX5 <- cyto[cyto$name == "p13.2" & cyto$chrom == "chr9", ]
RB1 <- cyto[cyto$name == "q14.2" & cyto$chrom == "chr13", ]
ETV6 <- cyto[cyto$name == "p13.2" & cyto$chrom == "chr12", ]
BTG1 <- cyto[cyto$name == "q24.33" & cyto$chrom == "chr12", ]
EBF1 <- cyto[cyto$name == "q33.3" & cyto$chrom == "chr5", ]
PAR1 <- cyto[cyto$name == "p22.33" & cyto$chrom == "chrX", ]
loci <- rbind(IKZF1, CDKN2AB, PAX5, RB1, ETV6, BTG1, EBF1, PAR1)

genes <-  c("IKZF1", "CDKN2AB", "PAX5", "RB1", "ETV6", "BTG1", "EBF1", "PAR1")

loci <- cbind(loci, genes)

write.table(loci, 'loci.hg38.tsv', sep='\t', row.names = FALSE)


