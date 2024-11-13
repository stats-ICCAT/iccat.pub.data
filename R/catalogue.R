#' Combines fishery ranks data and base catalogue data to produce a table with the same structure as the information
#' included in the SCRS summary catalogue
#'
#' @param fishery_ranks_data fishery ranks data retrieved using the \code{\link{iccat.dev.data::catalogue.fn_getT1NC_fisheryRanks}} function provided by the iccat.dev.data library
#' @param catalogue_data catalogue base data retrieved using the \code{\link{iccat.dev.data::catalogue.fn_genT1NC_CatalSCRS}} function provided by the iccat.dev.data library
#' @param year_from to limit the output to data from a given starting year only
#' @param year_to to limit the output to data up to a given ending year only
#' @param pretty_print_catches if catch values should be _pretty printed_, i.e., presented using a comma as thousands separator
#' @param catch_round_digits the number of digits catches should be rounded to
#' @param perc_round_digits the number of digits percentages should be rounded to
#' @return a catalogue table combining the fishery ranks and base catalogue data and filtered according to the specified criteria
#' @export
catalogue.compile = function(fishery_ranks_data, catalogue_data, year_from = 1950, year_to = NA, pretty_print_catches = TRUE, catch_round_digits = 0, perc_round_digits = 2) {
  if(is.null(fishery_ranks_data) || nrow(fishery_ranks_data) == 0) stop("No fishery ranks data available!")
  if(is.null(catalogue_data)     || nrow(catalogue_data) == 0)     stop("No catalogue data available!")

  FR = fishery_ranks_data
  CA = catalogue_data

  FR$DSet = NULL

  CA_NC = CA[DSet == "1-t1", .(Species, Year, Status, FlagName, Stock, GearGrp, QtyNC = Qty)]
  CA_CE = CA[DSet == "2-ce", .(QtyCE = sum(Qty, na.rm = TRUE)), keyby = .(Species, Year, Status, FlagName, Stock, GearGrp)]
  CA_SZ = CA[DSet == "3-sz", .(QtySZ = sum(Qty, na.rm = TRUE)), keyby = .(Species, Year, Status, FlagName, Stock, GearGrp)]
  CA_CS = CA[DSet == "4-cs", .(QtyCS = sum(Qty, na.rm = TRUE)), keyby = .(Species, Year, Status, FlagName, Stock, GearGrp)]

  CA_ALL = merge(CA_NC,  CA_CE, by = c("Species", "Year", "Status", "FlagName", "Stock", "GearGrp"), all.x = TRUE, all.y = TRUE)
  CA_ALL = merge(CA_ALL, CA_SZ, by = c("Species", "Year", "Status", "FlagName", "Stock", "GearGrp"), all.x = TRUE, all.y = TRUE)
  CA_ALL = merge(CA_ALL, CA_CS, by = c("Species", "Year", "Status", "FlagName", "Stock", "GearGrp"), all.x = TRUE, all.y = TRUE)

  CA_ALL[, Score := ""]
  CA_ALL[!is.na(QtyCE), Score := paste0(Score, "a")]
  CA_ALL[!is.na(QtySZ), Score := paste0(Score, "b")]
  CA_ALL[!is.na(QtyCS), Score := paste0(Score, "c")]
  CA_ALL[Score == "", Score := "-1"]

  if(catch_round_digits == 0) {
    CA_final = CA_ALL[, .(Species, Stock, FlagName, Status, GearGrp, DSet = "t1", Year, Value = ifelse(is.na(QtyNC),
                                                                                                       NA_character_,
                                                                                                       str_trim(formatC(QtyNC,
                                                                                                                        format = "d",
                                                                                                                        big.mark = ifelse(pretty_print_catches, ",", "")))))]
  } else {
    CA_final = CA_ALL[, .(Species, Stock, FlagName, Status, GearGrp, DSet = "t1", Year, Value = ifelse(is.na(QtyNC),
                                                                                                       NA_character_,
                                                                                                       str_trim(formatC(QtyNC,
                                                                                                                        format = "f",
                                                                                                                        digits = catch_round_digits,
                                                                                                                        big.mark = ifelse(pretty_print_catches, ",", "")))))]

  }

  CA_final = rbind(CA_final, CA_ALL[, .(Species, Stock, FlagName, Status, GearGrp, DSet = "t2", Year, Value = Score)])

  year_from = ifelse(is.na(year_from), as.integer(as.character(min(CA_final$Year))), year_from)
  year_to   = ifelse(is.na(year_to),   as.integer(as.character(max(CA_final$Year))), year_to)

  CA_final$Year =
    factor(
      CA_final$Year,
      levels = year_from:year_to,
      labels = year_from:year_to,
      ordered = TRUE
    )

  start = Sys.time()

  CA_final_w = dcast.data.table(CA_final[!is.na(Year)],
                                formula = Species + Stock + FlagName + Status + GearGrp + DSet ~ Year,
                                value.var = "Value",
                                drop = c(TRUE, FALSE))

  end = Sys.time()

  log_debug(paste0("DCast-ing table (", nrow(CA_final), " -> ", nrow(CA_final_w), " rows): ", end - start))

  start = Sys.time()

  CA_W = merge(FR[, .(Species, Stock, FlagName, Status, GearGrp, FisheryRank,
                      TotCatches = round(Qty, catch_round_digits),
                      Perc = round(avgQtyRatio * 100, perc_round_digits),
                      PercCum = round(avgQtyRatioCum * 100, perc_round_digits))], CA_final_w,
               by = c("Species", "Stock", "FlagName", "Status", "GearGrp"),
               all.x = TRUE, all.y = FALSE,
               sort = FALSE)

  end = Sys.time()

  DEBUG(paste0("Merging tables (", nrow(CA_W), " rows): ", end - start))

  return(CA_W)
}

#' Splits a catalogue table, as produced by \code{\link{catalogue.compile}}, in multiple tables with a set number of rows each
#'
#' @param catalogue a catalogue table
#' @param max_rows the maximum number of rows to be included in each _slice_
#' @return a list of catalogue tables each of which is a subset of the original one and consists of _max_rows_ rows at maximum.
#' THe  _union_ of these subset tables will result in the original table.
#' @export
catalogue.split = function(catalogue, max_rows = 60) {
  rows = split_rows(catalogue, max_rows)

  return(apply(rows, 1, function(row) { catalogue[row[1]:row[2]] }))
}

split_rows = function(table, max_rows = 60) {
  rows = data.table(min_row = integer(), max_row = integer())

  for(r in seq(1, nrow(table), max_rows))
    rows = rbind(rows, data.table(min_row = r, max_row = min(r + max_rows - 1, nrow(table))))

  return(rows)
}
