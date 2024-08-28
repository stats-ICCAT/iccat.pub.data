#' TBD - temporarily export-ed
#'
#' @param fishery_ranks_data TBD
#' @param catalogue_data TBD
#' @param pretty_print_catches TBD
#' @return TBD
#' @export
catalogue.compile = function(fishery_ranks_data, catalogue_data, pretty_print_catches = TRUE) {
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

  if(pretty_print_catches)
    CA_final = CA_ALL[, .(Species, Stock, FlagName, Status, GearGrp, DSet = "t1", Year, Value = ifelse(is.na(QtyNC),
                                                                                                       NA_character_,
                                                                                                       str_trim(format(round(QtyNC, 0), big.mark = ","))))]
  else
    CA_final = CA_ALL[, .(Species, Stock, FlagName, Status, GearGrp, DSet = "t1", Year, Value = ifelse(is.na(QtyNC),
                                                                                                       NA_character_,
                                                                                                       str_trim(as.character(round(QtyNC, 0)))))]

  CA_final = rbind(CA_final, CA_ALL[, .(Species, Stock, FlagName, Status, GearGrp, DSet = "t2", Year, Value = Score)])

  start = Sys.time()

  CA_final_w = dcast.data.table(CA_final,
                                formula = Species + Stock + FlagName + Status + GearGrp + DSet ~ Year,
                                value.var = "Value",
                                drop = c(TRUE, FALSE))

  end = Sys.time()

  log_debug(paste0("DCast-ing table (", nrow(CA_final), " -> ", nrow(CA_final_w), " rows): ", end - start))

  start = Sys.time()

  CA_W = merge(FR[, .(Species, Stock, FlagName, Status, GearGrp, FisheryRank,
                      TotCatches = round(Qty, 0), Perc = round(avgQtyRatio * 100, 2), PercCum = round(avgQtyRatioCum * 100, 2))], CA_final_w,
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
