#' Retrieve the common layout for a table
#'
#' Simple utility function to convert a record category code into a dataframe
#' with the common record layout based on a specified data dictionary dataframe.
#'
#' @param cat_code category code for the record ('NOBC', etc.)
#' @param data_dict a dataframe of data dictionary values with cols start, end & col_names
#' @param add_line a flag to specify a generic catch-all column before initial splitting (default is 1)
#'
#' @return a dataframe with layout specs
#' @importFrom dplyr %>%
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' cat_code <- getCatCode('c')
#' getCommonLayout(cat_code, civil_data_dict)
getCommonLayout <- function(cat_code, data_dict, add_line = 1){

  #load the common layout from the data dictionary and add generic line row
  common_layout <- data_dict %>%
    dplyr::filter(.data$table_code == cat_code & .data$table_id == '00') %>%
    dplyr::select(.data$start, .data$end, .data$col_names)

  if(add_line == 1){
    common_layout <- common_layout %>%
      dplyr::add_row(start = 25, end = 500, col_names = 'line')
  }

  return(common_layout)
}
