# Yeast RNA Decay Analysis During Glucose Adaptation

A reproducible R-based bioinformatics workflow for analysing yeast RNA decay and transcriptomic responses during glucose adaptation.

This project is adapted from my MSc Bioinformatics and Systems Biology dissertation work. The original project investigated RNA decay dynamics using sequencing/count-based analysis in yeast, with downstream analyses including differential expression, RNA half-life estimation, motif investigation, codon usage, and poly(A) tail comparison.

## Project focus

The workflow explores how transcript stability changes under different glucose conditions. It includes analysis steps for:

- estimating RNA decay constants and transcript half-lives from time-course count data
- comparing half-life changes between glucose conditions
- identifying differentially expressed transcripts using DESeq2
- preparing gene sets/3' UTR regions for motif analysis with MEME
- checking codon usage patterns in genes of interest
- comparing poly(A) tail lengths between genes of interest and the wider gene set

## Why this project matters

RNA stability is an important layer of gene-expression regulation. By combining decay modelling, differential expression, and sequence/motif-level analyses, this project demonstrates how computational workflows can be used to investigate transcriptome regulation in response to environmental change.

## Repository structure

```text
yeast_rna_decay_bioinformatics/
├── R/
│   ├── io.R
│   ├── decay_analysis.R
│   ├── deseq2_analysis.R
│   ├── codon_usage.R
│   ├── motif_analysis.R
│   └── polyA_analysis.R
├── scripts/
│   ├── 01_summarise_processed_decay.R
│   ├── 02_run_decay_from_raw_counts.R
│   └── 03_run_deseq2.R
├── data/
│   ├── raw/
│   ├── processed/
│   └── external/
├── results/
│   ├── figures/
│   └── tables/
├── docs/
├── DESCRIPTION
├── LICENSE
└── README.md
```

## Data availability

Raw experimental count files and lab-generated sequence files are not included in this public repository because they were produced as part of academic research and may not be publicly shareable.

The repository includes a processed half-life results table, `data/processed/Decay_Half_Lives.csv`, to demonstrate downstream analysis and visualisation. The scripts are designed so that users with appropriate access to the raw files can reproduce the full workflow locally.

## Main analyses

### 1. RNA decay and half-life estimation

Time-course count data are used to estimate transcript decay constants by fitting linear models to log-transformed adjusted read counts over time. Half-life is then calculated from the decay constant.

Main functions:

- `fit_decay_models()`
- `compare_half_lives()`
- `classify_decay_changes()`
- `plot_half_life_distribution()`

### 2. Differential expression with DESeq2

The DESeq2 workflow compares transcript counts between experimental conditions, applies multiple-testing correction, filters significant genes, and produces volcano plots.

Main functions:

- `build_count_matrix()`
- `run_deseq2_comparison()`
- `filter_significant_genes()`
- `plot_volcano()`

### 3. Motif analysis preparation

Gene lists can be intersected and 3' UTR BED files can be filtered to prepare input for MEME motif discovery.

Main functions:

- `intersect_gene_lists()`
- `filter_bed_by_genes()`

### 4. Codon usage

FASTA sequences can be analysed to calculate relative codon frequencies for genes of interest.

Main functions:

- `calculate_codon_usage()`
- `calculate_fasta_codon_usage()`
- `plot_codon_usage()`

### 5. Poly(A) tail comparison

Genes of interest can be compared against a background gene set to investigate whether they differ in poly(A) tail length distribution.

Main functions:

- `compare_polyA_tail_lengths()`
- `plot_polyA_comparison()`

## How to run the processed-data example

From the repository root:

```bash
Rscript scripts/01_summarise_processed_decay.R
```

This generates:

```text
results/tables/half_life_summary.csv
results/tables/half_life_glucose_comparison.csv
results/figures/half_life_distribution.png
results/figures/delta_half_life_distribution.png
```

## Requirements

Core R packages:

```r
install.packages(c(
  "dplyr", "ggplot2", "ggrepel", "readxl", "readr", "tidyr",
  "tibble", "stringr", "purrr", "seqinr", "moments", "XML"
))
```

Bioconductor packages:

```r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}

BiocManager::install(c("DESeq2", "Biostrings", "rtracklayer"))
```

## Project status

This is a cleaned portfolio version of my MSc dissertation analysis code. The original scripts were exploratory research scripts; this version reorganises the analysis into clearer, reusable R modules and command-line scripts.

## Future development and collaboration

I am still very interested in this project and in transcriptomics, RNA stability, and reproducible bioinformatics workflows more broadly. Suggestions, discussions, and feedback are welcome, especially around improving the modelling approach, extending the workflow to more datasets, adding better visualisations, or integrating the analysis into a Snakemake/Nextflow pipeline.
