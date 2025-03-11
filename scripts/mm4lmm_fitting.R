# Function to create the VarList
create_var_list <- function(filtered_kinship_matrix, Y) {
  list(Additive = filtered_kinship_matrix, Error = diag(1, length(Y)))
}
gc()
# Function to fit the REML model with 3 PCs included
fit_reml_model <- function(Y, X_triplet_list, pcs_3, VarList) {
  MMEst(Y = Y, X = X_triplet_list, Cofactor = pcs_3, VarList = VarList, Method = "Reml", NbCores = 12)
}
gc()
# Function to fit the ML model with 3 PCs included
#fit_ml_model <- function(Y, X_triplet_list, pcs_3, VarList) {
  #MMEst(Y = Y, X = X_triplet_list, Cofactor = pcs_3, VarList = VarList, Method = "ML", NbCores = 5)
#}
#gc()
# Function to create the reduced X_triplet_list without interaction terms
#create_reduced_triplet_list <- function(X_triplet_list) {
  #lapply(X_triplet_list, function(mat) mat[, 1:2])  # Only keep SNP1 and SNP2 columns
#}
#gc()
# Function to fit the reduced ML model without interaction terms
#fit_ml_reduced_model <- function(Y, X_triplet_list_reduced, pcs_3, VarList) {
  #MMEst(Y = Y, X = X_triplet_list_reduced, Cofactor = pcs_3, VarList = VarList, Method = "ML", NbCores = 5)
#}
#gc()
