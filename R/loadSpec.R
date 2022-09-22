#' Subprocess for vectorizing the load of individual specs for a table
#'
#' @param table A table
#'
#' @return A table of column specs
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
loadSpec <- function(table){
  col_spec <- common_spec %>%
    rbind(
      civil_data_dict %>%
        dplyr::filter(.data$table_code == substr(table, 0, 4) & .data$table_id  == substr(table, 5, 6)) %>%
        dplyr::select(.data$start, .data$end, .data$col_names)
    )

  cat('...SPEC FOR', table, 'CREATED\n')

  return(col_spec)
}
