#!/usr/bin/env Rscript

library(qs)

args <- commandArgs(trailingOnly = TRUE)
qs_dir <- if (length(args) >= 1) args[1] else "results/"

qs_files <- list.files(qs_dir, pattern = "^result_df_.*\\.qs$", full.names = TRUE)

for (file in qs_files) {
  data <- qread(file)
  data$q_value_INTERACTION <- p.adjust(data$p_value_INTERACTION, method = "BH")
  qsave(data, file)
  cat("FDR correction applied and saved for file:", file, "\n")
}
