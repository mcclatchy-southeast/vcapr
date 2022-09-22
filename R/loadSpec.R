loadSpec <- function(table){
  col_spec <- common_spec %>%
    rbind(
      civil_data_dict %>%
        filter(table_code == substr(table, 0, 4) & table_id  == substr(table, 5, 6)) %>%
        select(start, end, col_names)
    )

  cat('...SPEC FOR', table, 'CREATED\n')

  return(col_spec)
}
