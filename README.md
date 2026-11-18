# Exploratory pan-cancer analysis of cuproptosis-related genes

R scripts maintained by **Yao Zhi** (zhiyao@jlu.edu.cn) for exploratory expression,
clinical-association, immune-score and drug-response analyses of FDX1, LIAS,
LIPT1, DLD, DLAT, PDHA1, PDHB and SLC31A1. The original script was uploaded in
2022. It is a historical analysis workspace, not a validated reproduction of a
published article or a complete data-download pipeline.

## What is present

`pan_cancer.R` contains plotting and analysis sections for HPA/FANTOM/GTEx tissue
expression; tumor/normal comparisons with limma; TMB/MSI/neoantigen correlations;
precomputed survival estimates; stage, ESTIMATE and xCell scores; mutation
waterfalls; and NCI-60 drug-response correlations. Several sections consume
precomputed spreadsheets rather than generating their underlying results. The
empty legacy `cuproptosis` placeholder contains no analysis data.

The code by itself does not establish responsibility for every method in an
associated paper. A publication DOI, data accessions, final figure mapping and
versioned analysis inputs have not been recorded in this repository.

## Paths and input discovery

Use a **working copy** of the input files. The legacy script writes intermediate
Excel tables into WORK_DIR; figures and HPA summary tables go to OUTPUT_DIR.
Do not select your only copy of manually prepared workbooks as WORK_DIR.

```bash
Rscript pan_cancer.R --help
Rscript pan_cancer.R /path/to/working-copy /path/to/results /path/to/HPA --check-inputs
# Run only after reviewing schemas, dependencies and the limits below:
Rscript pan_cancer.R /path/to/working-copy /path/to/results /path/to/HPA
```

Alternatively, set `PANCANCER_WORK_DIR`, `PANCANCER_OUTPUT_DIR` and
`PANCANCER_HPA_DIR`, then run `Rscript pan_cancer.R --check-inputs`. Positional
arguments override environment values. Defaults are `./data`, `./results`, and
`HPA` inside WORK_DIR. OUTPUT_DIR/Graph is created when analysis begins.

The preflight command checks existence only and exits before loading analysis
packages or writing outputs. It does **not** verify worksheet layouts, numeric
units, sample matching, valid Excel contents or scientific suitability.

| Location | Required files | Legacy expectations |
|---|---|---|
| HPA_DIR | `rna_tissue_fantom.tsv`, `rna_tissue_hpa.tsv`, `rna_tissue_gtex.tsv` | HPA-style `Gene.name`, `Tissue`, and the respective expression columns |
| WORK_DIR | `diff.xlsx`, `exp.xlsx` | Eight gene worksheets. Four-column sheets are reordered to sample ID, cohort, group and gene value; merged tables need `SampleName`, `Sample`, `Group` and gene columns |
| WORK_DIR | `diff_T_N.xlsx` | Pre-existing workbook; the legacy heatmap section reads **sheet 4**, which is not generated from raw data by this repository |
| WORK_DIR | `TMB.xlsx`, `MSI.xlsx`, `NEO.xlsx` | Precomputed per-gene workbooks, eight sheets each, matched to sample/cohort labels |
| WORK_DIR | `prog.xlsx`, `Stage.xlsx` | Precomputed survival HR/CI tables and stage expression data; Stage uses sheet 6 |
| WORK_DIR | `Estimate.xlsx`, `xCell.xlsx` | Precomputed correlation/p-value layouts; positional column/sheet indices are retained |
| WORK_DIR | `GDC-PANCAN.mutect2_snv.tsv` | Mutation table with the fields selected by the script |
| WORK_DIR | `DTP_NCI60_ZSCORE.xlsx`, `RNA__RNA_seq_composite_expression.xls` | Manually formatted drug-response and expression workbooks with matching cell-line columns |

No patient records, source workbooks or access credentials are included.
Obtaining a similarly named public dataset is insufficient without reconstructing
these layouts and documenting source/version/transformations.

## Dependencies

There is no package lockfile. The historical script loads R packages from both
CRAN and Bioconductor, including GenVisR, limma, ggplot2, ggpubr, openxlsx, xlsx,
rJava, ggsignif, dplyr, plyr, reshape2, tidyverse, pheatmap, ComplexHeatmap, scales,
corrplot, ggcorrplot, Hmisc, ggradar, ggrepel, ggsci, forestploter and
RColorBrewer, and uses readxl, writexl, impute and viridis-related functions.
`xlsx` requires a working Java/rJava installation. Installing these packages alone
will not supply the missing inputs or fix all data-layout assumptions. Package
names/versions must be recorded when a real-data rerun is established.

The focused regression checks below need only the packages they use: limma,
dplyr, tidyr, readxl and openxlsx. They passed with R 4.3.3 in the review
environment; this is not a promise of compatibility for every historical plot.

## Targeted checks and repairs

```bash
Rscript tests/regression-limma-contrast.R
Rscript tests/regression-legacy-helpers.R
Rscript tests/preflight-paths.R
```

These use synthetic fixtures and exercise actual code sections. They check
positive/negative Normal-minus-Tumor contrasts and gene alignment, helper
initialization, no-exclusion filtering, xCell header parsing, configurable paths,
and missing-input failure. They do not reproduce biological findings.

The repairs preserve the contrasted limma fit during empirical-Bayes moderation;
remove several dependencies on undefined interactive-session objects; align
per-cancer model results by gene name; and replace machine-specific paths.
Original uploaded code failed the focused expression/contrast checks; fixes do not
establish validity of previously exported results.

## Remaining limits before a complete rerun

- Missing source files, acquisition commands, checksums, input schemas and final
  figure mapping prevent an end-to-end reproduction.
- Manual worksheet preparation and hardcoded cohort/cell/gene dimensions remain
  in historical plotting sections. Some sections cannot follow directly from
  prior outputs without the prepared workbooks.
- Point sizes named `p.adj` in old plotting blocks are heuristic transformations
  of raw p-values, **not** multiplicity-adjusted p-values. Correlation screens
  require a documented testing family and correction strategy before inference.
- Drug and expression columns require explicit cell-line matching and missingness
  review; positional alignment alone is insufficient.
- Survival forest plots consume precomputed HR/CI estimates; commented Cox code
  is not a trained and independently validated survival model.
- The script has not been run end to end against real inputs in this repair.
  Full numerical/figure validation and any relationship to a particular paper
  remain to be established.
