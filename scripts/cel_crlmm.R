if (!require("BiocManager", quietly = TRUE))
  install.package("BiocManager")

if (!require("crlmm", quietly = TRUE)) {
  BiocManager::install("crlmm")
} else {
  library("crlmm")
}



