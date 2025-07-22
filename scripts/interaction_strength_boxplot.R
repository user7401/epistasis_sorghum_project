#!/usr/bin/env Rscript

library(qs)

args <- commandArgs(trailingOnly = TRUE)
marginal_file <- if (length(args) >= 1) args[1] else "marginal.qs"
interaction_file <- if (length(args) >= 2) args[2] else "interaction.qs"

marginal_data <- qread(marginal_file)
interaction_data <- qread(interaction_file)

threshold <- 0.05

# SNPs with significant marginal effects
significant_snps <- marginal_data$SNP_ID[marginal_data$p_value_SNP < threshold]

# Filter interactions involving significant marginal SNPs
interaction_significant_snps <- interaction_data[
  interaction_data$SNP1_ID %in% significant_snps | interaction_data$SNP2_ID %in% significant_snps, ]

# SNPs without significant marginal effects
non_significant_snps <- setdiff(marginal_data$SNP_ID, significant_snps)

# Filter interactions involving non-significant marginal SNPs
interaction_non_significant_snps <- interaction_data[
  interaction_data$SNP1_ID %in% non_significant_snps & interaction_data$SNP2_ID %in% non_significant_snps, ]

# Check if there are data points to plot
if (nrow(interaction_significant_snps) == 0 | nrow(interaction_non_significant_snps) == 0) {
  cat("No interactions available for one of the groups. Please check your data.\n")
} else {
  png("interaction_strength_boxplot.png", width = 800, height = 600)
  
  boxplot(
    -log10(interaction_significant_snps$p_value_INTERACTION),
    -log10(interaction_non_significant_snps$p_value_INTERACTION),
    names = c("Significant Marginal SNPs", "Non-significant Marginal SNPs"),
    main = "Interaction Strength by SNP Marginal Significance",
    ylab = "-log10(Interaction p-value)",
    col = c("blue", "red")
  )
  
  dev.off()
  
  cat("Boxplot saved as 'interaction_strength_boxplot.png'\n")
}
