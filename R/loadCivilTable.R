#' Use table specs to load in a civil data table
#'
#' @param table_path
#' @param all_specs
#'
#' @return
#' @export
#'
#' @examples
load_civil_table <- function(table_path, all_specs){
  table_name <- basename(table_path)
  positions <- fwf_positions(start = all_specs[[table_name]]$start,
                             end = all_specs[[table_name]]$end,
                             col_names = all_specs[[table_name]]$col_names)
  df <- vroom_fwf(table_path, positions )
  return(df)
}
