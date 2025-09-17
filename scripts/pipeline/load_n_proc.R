load_vcf_data <- function() {
  vcf <- read.vcfR("data/genotypes_pruned.vcf.gz")
  geno <- extract.gt(vcf)
  return(list(vcf = vcf, geno = geno))
}

# Function to load and process PCs
load_pcs <- function() {
  pcs <- read.table("pca_results.eigenvec", header = FALSE)
  pcs_3 <- pcs[, 2:4]  # Extract PC1 to PC3
  colnames(pcs_3) <- paste0("PC", 1:3)
  return(pcs_3)
}

# Function to convert genotype values to numeric
convert_genotype_values <- function(geno) {
  convert_genotype <- function(gt) {
    ifelse(gt == "0|0", 0,
           ifelse(gt %in% c("0|1", "1|0"), 1,
                  ifelse(gt == "1|1", 2, NA)))
  }
  geno_numeric <- t(apply(geno, 2, convert_genotype))
  return(geno_numeric)
}

# Function to load and filter phenotype data
load_and_filter_phenotype_data <- function(geno_numeric) {
  phenotype_data <- read.table("filtered_cal.g_pheno.txt", header = TRUE)
  accession_names <- rownames(geno_numeric)
  filtered_pheno_data <- phenotype_data[phenotype_data$IID %in% accession_names, ]
  Y <- filtered_pheno_data$Cal.g
  Y <- Y[match(accession_names, filtered_pheno_data$IID)]
  return(list(Y = Y, accession_names = accession_names))
}

# Function to load and filter kinship matrix
load_and_filter_kinship_matrix <- function(geno_numeric) {
  kinship_data <- read.table("kin_table_final.txt", skip = 3, header = FALSE)
  accessions_kinship <- kinship_data[, 1]
  kinship_matrix <- as.matrix(kinship_data[, -1])
  rownames(kinship_matrix) <- accessions_kinship
  colnames(kinship_matrix) <- accessions_kinship
  accession_names <- rownames(geno_numeric)
  filtered_kinship_matrix <- kinship_matrix[accession_names, accession_names]
  return(filtered_kinship_matrix)
}

# Function to process SNP pairs and create a triplet list
create_triplet_list <- function(geno_numeric) {
  library(future.apply)
  library(parallel)
  plan(multisession, workers = 31)  # Use all but one core

  num_snps <- ncol(geno_numeric)
  snp_names <- colnames(geno_numeric)
  accession_names <- rownames(geno_numeric)

  # Generate all SNP pairs (combinations)
  all_indices <- combn(num_snps, 2, simplify = FALSE)

  # Function to process SNP pairs
  process_snp_batch <- function(batch_indices) {
    X_triplet_batch <- vector("list", length(batch_indices))
    
    for (k in seq_along(batch_indices)) {
      indices <- batch_indices[[k]]
      i <- indices[1]
      j <- indices[2]
      
      snp1 <- geno_numeric[, i]
      snp2 <- geno_numeric[, j]
      interaction <- snp1 * snp2
      
      X_triplet <- cbind(snp1, snp2, interaction)
      rownames(X_triplet) <- accession_names
      
      X_triplet_batch[[k]] <- X_triplet
      names(X_triplet_batch)[k] <- paste(snp_names[i], snp_names[j], sep = "_interaction_")
    }
    
    return(X_triplet_batch)
  }

  # Parallel processing using future_lapply with multisession
  X_triplet_list_parallel <- future_lapply(all_indices, function(indices) {
    process_snp_batch(list(indices))
  })

  # Combine the results into a single list
  X_triplet_list <- unlist(X_triplet_list_parallel, recursive = FALSE)
  return(X_triplet_list)
}

gc()
