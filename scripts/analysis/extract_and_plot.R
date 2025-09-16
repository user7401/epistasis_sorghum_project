# Set the parallel plan once at the beginning
num_cores <- 15
plan(multisession, workers = num_cores)

options(future.globals.maxSize = 64 * 1024^3)  # 64 GiB

# Function to extract and plot REML p-values
extract_and_plot_reml_pvalues <- function(reml_full_3pcs, output_pvalue_file, output_plot_file) {
  # Initialize counters
  non_7x7_varbeta_count <- 0

  # Parallel loop to extract p-values
  results <- future_lapply(seq_along(reml_full_3pcs), function(i) {
    beta_values <- reml_full_3pcs[[i]]$Beta
    varbeta_matrix <- reml_full_3pcs[[i]]$VarBeta

    if (length(beta_values) >= 7 && nrow(varbeta_matrix) >= 7 && ncol(varbeta_matrix) >= 7) {
      beta_snp1 <- beta_values[5]
      beta_snp2 <- beta_values[6]
      beta_interaction <- beta_values[7]

      var_snp1 <- varbeta_matrix[5, 5]
      var_snp2 <- varbeta_matrix[6, 6]
      var_interaction <- varbeta_matrix[7, 7]

      se_snp1 <- sqrt(var_snp1)
      se_snp2 <- sqrt(var_snp2)
      se_interaction <- sqrt(var_interaction)

      z_snp1 <- beta_snp1 / se_snp1
      z_snp2 <- beta_snp2 / se_snp2
      z_interaction <- beta_interaction / se_interaction

      p_snp1 <- 2 * (1 - pnorm(abs(z_snp1)))
      p_snp2 <- 2 * (1 - pnorm(abs(z_snp2)))
      p_interaction <- 2 * (1 - pnorm(abs(z_interaction)))

      list(p_values = c(p_snp1, p_snp2, p_interaction))
    } else {
      non_7x7_varbeta_count <<- non_7x7_varbeta_count + 1
      list(p_values = rep(NA, 3))
    }
  }, future.seed = TRUE)

  # Extract interaction p-values
  p_values_list <- lapply(results, `[[`, "p_values")
  interaction_p_values <- sapply(p_values_list, function(p) p[3])

  # Save p-values
  qsave(interaction_p_values, output_pvalue_file)

  # Create a data frame and remove NA values
  pvalue_df <- data.frame(Interaction_PValues = interaction_p_values)
  pvalue_df <- na.omit(pvalue_df)

  # Plot the histogram
  plot <- ggplot(pvalue_df, aes(x = Interaction_PValues)) +
    geom_histogram(breaks = seq(0, 1, by = 0.02), fill = "blue", color = "black") +
    theme_minimal() +
    labs(title = "Distribution of Interaction P-values (REML)", x = "P-value", y = "Frequency") +
    scale_x_continuous(breaks = seq(0, 1, by = 0.1))

  # Save the plot
  ggsave(output_plot_file, plot = plot)
}

# Function to extract and plot LRT p-values
extract_and_plot_lrt_pvalues <- function(ml_full_3pcs, ml_reduced_no_interaction, output_pvalue_file, output_plot_file) {
  # Function to perform LRT for each SNP pair
  perform_lrt <- function(i) {
    loglik_full <- ml_full_3pcs[[i]]$LogLik
    loglik_reduced <- ml_reduced_no_interaction[[i]]$LogLik
    lrt_statistic <- -2 * (loglik_reduced - loglik_full)
    p_value <- pchisq(lrt_statistic, df = 1, lower.tail = FALSE)
    return(p_value)
  }

  # Parallelized loop to compute LRT p-values
  interaction_p_values <- future_lapply(seq_along(ml_full_3pcs), perform_lrt, future.seed = TRUE)
  interaction_p_values <- unlist(interaction_p_values)

  # Save p-values
  qsave(interaction_p_values, output_pvalue_file)

  # Create a data frame and remove NA values
  pvalue_df <- data.frame(Interaction_PValues = interaction_p_values)
  pvalue_df <- na.omit(pvalue_df)

  # Plot the histogram
  plot <- ggplot(pvalue_df, aes(x = Interaction_PValues)) +
    geom_histogram(breaks = seq(0, 1, by = 0.01), fill = "blue", color = "black") +
    theme_minimal() +
    labs(title = "Distribution of Interaction P-values (LRT)", x = "P-value", y = "Frequency")

  # Save the plot
  ggsave(output_plot_file, plot = plot)
}
