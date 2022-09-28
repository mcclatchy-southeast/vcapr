#' Process a raw civil extract file
#'
#' @description
#' Import, parse and write single raw file from the extract data provided by the
#' N.C. Administrative Office of the Courts for the VCAP system managing civil courts.
#' By default, parsing follows the VCAP extract file layout for case tables.
#'
#' @note
#' Because this function is often used to loop through multiple files, it currently
#' appends data to existing files with the same table name in your destination directory.
#' Be careful not to double-count your data!
#'
#' @param file_path path containing raw file with filename NOBC0001 or NOBC0002 etc.
#' @param dest_dir directory for writing files
#' @param record_category define type of record. Default is 'case'
#' \cr\cr'case' or 'c' for case record,
#' \cr\cr'abstract' or 'a' for abstract record
#' \cr\cr'support' or 's' for support record
#' @param data_dict layout file containing the data dictionary. Default is built-in
#' data dictionary
#'
#' @return a dataframe reporting out rows details and parse time
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' processCivilFile('/vcap/NOBC0001', 'vcap/2022/sep_test')
processCivilFile <- function(file_path,
                             dest_dir,
                             record_category = 'c',
                             data_dict = vcapr::civil_data_dict
                             ){
  #start the timer for reporting
  start_time <- proc.time()[[3]]
  cat('...STARTING FILE IMPORT AT', format(Sys.time(), '%H:%M:%S'), '\n')

  #translate the record category to the file name code
  cat_code <- vcapr::getCatCode(record_category)

  #create a blank dataframe with results and timing for reporting
  process_results <- dplyr::tibble(
    file_name = character(),
    table_name = character(),
    rows = numeric(),
    parse_seconds = numeric()
    )

  #check for valid category code
  if(cat_code == 'INVALID'){
    cat('x  ERROR: INVALID CATEGORY CODE. DID YOU MEAN c, a OR s?\n')
    return(process_results)
  }

  #check the filename for mistaken entry
  file_base <- stringr::str_remove(basename(file_path), '\\d+')
  if(file_base != cat_code){
    cat('...THE FILE NAME', basename(file_path),
        'DOES NOT MATCH ENTERED RECORD CATEGORY. CHECK YOUR FILE.\n')
    return(process_results)
  }

  #check if the file exists
  if(!file.exists(file_path)){
    cat('x  ERROR: FILE DOES NOT EXIST.\n')
    return(process_results)
  }

  #check if the destination directory exists
  if(!dir.exists(dest_dir)){
    cat('x  ERROR: DESTINATION DIRECTORY DOES NOT EXIST OR IS NOT A DIRECTORY (DID YOU FORGET THE SLASH?).\n')
    return(process_results)
  }

  cat('...READING VALID FILE PATH AT', file_path, '\n')

  #load the common layout from the data dictionary and add generic line row
  common_layout <- vcapr::getCommonLayout(cat_code, data_dict, 1)

  #translate that common layout into a fwf_position object for vroom
  positions <- vroom::fwf_positions(start = common_layout$start,
                                    end = common_layout$end,
                                    col_names = common_layout$col_names)

  #load all file lines with vroom
  full_table <- vroom::vroom_fwf(file_path,
                                 positions,
                                 #remove undocumented columns
                                 col_select = c(-'f1', -'v2'),
                                 na = character(),
                                 trim_ws = FALSE,
                                 altrep = TRUE,
                                 col_types = c(.default = "c"),
                                 progress = TRUE)

  cat('---IMPORT COMPLETE AT', format(Sys.time(), '%H:%M:%S'),
      '- ELAPSED TIME:', proc.time()[[3]] - start_time, 'SECONDS...\n\n')

  #update lap time
  lap_time <- proc.time()[[3]]

  cat('...SPLITTING TABLE\n')

  #convert to a data table to speed up the split
  full_table <- data.table::setDT(full_table)

  #split using the record type
  table_split <- full_table %>%
    split(full_table$rectype)

  #get the total count of tables
  table_count <- length(table_split)

  #generate a list of valid table names
  valid_table_names <- data_dict %>%
    dplyr::filter(.data$table_code == cat_code & .data$table_id != '00' ) %>%
    dplyr::distinct(.data$table_id) %>%
    dplyr::pull(.data$table_id)

  #filter the tables based on valid table names
  clean_tables <- table_split[names(table_split) %in% valid_table_names]

  #update our clean table number
  clean_table_count <- length(clean_tables)

  cat('...PARSED', clean_table_count, 'VALID TABLES OF', table_count, '...\n')

  cat('---SPLIT OF', clean_table_count, 'TABLES COMPLETE AT', format(Sys.time(), '%H:%M:%S'),
      '- ELAPSED TIME:', proc.time()[[3]] - lap_time, 'SECONDS...\n\n')

  for (table_name in names(clean_tables)){
    #update lap time
    table_time <- proc.time()[[3]]
    lap_time <- proc.time()[[3]]

    cat('...PARSING TABLE', table_name, 'AT', format(Sys.time(), '%H:%M:%S'), '...\n')

    #pull out column names for given table
    col_names <- data_dict %>%
      dplyr::filter(.data$table_code == cat_code & .data$table_id != '00' &
                      .data$table_id == table_name) %>%
      dplyr::pull(.data$col_names)

    #pull out starting positions for given table, omitting first
    starting_positions <- data_dict %>%
      dplyr::filter(.data$table_code == cat_code & .data$table_id != '00' &
                      .data$table_id == table_name) %>%
      dplyr::mutate(start = .data$start - 25) %>%
      dplyr::pull(.data$start) %>%
      utils::tail(-1)

    #execute the split on the unparsed line column
    table <- clean_tables[[table_name]] %>%
      #deal with this annoying non-ascii issue
      dplyr::mutate(line = iconv(.data$line, sub = ' ' )) %>%
      tidyr::separate(.data$line, into = col_names, sep = starting_positions)

    #get number of rows for reporting
    rows <- nrow(table)

    cat('---PARSE SUCCESSFUL AT', format(Sys.time(), '%H:%M:%S'),
        '- ELAPSED TIME:', proc.time()[[3]] - lap_time, 'SECONDS...\n')

    #update lap time
    lap_time <- proc.time()[[3]]

    #get the file name
    save_file <- paste0(dest_dir, cat_code, table_name, '.csv')

    #write to file and append only if file exists
    vroom::vroom_write(
      table,
      file = save_file,
      delim = ',',
      append = file.exists(save_file),
      progress = TRUE)

    cat('---WRITE SUCCESSFUL AT', format(Sys.time(), '%H:%M:%S'),
        '- ELAPSED TIME:', proc.time()[[3]] - lap_time, 'SECONDS...\n\n')

    #update results dataframe
    process_results <- process_results %>%
      dplyr::add_row(file_name = basename(file_path),
              table_name = table_name,
              rows = rows,
              parse_seconds = proc.time()[[3]] - table_time
              )

  }

  cat('---', clean_table_count, 'TABLES WRITTEN AT', format(Sys.time(), '%H:%M:%S'),
      '- TOTAL ELAPSED TIME:', proc.time()[[3]] - start_time, 'SECONDS...\n\n')

  return(process_results)

}
