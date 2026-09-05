# Input/output helper functions -------------------------------------------------

parse_sample_metadata <- function(filename) {
  base <- basename(filename)

  sample <- stringr::str_match(
    base,
    "exp(\\d+)_s(\\d+)_(tc\\d+)\\.xlsx$"
  )

  if (!all(is.na(sample))) {
    return(tibble::tibble(
      file = filename,
      experiment = paste0("exp", sample[, 2]),
      sample = paste0("s", sample[, 3]),
      tc_condition = sample[, 4],
      time = NA_real_,
      glucose = NA_real_
    ))
  }

  time_course <- stringr::str_match(
    base,
    "exp(\\d+)_t(\\d+\\.?\\d*)_(\\d+)\\.xlsx$"
  )

  if (!all(is.na(time_course))) {
    return(tibble::tibble(
      file = filename,
      experiment = paste0("exp", time_course[, 2]),
      sample = NA_character_,
      tc_condition = NA_character_,
      time = as.numeric(time_course[, 3]),
      glucose = as.numeric(time_course[, 4])
    ))
  }

  stop("Could not parse metadata from filename: ", filename)
}

read_count_file <- function(filename) {
  required <- c("Name", "ReadCount", "TcReadCount")
  data <- readxl::read_excel(filename)
  missing <- setdiff(required, colnames(data))

  if (length(missing) > 0) {
    stop("Missing required columns in ", filename, ": ", paste(missing, collapse = ", "))
  }

  data |>
    dplyr::select(Name, ReadCount, TcReadCount) |>
    dplyr::mutate(
      NonTcReadCount = ReadCount - TcReadCount,
      Adjusted_NonTcReadCount = NonTcReadCount + 1
    )
}

read_count_directory <- function(path, pattern) {
  files <- list.files(path, pattern = pattern, full.names = TRUE)

  if (length(files) == 0) {
    stop("No files found in ", path, " matching pattern: ", pattern)
  }

  purrr::map_dfr(files, function(file) {
    metadata <- parse_sample_metadata(file)
    read_count_file(file) |>
      dplyr::bind_cols(metadata[rep(1, nrow(read_count_file(file))), ])
  })
}
