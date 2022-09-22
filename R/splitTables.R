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
#' all_tables <- importFiles('c', civil_data_dict, 'vcap/')
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
