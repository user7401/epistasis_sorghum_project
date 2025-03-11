# Function to extract information from all entries of reml_full_3pcs
extract_reml_info <- function(reml_full_3pcs) {
  # Initialize an empty matrix to store results for all entries
  results <- matrix(ncol = 8, nrow = length(reml_full_3pcs))
  colnames(results) <- c("SNP1_ID", "SNP2_ID", "BETA_SNP1", "BETA_SNP2", "BETA_INTERACTION", "SE_SNP1", "SE_SNP2", "SE_INTERACTION")

  # Counter for defective entries
  defective_entries_count <- 0

  # Loop through all entries to extract information
  for (i in 1:length(reml_full_3pcs)) {
    model_entry <- reml_full_3pcs[[i]]
    model_entry_name <- names(reml_full_3pcs)[i]

    # Extract SNP IDs from the model entry name
    snp_names <- strsplit(model_entry_name, "_interaction_")[[1]]
    
    # Check for successful parsing of SNP IDs
    if (length(snp_names) != 2) {
      warning("SNP IDs could not be parsed for entry: ", model_entry_name)
      defective_entries_count <- defective_entries_count + 1
      next  # Skip this entry
    }
    
    snp1_id <- snp_names[1]
    snp2_id <- snp_names[2]
    
    # Check if VarBeta is 7x7
    varbeta_matrix <- model_entry$VarBeta
    if (!all(dim(varbeta_matrix) == c(7, 7))) {
      warning("VarBeta is not 7x7 for entry: ", model_entry_name)
      defective_entries_count <- defective_entries_count + 1
      next  # Skip this entry
    }
    
    # Extract beta values
    beta_values <- model_entry$Beta
    beta_snp1 <- beta_values[5]
    beta_snp2 <- beta_values[6]
    beta_interaction <- beta_values[7]

    # Extract variances and calculate standard errors
    var_snp1 <- varbeta_matrix[5, 5]
    var_snp2 <- varbeta_matrix[6, 6]
    var_interaction <- varbeta_matrix[7, 7]

    se_snp1 <- sqrt(var_snp1)
    se_snp2 <- sqrt(var_snp2)
    se_interaction <- sqrt(var_interaction)

    # Fill in the results matrix
    results[i, ] <- c(snp1_id, snp2_id, beta_snp1, beta_snp2, beta_interaction, se_snp1, se_snp2, se_interaction)
  }

  # Convert to a data frame for easier viewing/manipulation
  results_df <- as.data.frame(results, stringsAsFactors = FALSE)

  # Print the number of defective entries
  cat("Number of defective entries skipped: ", defective_entries_count, "\n")

  return(results_df)
}
