#' Import civil data
#'
#' Import function to load in all tables exported by AOC of a specified record
#' category, using a predefined data dictionary of start and end positions. Produces
#' a dataframe with seven columns, where the first six are the the common layout
#' for the specified record category, followed by the fixed width line.
#' \cr\cr NOTE: Embedded nulls in some files required advanced cleaning of files using perl:
#' \cr\cr```$ perl -pe 's/\0/ /g' < NOBC0001 > NOBC0001fix```
#' \cr\cr Run time: 2 minutes/MTD
#'
#' @param record_category Define type of record. Default is 'case'.
#' 'case' or 'c' for case record,
#' 'abstract' or 'a' for abstract record
#' 'support' or 's' for support record
#' @param data_dict the built-in data dictionary
#' @param source_dir the directory containing files from AOC, with filenames NOBC0001 etc.
#'
#' @return a very large dataframe
#' @export
#'
#' @examples
#' importFiles('c', civil_data_dict, 'vcap/')
importFiles <- function(record_category = 'c', data_dict, source_dir){
  #start the timer for reporting
  start_time <- proc.time()[[3]]
  cat('...STARTING FILE IMPORT AT', format(Sys.time(), '%H:%M:%S'), '\n')

  #translate the record category to the file name code
  cat_code <- vcapr::getCatCode(record_category)

  #check for valid category code
  if(cat_code == 'INVALID'){
    cat('x  ERROR: INVALID CATEGORY CODE. DID YOU MEAN c, a OR s?')
    stop()
  }

  #load the fill directory of files
  full_dir <- list.files(source_dir)

  #filter the full directory for the category of records specified
  case_files <- sapply(full_dir[grepl(paste0('^', cat_code), full_dir)],
                       function(filename) paste0(source_dir, filename))

  #load the common layout from the data dictionary and add generic line row
  common_layout <- vcapr::getCommonLayout(cat_code, data_dict, 1)

  #translate that common layout into a fwf_position object for vroom
  positions <- vroom::fwf_positions(start = common_layout$start,
                             end = common_layout$end,
                             col_names = common_layout$col_names)

  #load all case file lines with vroom
  case <- vroom::vroom_fwf(case_files,
                    positions,
                    na = character(),
                    trim_ws = FALSE,
                    col_types = c(.default = "c"),
                    progress = TRUE)

  cat('...IMPORT COMPLETE AT', format(Sys.time(), '%H:%M:%S'),
      '- ELAPSED TIME:', proc.time()[[3]] - start_time, 'SECONDS\n')

  return(case)
}
