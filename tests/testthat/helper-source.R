# Source the pipeline helper functions so the tests can exercise them.
#
# testthat normally runs tests with the working directory set to this folder
# (tests/testthat), but we resolve the path defensively so the suite also works
# when invoked from the repository root.
.pipeline_candidates <- c(
  file.path("..", "..", "scripts", "pipeline"),
  file.path("scripts", "pipeline")
)
.pipeline_dir <- .pipeline_candidates[dir.exists(.pipeline_candidates)][1]
if (is.na(.pipeline_dir)) {
  stop("Could not locate scripts/pipeline relative to the test working directory")
}

source(file.path(.pipeline_dir, "load_n_proc.R"))
source(file.path(.pipeline_dir, "mm4lmm_fitting.R"))
source(file.path(.pipeline_dir, "extract_reml_info.R"))
