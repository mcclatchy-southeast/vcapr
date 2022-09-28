#' Process a directory of raw civil extract files
#'
#' @description
#' Import, parse and write an entire directory of extract data provided by the
#' N.C. Administrative Office of the Courts for the VCAP system managing civil courts.
#' By default, parsing follows the VCAP extract file layout for case tables.
#'
#' @param source_dir directory containing raw files
#' @param dest_dir directory for writing files
#' @param record_category define type of record. Default is 'case'
#' \cr\cr'case' or 'c' for case record,
#' \cr\cr'abstract' or 'a' for abstract record
#' \cr\cr'support' or 's' for support record
#' @param data_dict layout file containing the data dictionary. Default is built-in
#' data dictionary
#'
#' @return a dataframe reporting out rows details and parse time
#' @export
#'
#' @examples
#' process_results <- processCivilDirectory('/vcap/tables/', 'vcap/2022/sep_test')
processCivilDirectory <- function(source_dir,
                             dest_dir,
                             record_category = 'c',
                             data_dict = vcapr::civil_data_dict){

  # start the timer for reporting
  start_time <- proc.time()[[3]]
  cat('...STARTING DIRECTORY PROCESS AT', format(Sys.time(), '%H:%M:%S'), '\n\n')

  # create a blank dataframe with results and timing for reporting
  process_results <- dplyr::tibble(
    file_name = character(),
    table_name = character(),
    rows = numeric(),
    parse_seconds = numeric()
  )

  #translate the record category to the file name code
  cat_code <- vcapr::getCatCode(record_category)
  #check for valid category code
  if(cat_code == 'INVALID'){
    cat('x  ERROR: INVALID CATEGORY CODE. DID YOU MEAN c, a OR s?\n')
    return(process_results)
  }

  # check if the directory exists
  if(!dir.exists(source_dir)){
    cat('x  ERROR: SOURCE DIRECTORY DOES NOT EXIST OR IS NOT A DIRECTORY (DID YOU FORGET THE SLASH?).\n')
    return(process_results)
  }

  #load the full directory of files
  full_dir <- list.files(source_dir)

  #filter the full directory for the category of records specified
  files <- sapply(full_dir[grepl(paste0('^', cat_code, '\\d+$'), full_dir)],
         function(filename) paste0(source_dir, filename))

  #logout the file selection for user
  cat('...PROCESSING THE FOLLOWING FILES:', '\n')
  for(file in files){
    cat('...   ', basename(file), '\n')
  }
  cat('\n')

  # loop through the files and bind rows to the blank dataframe
  for(file in files){
    process_results <- rbind(
      process_results,
      processCivilFile(file, dest_dir)
    )
  }

  cat('---FINISHED DIRECTORY PARSE AT', format(Sys.time(), '%H:%M:%S'), '- TOTAL ELAPSED TIME:', proc.time()[[3]] - start_time, 'SECONDS\n')

  return(process_results)

}
