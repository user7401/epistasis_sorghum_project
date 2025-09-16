#!/usr/bin/env Rscript

library(qs)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
marginal_file <- if (length(args) >= 1) args[1] else "marginal_effects.qs"
interaction_file <- if (length(args) >= 2) args[2] else "interaction_effects.qs"

marginal_data <- qread(marginal_file)
str(marginal_data)

interaction_data <- qread(interaction_file)
str(interaction_data)

# Filter significant marginal SNPs
significant_snps <- marginal_data[marginal_data$p_value_SNP < 0.05, ]
significant_snps <- significant_snps[, c("SNP_ID", "BETA_SNP", "p_value_SNP")]

# View significant SNPs
print(significant_snps)

# Merge SNP1 marginal info
interaction_data <- merge(interaction_data, marginal_data, by.x = "SNP1_ID", by.y = "SNP_ID", all.x = TRUE)
colnames(interaction_data)[(ncol(interaction_data)-4):ncol(interaction_data)] <- c(
  "marginal_beta_SNP1", "marginal_SE_SNP1", "marginal_z_SNP1", "marginal_p_value_SNP1", "marginal_q_value_SNP1"
)

# Merge SNP2 marginal info
interaction_data <- merge(interaction_data, marginal_data, by.x = "SNP2_ID", by.y = "SNP_ID", all.x = TRUE)
colnames(interaction_data)[(ncol(interaction_data)-4):ncol(interaction_data)] <- c(
  "marginal_beta_SNP2", "marginal_SE_SNP2", "marginal_z_SNP2", "marginal_p_value_SNP2", "marginal_q_value_SNP2"
)

# Filter significant interactions
significant_interactions <- interaction_data[
  interaction_data$marginal_p_value_SNP1 < 0.05 |
    interaction_data$marginal_p_value_SNP2 < 0.05 |
    interaction_data$p_value_INTERACTION < 0.05, 
]

cat("Number of significant interactions:", nrow(significant_interactions), "\n")

# Save significant interactions
filtered_file_path <- "significant_interactions_amylose.qs"
qsave(significant_interactions, filtered_file_path)

# Plot 1: SNP1 vs Interaction p-values
output_plot <- "marginal_vs_interaction_pvalues_amylose.png"
png(output_plot, width = 800, height = 600)
ggplot(interaction_data, aes(x = -log10(p_value_INTERACTION), 
                             y = -log10(marginal_p_value_SNP1))) +
  geom_point(alpha = 0.5, color = "blue") +
  labs(title = "Marginal vs Interaction P-values (SNP1) for Amylose",
       x = "-log10(Interaction P-value)",
       y = "-log10(Marginal P-value SNP1)") +
  theme_minimal()
dev.off()

# Plot 2: SNP2 vs Interaction p-values
output_plot <- "marginal_vs_interaction_pvalues_amylose_SNP2.png"
png(output_plot, width = 800, height = 600)
ggplot(interaction_data, aes(x = -log10(p_value_INTERACTION), 
                             y = -log10(marginal_p_value_SNP2))) +
  geom_point(alpha = 0.5, color = "blue") +
  labs(title = "Marginal vs Interaction P-values (SNP2) for Amylose",
       x = "-log10(Interaction P-value)",
       y = "-log10(Marginal P-value SNP2)") +
  theme_minimal()
dev.off()

# Classify significance types
interaction_data$Significance <- ifelse(
  interaction_data$marginal_p_value_SNP1 < 0.05 & interaction_data$marginal_p_value_SNP2 < 0.05 & interaction_data$p_value_INTERACTION < 0.05,
  "Both SNPs and Interaction Significant",
  ifelse(interaction_data$marginal_p_value_SNP1 < 0.05 & interaction_data$marginal_p_value_SNP2 < 0.05,
         "Both SNPs Significant",
         ifelse(interaction_data$marginal_p_value_SNP1 < 0.05 & interaction_data$p_value_INTERACTION < 0.05,
                "SNP1 and Interaction Significant",
                ifelse(interaction_data$marginal_p_value_SNP2 < 0.05 & interaction_data$p_value_INTERACTION < 0.05,
                       "SNP2 and Interaction Significant",
                       ifelse(interaction_data$marginal_p_value_SNP1 < 0.05, "SNP1 Significant",
                              ifelse(interaction_data$marginal_p_value_SNP2 < 0.05, "SNP2 Significant",
                                     ifelse(interaction_data$p_value_INTERACTION < 0.05, "Interaction Significant", "Not Significant")))))))

# Plot 3: Colored significance plot
output_plot <- "marginal_vs_interaction_pvalues_amylose_colored.png"
png(output_plot, width = 800, height = 600)
ggplot(interaction_data, aes(x = -log10(p_value_INTERACTION), 
                             y = -log10(marginal_p_value_SNP1), 
                             color = Significance)) +
  geom_point(alpha = 0.5) +
  scale_color_manual(values = c(
    "Both SNPs Significant" = "red",
    "SNP1 Significant" = "blue",
    "SNP2 Significant" = "green",
    "Interaction Significant" = "purple",
    "Not Significant" = "grey"
  )) +
  labs(title = "Marginal vs Interaction P-values (SNP1) for Amylose",
       x = "-log10(Interaction P-value)",
       y = "-log10(Marginal P-value SNP1)",
       color = "Significance") +
  theme_minimal()
dev.off()
