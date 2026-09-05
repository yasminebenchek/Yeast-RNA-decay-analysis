#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
})

source("R/decay_analysis.R")

dir.create("results/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("results/tables", recursive = TRUE, showWarnings = FALSE)

decay_results <- readr::read_csv("data/processed/Decay_Half_Lives.csv", show_col_types = FALSE) |>
  dplyr::rename(experiment = Exp, glucose = Glucose)

summary_table <- decay_results |>
  dplyr::filter(is.finite(half_life), half_life > 0) |>
  dplyr::group_by(glucose) |>
  dplyr::summarise(
    n_genes = dplyr::n(),
    mean_half_life = mean(half_life, na.rm = TRUE),
    median_half_life = median(half_life, na.rm = TRUE),
    .groups = "drop"
  )

readr::write_csv(summary_table, "results/tables/half_life_summary.csv")

distribution_plot <- plot_half_life_distribution(decay_results)
ggplot2::ggsave("results/figures/half_life_distribution.png", distribution_plot, width = 9, height = 6)

comparison <- compare_half_lives(decay_results) |>
  classify_decay_changes()
readr::write_csv(comparison, "results/tables/half_life_glucose_comparison.csv")

delta_plot <- plot_delta_half_life(comparison)
ggplot2::ggsave("results/figures/delta_half_life_distribution.png", delta_plot, width = 9, height = 6)
