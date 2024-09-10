#' TBD - temporarily export-ed
#'
#' @param fishery_ranks_data TBD
#' @param catalogue_data TBD
#' @param year_from TBD
#' @param year_to TBD
#' @param pretty_print_catches TBD
#' @param catch_round_digits TBD
#' @param perc_round_digits TBD
#' @return TBD
#' @export
catalogue.compile = function(fishery_ranks_data, catalogue_data, year_from = NA, year_to = NA, pretty_print_catches = TRUE, catch_round_digits = 0, perc_round_digits = 2) {
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

  CA_final_w = dcast.data.table(CA_final,
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

split_rows = function(table, max_rows = 60) {
  rows = data.table(min_row = integer(), max_row = integer())

  for(r in seq(1, nrow(catalogue), 60))
    rows = rbind(rows, data.table(min_row = r, max_row = min(r + max_rows - 1, nrow(table))))

  return(rows)
}

#' TBD
#'
#' @param catalogue TBD
#' @param max_rows TBD
#' @return TBD
#' @export
catalogue.split = function(catalogue, max_rows = 60) {
  rows = split_rows(catalogue, max_rows)

  return(apply(rows, 1, function(row) { catalogue[row[1]:row[2]] }))
}
