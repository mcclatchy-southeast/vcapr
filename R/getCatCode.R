#' Get AOC category
#'
#' Simple utility function to convert a plain language table category code to
#' the corresponding file name per AOC naming convention.
#'
#' @param record_category plain language record category in short or long form
#'
#' @return string with corresponding category code
#' @export
#'
#' @examples
#' getCatCode('c')
getCatCode <- function(record_category){
  #translate the record category to the file name code
  cat_code <- switch(record_category,
                     'case' = 'NOBC', 'c' = 'NOBC',
                     'abstract' = 'NOBA', 'a' = 'NOBA',
                     'support' = 'NOBS', 's' = 'NOBS',
                     'INVALID')

  return(cat_code)
}
