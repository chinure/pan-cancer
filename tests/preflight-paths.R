# Run from repository root: Rscript tests/preflight-paths.R
# Checks file discovery only; placeholder files are not biological input data.
script <- normalizePath('pan_cancer.R')
root <- tempfile('pan-paths-'); dir.create(root)
work <- file.path(root, 'working-copy'); dir.create(work)
hpa <- file.path(root, 'hpa'); dir.create(hpa)
out <- file.path(root, 'figures')
workbooks <- c('diff.xlsx', 'diff_T_N.xlsx', 'exp.xlsx', 'TMB.xlsx', 'MSI.xlsx',
              'NEO.xlsx', 'prog.xlsx', 'Stage.xlsx', 'Estimate.xlsx', 'xCell.xlsx',
              'GDC-PANCAN.mutect2_snv.tsv', 'DTP_NCI60_ZSCORE.xlsx',
              'RNA__RNA_seq_composite_expression.xls')
invisible(file.create(file.path(work, workbooks)))
invisible(file.create(file.path(hpa, c('rna_tissue_fantom.tsv',
  'rna_tissue_hpa.tsv', 'rna_tissue_gtex.tsv'))))
status <- system2(file.path(R.home('bin'), 'Rscript'),
                  c(shQuote(script), shQuote(work), shQuote(out), shQuote(hpa),
                    '--check-inputs'), stdout = TRUE, stderr = TRUE)
stopifnot(is.null(attr(status, 'status')), any(grepl('schemas.*not validated', status)),
          !dir.exists(out))
Sys.setenv(PANCANCER_WORK_DIR = work, PANCANCER_OUTPUT_DIR = out, PANCANCER_HPA_DIR = hpa)
status <- system2(file.path(R.home('bin'), 'Rscript'),
                  c(shQuote(script), '--check-inputs'), stdout = TRUE, stderr = TRUE)
stopifnot(is.null(attr(status, 'status')))
unlink(file.path(work, 'TMB.xlsx'))
status <- suppressWarnings(system2(file.path(R.home('bin'), 'Rscript'),
                  c(shQuote(script), '--check-inputs'), stdout = TRUE, stderr = TRUE))
stopifnot(attr(status, 'status') != 0L, any(grepl('TMB.xlsx', status, fixed = TRUE)))
unlink(root, recursive = TRUE)
cat('PASS: CLI/env path selection and explicit missing-input failure before analysis.\n')
