# Run from repository root: Rscript tests/regression-limma-contrast.R [script]
# Exercise the actual differential-expression loop on an independent synthetic
# fixture with known Normal-minus-Tumor differences, without loading private XLSX.
library(limma)
script <- if (length(commandArgs(TRUE))) commandArgs(TRUE)[1] else 'pan_cancer.R'
expressions <- parse(script)
block <- Filter(function(expr) {
  is.call(expr) && identical(expr[[1]], as.name('for')) &&
    grepl('lmFit(res3', paste(deparse(expr), collapse = ' '), fixed = TRUE)
}, as.list(expressions))
stopifnot(length(block) == 1L)
genes <- c('FDX1', 'LIAS', 'LIPT1', 'DLD', 'DLAT', 'PDHA1', 'PDHB', 'SLC31A1')
fixture <- data.frame(SampleName = paste0('sample', 1:8), Sample = 'fixture',
                      Group = rep(c('Normal', 'Tumor'), each = 4))
noise <- c(-0.15, -0.05, 0.05, 0.15)
truth <- setNames(c(2, -1, 3, 0.5, 1.5, -2, 4, -0.5), genes)
for (j in seq_along(genes)) {
  fixture[[genes[j]]] <- c(5 + j + noise, 5 + j - truth[[genes[j]]] + noise)
}
second <- fixture
second$Sample <- 'second'
second$SampleName <- paste0('second', seq_len(nrow(second)))
for (gene in genes) second[second$Group == 'Tumor', gene] <-
  second[second$Group == 'Tumor', gene] + 0.25
fixture <- rbind(fixture, second)
env <- new.env(parent = globalenv())
env$filter <- dplyr::filter
env$res <- fixture
env$sam <- c('fixture', 'second')
env$expression_genes <- genes
env$logFC <- data.frame(row.names = genes)
env$avgexp <- data.frame(row.names = genes)
env$diff_exp <- data.frame()
eval(block[[1]], env)
stopifnot(nrow(env$diff_exp) == 16L,
          all(abs(env$diff_exp$logFC - (truth[env$diff_exp$Gene] -
            ifelse(env$diff_exp$Sample == 'second', 0.25, 0))) < 1e-8),
          all(abs(env$logFC[genes, 'fixture'] - truth) < 1e-8),
          all(abs(env$logFC[genes, 'second'] - (truth - 0.25)) < 1e-8))
cat('PASS: eight known positive/negative contrasts recovered and aligned by gene.\n')
