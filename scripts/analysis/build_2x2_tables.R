#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(qs)
})

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  cat("Usage:\n",
      "  Rscript build_2x2_tables.R <folder_path> [p_threshold]\n\n",
      "Args:\n",
      "  folder_path   Path to the folder containing marginal/interaction .qs files (required)\n",
      "  p_threshold   Significance threshold (optional; default 0.01)\n",
      sep = "")
  quit(status = 1)
}

folder_path <- args[[1]]
p_threshold <- if (length(args) >= 2) as.numeric(args[[2]]) else 0.01

# List of traits
traits <- c("amylose", "cal_g", "dta", "fat", "gn", "gw", "gy", "ph", "protein", "starch")

# Loop through each trait
for (trait in traits) {
  
  # Construct file paths for marginal and interaction data
  marginal_file <- file.path(folder_path, paste0("results_df_", trait, "_marginal"))
  interaction_file <- file.path(folder_path, paste0("result_df_", trait))
  
  # Load the marginal and interaction data
  marginal_data <- qread(marginal_file)
  interaction_data <- qread(interaction_file)
  
  # Add significance column to the marginal data
  marginal_data <- marginal_data %>%
    mutate(significant_marginal = ifelse(p_value_SNP < p_threshold, TRUE, FALSE))
  
  # Add significance column to the interaction data
  interaction_data <- interaction_data %>%
    mutate(significant_interaction = ifelse(p_value_INTERACTION < p_threshold, TRUE, FALSE))
  
  # Extract list of marginally significant SNPs
  significant_snps <- marginal_data$SNP_ID[marginal_data$significant_marginal]
  
  # Map marginal significance to interaction dataset
  interaction_data <- interaction_data %>%
    rowwise() %>%
    mutate(significant_marginal = 
             any(SNP1_ID %in% significant_snps, SNP2_ID %in% significant_snps))
  
  # Construct the 2x2 table
  table_2x2 <- table(
    Marginal_Significant = interaction_data$significant_marginal,
    Interaction_Significant = interaction_data$significant_interaction
  )
  
  # Print the 2x2 table for inspection
  cat("\n2x2 Table of Marginal vs Interaction Significance for", trait, ":\n")
  print(table_2x2)
  
  # Save the 2x2 table as a .qs file without the .qs extension in the name
  table_2x2_df <- as.data.frame(table_2x2)
  output_file <- file.path(folder_path, paste0("2x2_table_marginal_vs_interaction_", trait, "_", p_threshold))
  qsave(table_2x2_df, output_file)
  
  # Confirmation message
  cat("2x2 table saved for", trait, "as:", output_file, "\n")
}
