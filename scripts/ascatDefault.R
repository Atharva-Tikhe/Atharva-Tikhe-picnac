library(ASCAT)
library(optparse)

option_list <- list(
                    make_option(c("-i", "--input"), type = "character", help = "Input BED file"),
                    make_option(c("-s", "--sample"), type = "character", help = "Sample ID")
)

opt <- parse_args(OptionParser(option_list = option_list))
input_file = opt$input
sample_id = opt$sample

ascat.bc <- ascat.loadData(Tumor_LogR_file=paste0(sample_id, '_Tumor_LRR.txt'), Tumor_BAF_file=paste0(sample_id,'_Tumor_BAF.txt'), Germline_LogR_file=NULL, Germline_BAF_file=NULL, genomeVersion = "hg38")

summary(ascat.bc)
ascat.plotRawData(ascat.bc, img.prefix="Raw_Data_")
ascat.gg <- ascat.predictGermlineGenotypes(ascat.bc, platform="IlluminaCytoSNP850k")
summary(ascat.gg)
ascat.bc.seg <- ascat.aspcf(ascat.bc, ascat.gg = ascat.gg)
ascat.plotSegmentedData(ascat.bc, img.prefix = "Segmented_Data_")
ascat.plotSegmentedData(ascat.bc.seg, img.prefix = "Segmented_Data_")
ascat.output <- ascat.runAscat(ascat.bc.seg)
print(ascat.output$purity)
print(ascat.output$ploidy)
