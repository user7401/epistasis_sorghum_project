# Function to check and install packages if they are not installed
install_if_missing <- function(package) {
  if (!requireNamespace(package, quietly = TRUE)) {
    install.packages(package, repos = "http://cran.us.r-project.org")
  }
}

# List of packages to check and install
packages <- c("targets", "tarchetypes", "vcfR", "dplyr", "future.apply", "parallel", "MM4LMM", "qs", "ggplot2")

# Install missing packages
invisible(lapply(packages, install_if_missing))

# Load the required packages
library(targets)
library(tarchetypes)
library(vcfR)
library(dplyr)
library(future.apply)
library(parallel)

testing_mode <- TRUE

source("load_n_proc.R")
source("mm4lmm_fitting.R")
source("extract_info.R")

# Set target options
tar_option_set(
  packages = c("vcfR", "dplyr", "MM4LMM", "future.apply", "parallel"),
  format = if (testing_mode) "qs" else "rds"
)

# Define pipeline
list(
  tar_target(
    vcf_data,
    load_vcf_data()
  ),
  tar_target(
    geno_numeric,
    convert_genotype_values(vcf_data$geno)
  ),
  tar_target(
    pcs_3,
    load_pcs()
  ),
  tar_target(
    phenotype_data,
    load_and_filter_phenotype_data(geno_numeric)
  ),
  tar_target(
    filtered_kinship_matrix,
    load_and_filter_kinship_matrix(geno_numeric)
  ),
  tar_target(
    X_triplet_list,
    create_triplet_list(geno_numeric)
  ),
  tar_target(
    VarList,
    create_var_list(filtered_kinship_matrix, phenotype_data$Y)
  ),
  tar_target(
    reml_full_3pcs,
    fit_reml_model(phenotype_data$Y, X_triplet_list, pcs_3, VarList)
  ),
  tar_target(
    ml_full_3pcs,
    fit_ml_model(phenotype_data$Y, X_triplet_list, pcs_3, VarList)
  ),
  tar_target(
    X_triplet_list_reduced_no_interaction,
    create_reduced_triplet_list(X_triplet_list)
  ),
  tar_target(
    ml_reduced_no_interaction,
    fit_ml_reduced_model(phenotype_data$Y, X_triplet_list_reduced_no_interaction, pcs_3, VarList)
  ),
  tar_target(
    reml_info,
    extract_model_info(reml_full_3pcs, "reml_full_3pcs"),
    format = "qs"
  )
)
