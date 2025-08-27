# Pairwise Epistatic Interactions and Their Functional Consequences in Sorghum

## Overview

This project was completed as a semester-long Project in Bioinformatics (5 ECTS) during my Master's degree at Aarhus Univeristy. This project explores the role of genetic interactions (epistasis) in shaping the genetic architecture of complex traits in Sorghum bicolor. Using single-nucleotide polymorphism (SNP) data and phenotypic information, we developed a modular and reproducible R pipeline for epistasis analysis to detect significant SNP-SNP interactions. The pipeline automates the entire process from VCF processing to statistical model fitting. The project was done in collaboration with Savvas Chatzivasieliou under the supervision of Thomas Bataillon and Guillaume Ramstein.

🚧 *This repository is a work in progress.* 🚧  


## Features

- Data Preprocessing: Filtering SNPs based on minor allele frequency (MAF) and linkage disequilibrium (LD) thresholds.

- Epistasis Detection: Using the MM4LMM R package to fit mixed models.

- Covariate Control: Includes kinship matrix and PCs to account for structure.

- Model Comparison: Supports both REML and ML-based inference.

- P-Value Analysis: Computes z-score and LRT-based significance tests.

- Pipeline Automation: Structured with {targets} for modularity, reproducibility, and efficient reruns

## Repository Structure

```text
├── docs/                # Project report
├── scripts/             # R scripts 
│   ├── _targets.R
│   ├── mm4lmm_fitting.R
│   ├── plot_qval_distribution.R
│   └── ...
└── README.md            # You are here
```

## How to Run 

Each script auto-installs missing packages on first run.

```r
targets::tar_make
```

## Scripts Overview

- _targets.R: Main targets pipeline script, integrating all steps for data processing and model fitting.

- load_n_proc.R: Loads and processes genotype and phenotype data.

- mm4lmm_fitting.R: Fits REML models and manages variance structures.

- extract_reml_info.R: Extracts SNP interaction results from REML models.

- extract_and_plot.R: Computes and visualizes p-value distributions.

- add_interaction_pvalues.R: Calculates z-scores and p-values for SNP–SNP interaction terms and updates .qs result files.

- adjust_fdr_bh.R: Applies Benjamini–Hochberg FDR correction to interaction p-values and updates result files.

- classify_and_plot_significant_interactions.R: Merges marginal and interaction results, filters significant SNP–SNP effects, classifies significance patterns, and generates comparative plots.
