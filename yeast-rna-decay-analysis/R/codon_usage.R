# Codon usage analysis ----------------------------------------------------------

calculate_codon_usage <- function(sequence) {
  sequence <- toupper(sequence)
  usable_length <- nchar(sequence) - (nchar(sequence) %% 3)
  sequence <- substr(sequence, 1, usable_length)
  codons <- substring(sequence, seq(1, usable_length, by = 3), seq(3, usable_length, by = 3))
  as.data.frame(prop.table(table(codons))) |>
    dplyr::rename(codon = codons, frequency = Freq)
}

calculate_fasta_codon_usage <- function(fasta_path) {
  fasta <- seqinr::read.fasta(file = fasta_path, as.string = TRUE, seqonly = FALSE)

  purrr::imap_dfr(fasta, function(sequence, header) {
    calculate_codon_usage(as.character(sequence)) |>
      dplyr::mutate(sequence_id = header, .before = 1)
  })
}

plot_codon_usage <- function(codon_usage_df) {
  codon_usage_df |>
    ggplot2::ggplot(ggplot2::aes(x = codon, y = frequency)) +
    ggplot2::geom_col() +
    ggplot2::facet_wrap(~ sequence_id, scales = "free_y") +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 90, vjust = 0.5)) +
    ggplot2::labs(
      title = "Codon usage frequency",
      x = "Codon",
      y = "Relative frequency"
    )
}
