# DESeq2 differential expression analysis --------------------------------------

build_count_matrix <- function(sample_tables, count_column = "ReadCount") {
  count_matrix <- do.call(cbind, lapply(sample_tables, function(df) df[[count_column]]))
  rownames(count_matrix) <- sample_tables[[1]]$Name
  count_matrix
}

run_deseq2_comparison <- function(count_matrix, sample_metadata, design_formula, contrast) {
  dds <- DESeq2::DESeqDataSetFromMatrix(
    countData = round(count_matrix),
    colData = sample_metadata,
    design = design_formula
  )

  dds <- dds[rowSums(DESeq2::counts(dds)) > 1, ]
  dds <- DESeq2::DESeq(dds)

  DESeq2::results(dds, contrast = contrast) |>
    as.data.frame() |>
    tibble::rownames_to_column("gene") |>
    dplyr::arrange(padj)
}

filter_significant_genes <- function(results, padj_cutoff = 0.05, log2fc_cutoff = 1) {
  results |>
    dplyr::filter(
      !is.na(padj),
      padj < padj_cutoff,
      abs(log2FoldChange) >= log2fc_cutoff
    )
}

plot_volcano <- function(results, padj_cutoff = 0.05, log2fc_cutoff = 1) {
  results |>
    dplyr::mutate(
      neg_log10_padj = -log10(padj),
      significant = !is.na(padj) & padj < padj_cutoff & abs(log2FoldChange) >= log2fc_cutoff,
      label = dplyr::if_else(significant, gene, "")
    ) |>
    dplyr::filter(is.finite(log2FoldChange), is.finite(neg_log10_padj)) |>
    ggplot2::ggplot(ggplot2::aes(x = log2FoldChange, y = neg_log10_padj)) +
    ggplot2::geom_point(ggplot2::aes(shape = significant), alpha = 0.7) +
    ggrepel::geom_text_repel(ggplot2::aes(label = label), max.overlaps = 20) +
    ggplot2::theme_minimal() +
    ggplot2::labs(
      title = "Differential expression volcano plot",
      x = "log2 fold change",
      y = "-log10 adjusted p-value"
    )
}
