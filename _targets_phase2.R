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
library(qs)

testing_mode <- TRUE

source("extract_reml_info.R")

# Set target options
tar_option_set(
  packages = c("vcfR", "dplyr", "MM4LMM", "future.apply", "parallel"),
  format = if (testing_mode) "qs" else "rds"
)


# Define the target list
list(
  # Target to load the reml_full_3pcs object
  tar_target(
    reml_full_3pcs,
    qread("/faststorage/project/sorghum_vep/savvas/sorghum_project_part_2/desktop_to_hpc/targets_script/_targets/objects/reml_full_3pcs")
  ),
  
  # Target to extract information for the first 1000 entries
  tar_target(
    results_df,
    extract_reml_info(reml_full_3pcs)
  )
)
