# Pairwise Epistatic Interactions and Their Functional Consequences in Sorghum

## Overview

This project explores the role of genetic interactions (epistasis) in shaping the genetic architecture of complex traits in Sorghum bicolor. Using single-nucleotide polymorphism (SNP) data and phenotypic information, we developed an R pipeline for epistasis analysis to detect significant SNP-SNP interactions.

## Features

- Data Preprocessing: Filtering SNPs based on minor allele frequency (MAF) and linkage disequilibrium (LD).

- Epistasis Detection: Using the MM4LMM R package to identify interaction effects.

- Statistical Model Fitting: Mixed models with kinship matrices to account for population structure.

- Enrichment Analysis: Identifying relationships between marginal and interaction effects.

- Pipeline Automation: Implemented using the targets package in R for reproducibility.

##Explanation of Scripts

- _targets.R: Main targets pipeline script, integrating all steps for data processing and model fitting.

- _targets_phase1.R: Handles the first phase of the pipeline, including data loading, conversion, and model fitting.

- _targets_phase2.R: Extracts REML model results and computes enrichment analysis statistics.

- load_n_proc.R: Loads and processes genotype and phenotype data.

- mm4lmm_fitting.R: Fits REML models and manages variance structures.

- extract_reml_info.R: Extracts SNP interaction results from REML models.

- extract_and_plot.R: Computes and visualizes p-value distributions.
