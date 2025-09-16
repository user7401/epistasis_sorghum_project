#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(qs)
  library(dplyr)
})

args <- commandArgs(trailingOnly = TRUE)

if (length(args) < 1) {
  cat("Usage:\n",
      "  Rscript chi_sq_test_2x2.R <2x2_table.qs>\n",
      "Args:\n",
      "  2x2_table.qs   Path to the serialized 2x2 table (.qs)\n",
      sep = "")
  quit(status = 1)
}

input_file <- args[[1]]

table_2x2 <- qread(input_file)

# Convert the table to a contingency table
table_matrix <- xtabs(Freq ~ Marginal_Significant + Interaction_Significant, data = table_2x2)

# Perform the Chi-squared test
chi_sq_test <- chisq.test(table_matrix)

# Extract expected counts
expected_counts <- chi_sq_test$expected

# Verify assumptions of the Chi-squared test
all_expected_ge_1 <- all(expected_counts >= 1)
proportion_less_than_5 <- sum(expected_counts < 5) / length(expected_counts)

cat("Are all expected frequencies >= 1?", all_expected_ge_1, "\n")
cat("Proportion of categories with expected frequencies < 5:", proportion_less_than_5, "\n")
cat("Does the proportion satisfy the 20% rule?", proportion_less_than_5 <= 0.2, "\n")

# Print the expected counts for inspection
cat("Expected Counts:\n")
print(expected_counts)

# Run the Chi-squared test if assumptions are satisfied
if (all_expected_ge_1 & proportion_less_than_5 <= 0.2) {
  cat("Running Chi-Squared Test...\n")
  print("Chi-Squared Test Results:")
  print(chi_sq_test)
} else {
  cat("Chi-Squared Test assumptions not satisfied. Consider using Fisher's Exact Test.\n")
}

# Calculate enrichment ratio
observed_true_true <- table_matrix["TRUE", "TRUE"]
expected_true_true <- expected_counts["TRUE", "TRUE"]
enrichment_ratio <- observed_true_true / expected_true_true
cat("Enrichment Ratio for True-True:", enrichment_ratio, "\n")
