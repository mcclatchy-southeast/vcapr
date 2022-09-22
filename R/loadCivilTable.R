#' Use table specs to load in a civil data table
#'
#' @param table_path Description
#' @param all_specs Description
#'
#' @return A parsed table
#' @export
#'
#' @examples
#' #' #load all specifications per a specified data dictionary
#' all_specs <- loadAllSpecs(civil_data_dict)
#'
#' #load relevant tables from civil data
#' issue_type <- loadCivilTable('../../aoc/2022/sep/NOBC23', all_specs)
#' party_names <- loadCivilTable('../../aoc/2022/sep/NOBC48', all_specs)
loadCivilTable <- function(table_path, all_specs){

  if(file.exists(table_path)){
    table_name <- basename(table_path)
    positions <- vroom::fwf_positions(start = all_specs[[table_name]]$start,
                                      end = all_specs[[table_name]]$end,
                                      col_names = all_specs[[table_name]]$col_names)
    df <- vroom::vroom_fwf(table_path, positions )
    return(df)
  }
  else{
    cat('x  ERROR:', table_path, 'DOES NOT EXIST\n')
  }

}
