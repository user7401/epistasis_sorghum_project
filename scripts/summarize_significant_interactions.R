#!/usr/bin/env Rscript

library(qs)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
marginal_file <- if (length(args) >= 1) args[1] else "results_df_marginal.qs"
interaction_file <- if (length(args) >= 2) args[2] else "result_df.qs"

marginal_data <- qread(marginal_file)
interaction_data <- qread(interaction_file)

# Basic column validation
stopifnot(all(c("SNP_ID", "p_value_SNP") %in% names(marginal_data)))
stopifnot(all(c("SNP1_ID", "SNP2_ID", "p_value_INTERACTION") %in% names(interaction_data)))

# Define significance threshold
threshold <- 0.05

# Identify significant marginal SNPs
significant_snps <- unique(marginal_data$SNP_ID[marginal_data$p_value_SNP < threshold])
cat("Number of significant marginal SNPs:", length(significant_snps), "\n")

# Filter interactions involving those SNPs
interaction_significant_snps <- interaction_data[
  interaction_data$SNP1_ID %in% significant_snps | 
    interaction_data$SNP2_ID %in% significant_snps, ]
cat("Number of interaction pairs involving significant SNPs:", nrow(interaction_significant_snps), "\n")

# Filter interactions that are themselves significant
significant_interactions <- interaction_significant_snps[
  interaction_significant_snps$p_value_INTERACTION < threshold, ]
cat("Number of interaction pairs with significant interaction p-values:", nrow(significant_interactions), "\n")

# Count number of significant interactions per marginal SNP
interaction_summary <- data.frame(
  SNP_ID = significant_snps,
  Significant_Interactions = sapply(significant_snps, function(snp) {
    sum(
      significant_interactions$SNP1_ID == snp | 
        significant_interactions$SNP2_ID == snp
    )
  })
)

# Save summary
output_file <- "significant_interaction_summary.qs"
qsave(interaction_summary, output_file)
cat("Summary of significant interactions saved at:", output_file, "\n")

# Create barplot of top 20 SNPs
top_interaction_summary <- interaction_summary[order(-interaction_summary$Significant_Interactions), ][1:20, ]

bar_plot <- ggplot(top_interaction_summary, aes(x = reorder(SNP_ID, -Significant_Interactions), y = Significant_Interactions)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  labs(
    title = "Top 20 SNPs with the Most Significant Interactions",
    x = "SNP ID",
    y = "Number of Significant Interactions"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.title = element_text(size = 14, face = "bold")
  )

ggsave("top_significant_interactions_barplot.png", plot = bar_plot, width = 10, height = 6)
