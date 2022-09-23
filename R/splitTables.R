#' Split civil data tables
#'
#' Function that accepts a dataframe of combined tables from the AOC civil extract
#' and splits them into component parts based on the record type. Output is a large
#' list that we can later use to write indidividual separated files.
#' \cr\cr Run time: ~ 8 minutes/MTD
#'
#' @param combined_tables a dataframe containing the combined tables from AOC
#'
#' @return large list
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' all_tables <- data.frame(
#'  cntyno = c('000','000','000','000','000','000','000','000','000','000'),
#'  v2 = c(1:10),
#'  rectype = c(28, 59, 59,48, 37, 47, 65, 48, 48, 60),
#'  caseno = c('17CR 000002', '17CR 000002', '17CR 000002', '17CR 000002', '17CR 000002',
#'  '17CR 000002', '17CR 000002', '17CR 000002', '17CR 000002', '17CR 000002'),
#'  f1 = c(1:10),
#'  line = c('test line', 'test line','test line','test line','test line',
#'  'test line','test line','test line','test line','test line')
#'  )
#' splitTables(all_tables)
splitTables <- function(combined_tables) {
  #start the timer for reporting
  start_time <- proc.time()[[3]]
  cat('...starting table split at', format(Sys.time(), '%H:%M:%S'), '\n')

  table_split <- combined_tables %>%
    split(combined_tables$rectype)

  cat('...Split complete at', format(Sys.time(), '%H:%M:%S'),
      '- elapsed time:', proc.time()[[3]] - start_time, 'seconds\n')

  return(table_split)
}
