# Motif and gene-list helper functions -----------------------------------------

intersect_gene_lists <- function(path_a, path_b) {
  genes_a <- readr::read_lines(path_a)
  genes_b <- readr::read_lines(path_b)
  intersect(genes_a, genes_b)
}

filter_bed_by_genes <- function(bed_path, gene_list_path, output_path) {
  bed <- readr::read_tsv(bed_path, col_names = FALSE, show_col_types = FALSE)
  genes <- readr::read_lines(gene_list_path)

  filtered <- bed |>
    dplyr::filter(X4 %in% genes)

  readr::write_tsv(filtered, output_path, col_names = FALSE)

  list(
    matched_genes = unique(filtered$X4),
    unmatched_genes = setdiff(genes, unique(filtered$X4)),
    output_path = output_path
  )
}
