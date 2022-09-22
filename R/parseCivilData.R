#' Parse civil data
#'
#' Function that accepts info about the files you want to parse and reads them
#' into a list of dataframes using a predefined data dictionary.
#' \cr\cr Run time: 18 seconds for largest tables, 3 minutes for all/MTD
#'
#' @param record_category Define type of record. Default is 'case'.
#' \cr\cr 'case' or 'c' for case record,
#' \cr\cr 'abstract' or 'a' for abstract record
#' \cr\cr 'support' or 's' for support record
#' @param data_dict preloaded data dictionary
#' @param source_dir source directory for the separated files
#' @param record_id (optional) provide the record type number if you only want one table
#'
#' @return list of dataframes
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' #don't run these
#' #parseCivilData('c', civil_data_dict, 'sep/', record_id = 48) #specific
#' #parseCivilData('c', civil_data_dict, 'sep/') #all
parseCivilData <- function(record_category = 'c', data_dict, source_dir, record_id = NA){
  #start timer for reporting
  start_time <- proc.time()[[3]]
  cat('...starting table split at', format(Sys.time(), '%H:%M:%S'), '\n')

  #translate the record category to the file name code
  cat_code <- vcapr::getCatCode(record_category)

  #load the common layout from the data dictionary and add generic line row
  common_layout <- vcapr::getCommonLayout(cat_code, data_dict, 0)

  #create a vector of unique, noncommon table code/ids
  tables <- data_dict %>%
    dplyr::filter(.data$table_code == .data$cat_code & .data$table_id != '00') %>%
    dplyr::distinct(.data$table_code, .data$table_id) %>%
    dplyr::mutate(table_code_id = paste0(.data$table_code, .data$table_id) ) %>%
    dplyr::pull(.data$table_code_id)

  #execute our loader function across the table list
  all_specs <- lapply(tables,
                      function(table){
                        col_spec <- common_layout %>%
                          rbind(
                            data_dict %>%
                              dplyr::filter(.data$table_code == substr(table, 0, 4) & .data$table_id  == substr(table, 5, 6)) %>%
                              dplyr::select(.data$start, .data$end, .data$col_names)
                          )

                        return(col_spec)
                      })

  #name our new list of column specs according to our table list
  names(all_specs) <- tables

  cat('...all specs loaded\n')

  #check to see if a specific record was requested
  if(!is.na(record_id)){
    cat('...loading Table', record_id, '\n')

    table_code_id <- paste0(cat_code, record_id)

    positions <- vroom::fwf_positions(start = all_specs[[table_code_id]]$start,
                               end = all_specs[[table_code_id]]$end,
                               col_names = all_specs[[table_code_id]]$col_names)

    table <- vroom::vroom_fwf(paste0(source_dir, table_code_id), positions )

    cat('...all parsing complete at', format(Sys.time(), '%H:%M:%S'),
        '- elapsed time:', proc.time()[[3]] - start_time, 'seconds\n')

    return(table)
  }

  cat('...loading all tables\n')

  #initialize an empty list
  parsed_tables <- list()

  #if requesting all, apply across vector
  lapply(
    names(all_specs),
    function(filename) {
      lap_time <- proc.time()[[3]]
      tryCatch(
        {
          new_table <- vroom::vroom_fwf(
            paste0(source_dir, filename),
            vroom::fwf_positions(start = all_specs[[filename]]$start,
                          end = all_specs[[filename]]$end,
                          col_names = all_specs[[filename]]$col_names),
            col_types = c(.default = "c"),
            show_col_types = FALSE
          )
          parsed_tables[filename] <<- list(new_table)
          cat('...table', filename, 'written in', proc.time()[[3]] - lap_time, 'seconds\n')
        },
        error = function(cond){
          message('x..write failed for ', filename, ' - ', cond, '\n')
        }
      )
    }
  )

  cat('...all parsing complete at', format(Sys.time(), '%H:%M:%S'),
      '- elapsed time:', proc.time()[[3]] - start_time, 'seconds\n')

  return(parsed_tables)
}
