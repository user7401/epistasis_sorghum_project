# MM4LMM model fitting helpers for the epistasis pipeline.
#
# These functions build the variance-component structure and fit the full
# REML model (SNP1 + SNP2 + interaction) used by the {targets} pipeline.

# Build the VarList passed to MMEst: an additive (kinship) component plus an
# i.i.d. error component.
create_var_list <- function(filtered_kinship_matrix, Y) {
  list(Additive = filtered_kinship_matrix, Error = diag(1, length(Y)))
}

# Fit the full REML model with the first 3 PCs included as cofactors.
fit_reml_model <- function(Y, X_triplet_list, pcs_3, VarList) {
  MMEst(Y = Y, X = X_triplet_list, Cofactor = pcs_3, VarList = VarList,
        Method = "Reml", NbCores = 12)
}

# --- Alternative ML-based path (used for the LRT analysis; see report) -------
# These were used to compare the full model against a reduced model without the
# interaction term via a likelihood-ratio test. Kept for reference.
#
# fit_ml_model <- function(Y, X_triplet_list, pcs_3, VarList) {
#   MMEst(Y = Y, X = X_triplet_list, Cofactor = pcs_3, VarList = VarList,
#         Method = "ML", NbCores = 5)
# }
#
# # Drop the interaction column, keeping only SNP1 and SNP2.
# create_reduced_triplet_list <- function(X_triplet_list) {
#   lapply(X_triplet_list, function(mat) mat[, 1:2])
# }
#
# fit_ml_reduced_model <- function(Y, X_triplet_list_reduced, pcs_3, VarList) {
#   MMEst(Y = Y, X = X_triplet_list_reduced, Cofactor = pcs_3, VarList = VarList,
#         Method = "ML", NbCores = 5)
# }
