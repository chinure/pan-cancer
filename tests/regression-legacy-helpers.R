# Run from repository root: Rscript tests/regression-legacy-helpers.R
# Real helper expressions are evaluated with synthetic tables; no paper data.
expressions <- as.list(parse('pan_cancer.R'))
env <- new.env(parent = globalenv())
env$separate <- tidyr::separate
env$`%>%` <- dplyr::`%>%`
find_assignment <- function(name) {
  Filter(function(e) is.call(e) && identical(e[[1]], as.name('<-')) &&
           identical(e[[2]], as.name(name)), expressions)
}
eval(find_assignment('corda')[[1]], env)
x <- data.frame(id = 1:2, Sample = c('BRCA(N=2)', 'KIRC(N=2)'), gene = 1:2)
stopifnot(nrow(env$corda(x)) == 2L) # Empty exclusion set must not erase all rows.
x$Sample[2] <- 'SARC(N=2)'
stopifnot(identical(env$corda(x)$Sample, 'BRCA'))
# Exercise correlation-score header parsing with a real temporary workbook.
eval(find_assignment('xcR')[[1]], env)
env$score_columns <- c(4L, 8L)
env$pvalue_columns <- c(5L, 9L)
fixture <- as.data.frame(matrix('0', nrow = 2, ncol = 9))
colnames(fixture) <- c('Sample', 'unused1', 'unused2', 'NKT...4', 'p...5',
                      'unused3', 'unused4', 'CLP...8', 'p...9')
fixture$Sample <- c('units', 'BRCA(N=2)')
work <- tempfile('legacy-helper-'); dir.create(work)
openxlsx::write.xlsx(fixture, file.path(work, 'xCell.xlsx'))
old <- getwd(); setwd(work)
y <- env$xcR(1)
setwd(old); unlink(work, recursive = TRUE)
stopifnot(identical(names(y), c('Sample', 'NKT', 'CLP', 'Index')),
          identical(y$Index, c('R', 'pvalue')))
cat('PASS: correlation helper initialization, exclusion filtering, local xCell headers.\n')
