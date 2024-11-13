#' Retrieves stock metadata for one or more species.
#' These include a table with stock / statistical / sampling area code for each species, and an overall summary of
#' their cardinality
#'
#' @param species_codes one or more species codes
#' @return a list of metadata describing the stocks for the provided species codes
#' @export
stock.metadata = function(species_codes = NULL) {
  stock_data = REF_STOCKS

  if(!is.null(species_codes)) stock_data = stock_data[SPECIES_CODE %in% species_codes]

  num_stocks            = length(unique(stock_data[STOCK_CODE != "--"]$STOCK_CODE))
  num_statistical_areas = length(unique(stock_data[STATISTICAL_AREA_CODE != "--"]$STATISTICAL_AREA_CODE))

  return(
    list(
      stock_data = stock_data,
      num_stocks            = ifelse(num_stocks == 0,            "N/A", num_stocks),
      num_statistical_areas = ifelse(num_statistical_areas == 0, "N/A", num_statistical_areas),
      num_sampling_areas    = length(unique(stock_data$SAMPLING_AREA_CODE))
    )
  )
}

#' Retrieves stock summary data for one or more species as a table including the stock codes and the number of
#' statistical area codes and sampling areas for each of them
#'
#' @param species_codes one or more species codes
#' @return a table describing the structure of the stocks for the provided species codes#'
#' @export
stock.summary = function(species_codes = NULL) {
  stock_data = REF_STOCKS

  if(!is.null(species_codes)) stock_data = stock_data[SPECIES_CODE %in% species_codes]

  stock_data[STOCK_CODE == "", STOCK_CODE := "--"]
  stock_data[STATISTICAL_AREA_CODE == "", STATISTICAL_AREA_CODE := "--"]

  return(
    stock_data[, .(NUM_SAMPLING_AREAS = length(unique(SAMPLING_AREA_CODE))),
               keyby = .(SPECIES_GROUP, SPECIES_CODE, STOCK_CODE, STATISTICAL_AREA_CODE)]
  )
}
