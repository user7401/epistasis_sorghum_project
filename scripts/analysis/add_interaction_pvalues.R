#!/usr/bin/env Rscript

library(qs)

args <- commandArgs(trailingOnly = TRUE)
qs_dir <- if (length(args) >= 1) args[1] else "results/"

qs_files <- list.files(qs_dir, pattern = "\\.qs$", full.names = TRUE)

for (file in qs_files) {
  data <- qread(file)
  
  numeric_cols <- c("BETA_SNP1", "BETA_SNP2", "BETA_INTERACTION", "SE_SNP1", "SE_SNP2", "SE_INTERACTION")
  data[numeric_cols] <- lapply(data[numeric_cols], as.numeric)
  
  data$z_INTERACTION <- data$BETA_INTERACTION / data$SE_INTERACTION
  data$p_value_INTERACTION <- 2 * pnorm(-abs(data$z_INTERACTION))
  
  qsave(data, file)
  cat("Updated file saved:", file, "\n")
}
