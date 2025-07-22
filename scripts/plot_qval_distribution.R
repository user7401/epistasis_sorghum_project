#!/usr/bin/env Rscript

library(ggplot2)
library(qs)

args <- commandArgs(trailingOnly = TRUE)
file_path <- if (length(args) >= 1) args[1] else "results/result_df_example.qs"

data <- qread(file_path)

output_plot <- "q_value_distribution.png"

breaks <- seq(0, 1, by = 0.01)

png(output_plot, width = 800, height = 600)
ggplot(data, aes(x = q_value_INTERACTION)) +
  geom_histogram(breaks = breaks, fill = "purple", alpha = 0.7, color = "black") +
  labs(title = "Q-value Distribution",
       x = "Q-value (FDR-adjusted P-value)",
       y = "Frequency") +
  theme_minimal()
dev.off()

cat("Q-value plot saved as:", output_plot, "\n")
