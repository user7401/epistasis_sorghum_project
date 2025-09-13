#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(qs)
  library(ggplot2)
  library(dplyr)
  library(RColorBrewer)
})

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  cat("Usage:\n",
      "  Rscript plot_enrichment_vs_threshold.R <output_folder> [thresholds]\n\n",
      "Args:\n",
      "  output_folder   Path to folder with result files (required)\n",
      "  thresholds      Comma-separated list of thresholds (optional; default: 0.05,0.01,0.005,0.001)\n",
      sep = "")
  quit(status = 1)
}

output_folder <- args[[1]]
thresholds <- if (length(args) >= 2) strsplit(args[[2]], ",")[[1]] else c("0.05", "0.01", "0.005", "0.001")

# Initialize a data frame to store enrichment results
enrichment_data <- data.frame(Threshold = numeric(), Enrichment_Ratio = numeric(), Trait = character())

# Loop through thresholds to extract enrichment ratios
for (threshold in thresholds) {
  result_files <- list.files(
    path = output_folder,
    pattern = paste0("test_results_.*_", threshold, "$"),
    full.names = TRUE
  )
  
  for (file in result_files) {
    result <- qread(file)
    enrichment_data <- rbind(enrichment_data, data.frame(
      Threshold = as.numeric(threshold),
      Enrichment_Ratio = result$enrichment_ratio,
      Trait = result$Trait
    ))
  }
}

# Ensure Threshold is numeric
enrichment_data$Threshold <- as.numeric(enrichment_data$Threshold)

# Define color palette
distinct_colors <- brewer.pal(n = length(unique(enrichment_data$Trait)), name = "Set3")
names(distinct_colors) <- unique(enrichment_data$Trait)

# Modify specific colors for visibility
if ("cal_g" %in% names(distinct_colors)) distinct_colors["cal_g"] <- "#FF9900"
if ("protein" %in% names(distinct_colors)) distinct_colors["protein"] <- "#00008B"

# Plot
enrichment_plot <- ggplot(enrichment_data, aes(x = Threshold, y = Enrichment_Ratio, color = Trait)) +
  geom_point(size = 3) +
  geom_line(aes(group = Trait), linewidth = 1) +
  scale_x_reverse(breaks = as.numeric(thresholds)) +
  scale_y_log10() +
  scale_color_manual(values = distinct_colors) +
  labs(
    title = "Enrichment vs P-Value Threshold (Log Scale)",
    x = "P-Value Threshold",
    y = "Enrichment Ratio (Log Scale)",
    color = "Trait"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "right",
    legend.title = element_text(size = 12),
    legend.text = element_text(size = 10),
    panel.grid.major = element_line(color = "gray", linewidth = 0.5),
    panel.grid.minor = element_line(color = "lightgray", linewidth = 0.25)
  )

# Save & print
ggsave(file.path(output_folder, "enrichment_vs_threshold_traits.png"),
       plot = enrichment_plot, width = 12, height = 8)

print(enrichment_plot)
