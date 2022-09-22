#' Write tables
#'
#' Function that accepts a list of split tables stored in a list object and
#' writes to a fixed width file in a specified directory. Tables can be written
#' individually or all at once.
#' \cr\cr NOTE: This is the slowest step in the process, and seems unnecessary
#' given that the data is already loaded. Is there a way to reparse the data,
#' instead of writing and loading separately?
#' \cr\cr Run time: ~ 4 hours for all, ~15 min for larger tables/MTD
#'
#' @param table_list a list of tables contained separated data from AOC civil extract
#' @param dest_dir destination directory for the resulting separated files
#' @param record_category Define type of record. Default is 'case'.
#' \cr\cr 'case' or 'c' for case record,
#' \cr\cr 'abstract' or 'a' for abstract record
#' \cr\cr support' or 's' for support record
#' @param threads the number of threads for vroom to use. Default is 8.
#'
#' @return No return value
#' @export
#'
#' @examples
#' #don't run these, very slow
#' #writeSepTables(case_tables, 'sep_test/', 'c', threads = 8) #specific table
#' #writeSepTables(case_tables['03'], 'sep_test/', 'c', threads = 8) #all tables
writeSepTables <- function(table_list, dest_dir, record_category = 'c', threads = 8){
  #start timer for reporting
  start_time <- proc.time()[[3]]
  cat('...starting writing tables at', format(Sys.time(), '%H:%M:%S'), '\n')

  #translate the record category to the file name code
  cat_code <- vcapr::getCatCode(record_category)

  #remove the error table in the first position
  #TODO: find a more elegant way to do this
  if(names(table_list)[1] == ''){
    cat('...bad table found in first position. Deleting.')
    table_list <- table_list[-1]
  }

  lapply(
    names(table_list),
    function(table_id) {
      lap_time <- proc.time()[[3]]
      vroom::vroom_write(
        table_list[[table_id]],
        file = paste0(dest_dir, cat_code, table_id),
        col_names = FALSE,
        delim = '',
        num_threads = threads,
        progress = TRUE)

      cat('...Table', table_id, 'written in', proc.time()[[3]] - lap_time, 'seconds\n')
    }
  )

  cat('...All writing complete at', format(Sys.time(), '%H:%M:%S'),
      '- elapsed time:', proc.time()[[3]] - start_time, 'seconds\n')
}
