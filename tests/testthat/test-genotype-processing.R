test_that("convert_genotype_values encodes phased genotypes as allele dosages", {
  # Markers in rows, accessions in columns (as returned by vcfR::extract.gt).
  geno <- matrix("", nrow = 2, ncol = 2,
                 dimnames = list(c("snp1", "snp2"), c("s1", "s2")))
  geno["snp1", "s1"] <- "0|0"  # -> 0
  geno["snp1", "s2"] <- "0|1"  # -> 1
  geno["snp2", "s1"] <- "1|1"  # -> 2
  geno["snp2", "s2"] <- "2|2"  # invalid -> NA

  out <- convert_genotype_values(geno)

  # Result is transposed: accessions in rows, markers in columns.
  expect_equal(dim(out), c(2, 2))
  expect_equal(rownames(out), c("s1", "s2"))
  expect_equal(colnames(out), c("snp1", "snp2"))

  expect_equal(out["s1", "snp1"], 0)
  expect_equal(out["s2", "snp1"], 1)
  expect_equal(out["s1", "snp2"], 2)
  expect_true(is.na(out["s2", "snp2"]))
})

test_that("convert_genotype_values treats heterozygous orderings identically", {
  geno <- matrix("", nrow = 2, ncol = 2,
                 dimnames = list(c("snp1", "snp2"), c("s1", "s2")))
  geno["snp1", "s1"] <- "0|1"
  geno["snp1", "s2"] <- "1|0"
  geno["snp2", "s1"] <- "1|0"
  geno["snp2", "s2"] <- "0|1"

  out <- convert_genotype_values(geno)
  # Both phasings of the heterozygote encode to dosage 1.
  expect_true(all(out == 1))
})

test_that("create_triplet_list builds one SNP1/SNP2/interaction matrix per pair", {
  geno_numeric <- matrix(
    c(0, 1, 2,
      1, 1, 0,
      2, 0, 1),
    nrow = 3, byrow = FALSE,
    dimnames = list(c("a1", "a2", "a3"), c("S1", "S2", "S3"))
  )

  triplets <- create_triplet_list(geno_numeric)

  # choose(3, 2) == 3 unordered SNP pairs.
  expect_length(triplets, 3)
  expect_setequal(
    names(triplets),
    c("S1_interaction_S2", "S1_interaction_S3", "S2_interaction_S3")
  )

  pair <- triplets[["S1_interaction_S2"]]
  expect_equal(colnames(pair), c("snp1", "snp2", "interaction"))
  expect_equal(rownames(pair), c("a1", "a2", "a3"))
  expect_equal(unname(pair[, "snp1"]), c(0, 1, 2))
  expect_equal(unname(pair[, "snp2"]), c(1, 1, 0))
  # Interaction column is the element-wise product of the two SNP columns.
  expect_equal(unname(pair[, "interaction"]), c(0, 1, 0))
})
