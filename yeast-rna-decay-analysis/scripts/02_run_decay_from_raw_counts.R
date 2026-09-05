#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(readxl)
  library(stringr)
  library(purrr)
})

source("R/io.R")
source("R/decay_analysis.R")

input_dir <- "data/raw"
output_path <- "results/tables/Decay_Half_Lives_from_raw.csv"
pattern <- "exp(20|22|23)_t(0|2\\.5|5|10|20|40)_(0|2)\\.xlsx$"

counts <- read_count_directory(input_dir, pattern)
decay_results <- fit_decay_models(counts)
readr::write_csv(decay_results, output_path)
