##' A wrapper for a MultiGSEAResult that makes explicity some shiny bits
##'
##' @export
##' @param x A \code{\link[multiGSEA]{MultiGSEAResult}} object, or a path to
##'   an rds-serliazed one
##' @return a \code{MultiGSEAResultContainer} object
MultiGSEAResultContainer <- function(x) {
  ## TODO: S4ize MultiGSEAResultContainer
  if (is.character(x)) {
    ## Assume this is a file
    if (!file.exists(x)) {
      stop("file does not exist: ", x)
    }
    mg <- readRDS(x)
  } else if (is(x, 'GeneSetDb')) {
    ## Hack to init some shinybits that are useful to have ontop of a GeneSetDb
    ## (I feel horrible for having this)
    fids <- featureIds(x)
    fids <- setNames(rnorm(length(fids)), fids)
    mg <- multiGSEA(x, fids, methods=NULL)
  } else if (is(x, 'MultiGSEAResult')) {
    mg <- x
  } else {
    mg <- NULL
  }

  if (!is(mg, 'MultiGSEAResult')) {
    stop("Don't know how to create container from: ", class(mg)[1L])
  }

  methods <- local({
    tmp <- resultNames(mg)
    if (length(tmp) == 0L) {
      warning("No GSEA methods found in MultiGSEAResult, ",
              "you can only make a geneSetSelectUI")
      out <- character()
    } else {
      ## I am biased and prefer to show these methods first, if available
      pref <- c('camera', 'goseq', 'goseq.up', 'goseq.down')
      pref <- pref[pref %in% tmp]
      out <- c(pref, setdiff(tmp, pref))
    }
    out
  })

  gs.choices <- gs.select.choices(mg)

  out <- list(mg=mg, methods=methods, choices=gs.choices)
  class(out) <- c('MultiGSEAResultContainer', class(out))
  out
}
