# Entry point for running the test suite locally:
#   Rscript tests/testthat.R
library(testthat)
testthat::test_dir("tests/testthat", stop_on_failure = TRUE)
