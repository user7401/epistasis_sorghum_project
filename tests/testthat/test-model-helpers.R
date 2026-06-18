test_that("create_var_list returns an additive (kinship) and error component", {
  K <- diag(c(1, 2, 3))
  Y <- c(10, 20, 30)

  vl <- create_var_list(K, Y)

  expect_named(vl, c("Additive", "Error"))
  expect_equal(vl$Additive, K)
  expect_equal(vl$Error, diag(1, 3))
  expect_equal(dim(vl$Error), c(3L, 3L))
})

# Build a minimal MM4LMM-like model entry with a 7-element Beta and 7x7 VarBeta.
make_model_entry <- function(beta = 1:7, varbeta = diag(7)) {
  list(Beta = beta, VarBeta = varbeta)
}

test_that("extract_reml_info pulls SNP IDs, betas and standard errors", {
  reml <- list(make_model_entry(), make_model_entry())
  names(reml) <- c("snpA_interaction_snpB", "snpC_interaction_snpD")

  df <- extract_reml_info(reml)

  expect_equal(nrow(df), 2)
  expect_equal(df$SNP1_ID, c("snpA", "snpC"))
  expect_equal(df$SNP2_ID, c("snpB", "snpD"))

  # Beta entries 5, 6, 7 are SNP1, SNP2 and the interaction.
  expect_equal(as.numeric(df$BETA_SNP1), c(5, 5))
  expect_equal(as.numeric(df$BETA_SNP2), c(6, 6))
  expect_equal(as.numeric(df$BETA_INTERACTION), c(7, 7))

  # SEs are sqrt of the corresponding VarBeta diagonal (here sqrt(1) == 1).
  expect_equal(as.numeric(df$SE_SNP1), c(1, 1))
  expect_equal(as.numeric(df$SE_INTERACTION), c(1, 1))
})

test_that("extract_reml_info skips entries with a non-7x7 VarBeta", {
  reml <- list(
    make_model_entry(),
    make_model_entry(varbeta = diag(5))  # defective dimensions
  )
  names(reml) <- c("good_interaction_pair", "bad_interaction_pair")

  expect_warning(df <- extract_reml_info(reml), "VarBeta is not 7x7")

  # The good entry is parsed; the defective one is left as an all-NA row.
  expect_equal(df$SNP1_ID[1], "good")
  expect_true(all(is.na(df[2, ])))
})
