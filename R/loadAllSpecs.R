load_all_specs <- function(civil_data_dict){
  start_time <- proc.time()[[3]]

  #create a vector of unique table code/ids using the civil data dictionarr
  tables <- civil_data_dict %>%
    filter(table_type != 'common') %>%
    distinct(table_code, table_id) %>%
    mutate(table_code_id = paste0(table_code, table_id) ) %>%
    pull(table_code_id)

  cat('...TABLE LIST CREATED\n')

  #filter and load into a zero indexed table with the specific specs
  #of the fwf_cols() function, which we can define directly on read
  common_spec <- civil_data_dict %>%
    filter(table_id == '00' | table_id == 0 | table_id == '0') %>%
    select(start, end, col_names)

  cat('...COMMON SPECS CREATED\n')

  #execute our loader function across the table list
  all_specs <- lapply(tables, loadSpec)

  cat('...ALL SPECS LOADED\n')

  #name our new list of column specs
  names(all_specs) <- tables

  cat('✓  SPEC LOAD COMPLETE. ELAPSED TIME:', proc.time()[[3]] - start_time, 'seconds\n')

  return(all_specs)

}
