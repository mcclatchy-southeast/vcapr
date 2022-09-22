#' Use a data dictionary to load specs
#'
#' @param civil_data_dict A dataframe describing the data
#'
#' @return A list of data layouts named for each table
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' #load all specifications per a specified data dictionary
#' all_specs <- loadAllSpecs(civil_data_dict)
loadAllSpecs <- function(civil_data_dict){
  start_time <- proc.time()[[3]]

  #create a vector of unique table code/ids using the civil data dictionary
  tables <- civil_data_dict %>%
    dplyr::filter(.data$table_type != 'common') %>%
    dplyr::distinct(.data$table_code, .data$table_id) %>%
    dplyr::mutate(table_code_id = paste0(.data$table_code, .data$table_id) ) %>%
    dplyr::pull(.data$table_code_id)

  cat('...TABLE LIST CREATED\n')

  #filter and load into a zero indexed table with the specific specs
  #of the fwf_cols() function, which we can define directly on read
  common_spec <- civil_data_dict %>%
    dplyr::filter(.data$table_id == '00' | .data$table_id == 0 | .data$table_id == '0') %>%
    dplyr::select(.data$start, .data$end, .data$col_names)

  cat('...COMMON SPECS CREATED\n')

  #execute our loader function across the table list
  all_specs <- lapply(tables, function(table){
    col_spec <- common_spec %>%
      rbind(
        civil_data_dict %>%
          dplyr::filter(.data$table_code == substr(table, 0, 4) & .data$table_id  == substr(table, 5, 6)) %>%
          dplyr::select(.data$start, .data$end, .data$col_names)
      )

    cat('...SPEC FOR', table, 'CREATED\n')

    return(col_spec)

  })

  cat('...ALL SPECS LOADED\n')

  #name our new list of column specs
  names(all_specs) <- tables

  cat('...SPEC LOAD COMPLETE. ELAPSED TIME:', proc.time()[[3]] - start_time, 'seconds\n')

  return(all_specs)

}
