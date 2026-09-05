#!/usr/bin/env Rscript

# Template script for DESeq2 analysis.
# Requires raw Excel count files in data/raw. These files are not included in the public repo.

suppressPackageStartupMessages({
  library(DESeq2)
  library(dplyr)
  library(ggplot2)
  library(ggrepel)
  library(readxl)
  library(readr)
})

source("R/deseq2_analysis.R")

message("Place raw count Excel files in data/raw before running this script.")
message("Expected filename example: exp20_s7_tc1.xlsx")
