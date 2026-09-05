# RNA decay half-life analysis --------------------------------------------------

fit_decay_models <- function(count_data) {
  count_data |>
    dplyr::group_by(Name, experiment, glucose) |>
    dplyr::filter(dplyr::n_distinct(time) >= 3) |>
    dplyr::group_modify(~ {
      model <- stats::lm(log(Adjusted_NonTcReadCount) ~ time, data = .x)
      decay_constant <- stats::coef(model)[["time"]]
      half_life <- ifelse(
        is.finite(decay_constant) && decay_constant != 0,
        log(2) / abs(decay_constant),
        NA_real_
      )

      tibble::tibble(
        decay_constant = decay_constant,
        half_life = half_life,
        adj_r_squared = summary(model)$adj.r.squared
      )
    }) |>
    dplyr::ungroup()
}

compare_half_lives <- function(decay_results) {
  cleaned <- decay_results |>
    dplyr::filter(is.finite(half_life), half_life > 0)

  glu_plus <- cleaned |>
    dplyr::filter(glucose == 2 | glucose == 200) |>
    dplyr::rename(half_life_glucose = half_life)

  glu_minus <- cleaned |>
    dplyr::filter(glucose == 0) |>
    dplyr::rename(half_life_no_glucose = half_life)

  dplyr::left_join(
    glu_plus,
    glu_minus,
    by = c("Name", "experiment"),
    suffix = c("_plus", "_minus")
  ) |>
    dplyr::mutate(delta_half_life = half_life_glucose - half_life_no_glucose)
}

classify_decay_changes <- function(decay_comparison, sd_cutoff = 1.5) {
  mean_delta <- mean(decay_comparison$delta_half_life, na.rm = TRUE)
  sd_delta <- stats::sd(decay_comparison$delta_half_life, na.rm = TRUE)

  decay_comparison |>
    dplyr::mutate(
      decay_change = dplyr::case_when(
        delta_half_life > mean_delta + sd_cutoff * sd_delta ~ "longer_half_life_in_glucose",
        delta_half_life < mean_delta - sd_cutoff * sd_delta ~ "shorter_half_life_in_glucose",
        TRUE ~ "no_large_change"
      )
    )
}

plot_half_life_distribution <- function(decay_results) {
  decay_results |>
    dplyr::filter(is.finite(half_life), half_life > 0) |>
    ggplot2::ggplot(ggplot2::aes(x = half_life)) +
    ggplot2::geom_histogram(bins = 50) +
    ggplot2::facet_wrap(~ glucose, scales = "free_y") +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "RNA half-life distribution by glucose condition",
      x = "Estimated half-life",
      y = "Gene count"
    )
}

plot_delta_half_life <- function(decay_comparison) {
  decay_comparison |>
    dplyr::filter(is.finite(delta_half_life)) |>
    ggplot2::ggplot(ggplot2::aes(x = delta_half_life)) +
    ggplot2::geom_histogram(bins = 50) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Change in RNA half-life with glucose",
      x = "Half-life in glucose - half-life without glucose",
      y = "Gene count"
    )
}
