# Pairwise Epistatic Interactions and Their Functional Consequences in Sorghum

## Overview

This project explores the role of genetic interactions (epistasis) in shaping the genetic architecture of complex traits in Sorghum bicolor. Using single-nucleotide polymorphism (SNP) data and phenotypic information, we developed an R pipeline for epistasis analysis to detect significant SNP-SNP interactions.

## Features

- Data Preprocessing: Filtering SNPs based on minor allele frequency (MAF) and linkage disequilibrium (LD).

- Epistasis Detection: Using the MM4LMM R package to identify interaction effects.

- Statistical Model Fitting: Mixed models with kinship matrices to account for population structure.

- Enrichment Analysis: Identifying relationships between marginal and interaction effects.

- Pipeline Automation: Implemented using the targets package in R for reproducibility.


