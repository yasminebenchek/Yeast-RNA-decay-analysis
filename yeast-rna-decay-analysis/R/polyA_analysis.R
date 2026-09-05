# Poly(A) tail comparison -------------------------------------------------------

compare_polyA_tail_lengths <- function(polyA_data, genes_of_interest) {
  degraded_genes <- polyA_data |>
    dplyr::filter(Systematic.Name %in% genes_of_interest)

  tibble::tibble(
    group = c("full_gene_set", "genes_of_interest"),
    mean_tail_length = c(
      mean(polyA_data$WT.W303.30C.mean, na.rm = TRUE),
      mean(degraded_genes$WT.W303.30C.mean, na.rm = TRUE)
    ),
    median_tail_length = c(
      stats::median(polyA_data$WT.W303.30C.mean, na.rm = TRUE),
      stats::median(degraded_genes$WT.W303.30C.mean, na.rm = TRUE)
    )
  )
}

plot_polyA_comparison <- function(polyA_data, genes_of_interest) {
  degraded_genes <- polyA_data |>
    dplyr::filter(Systematic.Name %in% genes_of_interest) |>
    dplyr::mutate(group = "Genes of interest")

  full_data <- polyA_data |>
    dplyr::mutate(group = "Full gene set")

  dplyr::bind_rows(full_data, degraded_genes) |>
    ggplot2::ggplot(ggplot2::aes(x = group, y = WT.W303.30C.mean)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Poly(A) tail length comparison",
      x = "Gene group",
      y = "Poly(A) tail length"
    )
}
