#!/usr/bin/env Rscript

library(qs)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
file_path <- if (length(args) >= 1) args[1] else "results/example.qs"

data <- qread(file_path)

breaks <- seq(0, 1, by = 0.01)

png("p_value_distribution_detailed.png", width = 800, height = 600)
ggplot(data, aes(x = p_value_INTERACTION)) +
  geom_histogram(breaks = breaks, fill = "blue", alpha = 0.7, color = "black") +
  labs(title = "Detailed P-value Distribution for SNP-SNP Interactions",
       x = "Raw P-value",
       y = "Frequency") +
  theme_minimal()
dev.off()

cat("Plot saved as: p_value_distribution_detailed.png\n")
