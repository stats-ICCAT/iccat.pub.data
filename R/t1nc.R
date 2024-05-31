#' TBD
#'
#' @param t1nc_data TBD
#' @param by_species TBD
#' @param by_stock TBD
#' @param by_gear TBD
#' @param by_catch_type TBD
#' @param rank TBD
#' @return TBD
#' @export
t1nc.summarise = function(t1nc_data, year_min = NA, year_max = NA,
                          by_species = TRUE, by_stock = TRUE, by_gear = TRUE, by_catch_type = TRUE,
                          rank = FALSE) {

  T1NC_proc = t1nc_data[, .(CATCH = round(sum(Qty_t, na.rm = TRUE), 0)),
                        keyby = .(SPECIES_CODE = Species, FLAG_CODE = FlagName, GEAR_GROUP_CODE = GearGrp, STOCK_CODE = Stock, CATCH_TYPE_CODE = CatchTypeCode, YEAR = YearC)]

  T1NC_proc[, FLAG_CODE       := as.factor(FLAG_CODE)]
  T1NC_proc[, SPECIES_CODE    := as.factor(SPECIES_CODE)]
  T1NC_proc[, STOCK_CODE      := as.factor(STOCK_CODE)]
  T1NC_proc[, GEAR_GROUP_CODE := as.factor(GEAR_GROUP_CODE)]
  T1NC_proc[, CATCH_TYPE_CODE := as.factor(CATCH_TYPE_CODE)]

  year_min = ifelse(is.na(year_min), min(T1NC_proc$YEAR), year_min)
  year_max = ifelse(is.na(year_max), max(T1NC_proc$YEAR), year_max)

  T1NC_proc$YEAR =
    factor(
      T1NC_proc$YEAR,
      levels = year_min:year_max,
      labels = year_min:year_max
    )

  formula_components = c()
  grouped_columns = 0

  formula_components = append(formula_components, "FLAG_CODE")
  grouped_columns = grouped_columns + 1

  if(by_species) {
    formula_components = append(formula_components, "SPECIES_CODE")
    grouped_columns = grouped_columns + 1
  }

  if(by_stock) {
    formula_components = append(formula_components, "STOCK_CODE")
    grouped_columns = grouped_columns + 1
  }

  if(by_gear) {
    formula_components = append(formula_components, "GEAR_GROUP_CODE")
    grouped_columns = grouped_columns + 1
  }

  if(by_catch_type) {
    formula_components = append(formula_components, "CATCH_TYPE_CODE")
    grouped_columns = grouped_columns + 1
  }

  formula = paste0(formula_components, collapse = " + ")
  formula = paste0(formula, " ~ YEAR")

  T1NC_proc_d =
    dcast.data.table(
      T1NC_proc,
      formula = as.formula(formula), #SPECIES_CODE + STOCK_CODE + FLAG_CODE + GEAR_GROUP_CODE ~ YEAR,
      value.var = "CATCH",
      fun.aggregate = sum, #function(x) ifelse(is.na(x), NA_real_, x),
      fill = NA,
      drop = c(TRUE, FALSE)
    )

  T1NC_proc_m =
    melt.data.table(
      T1NC_proc_d,
      id.vars = 1:grouped_columns,
      measure.vars = (grouped_columns + 1):ncol(T1NC_proc_d),
      variable.name = "YEAR",
      value.name = "CATCH",
    )

  T1NC_proc_m[, YEAR := as.integer(as.character(YEAR))]


  if(rank) {
    T1NC_proc_d[, AVG_CATCH := rowSums(.SD, na.rm = TRUE), .SDcols = ( grouped_columns + 1 ):ncol(T1NC_proc_d)]
    T1NC_proc_d[, AVG_CATCH := AVG_CATCH / (year_max - year_min + 1)]

    T1NC_proc_d = T1NC_proc_d[, RANK := frank(-AVG_CATCH, ties.method = "min")][order(RANK)]

    T1NC_proc_d[, AVG_CATCH_RATIO     := AVG_CATCH / sum(AVG_CATCH)]
    T1NC_proc_d[, AVG_CATCH_RATIO_CUM := cumsum(AVG_CATCH_RATIO)]

    T1NC_proc_d = T1NC_proc_d %>% relocate(AVG_CATCH_RATIO_CUM)
    T1NC_proc_d = T1NC_proc_d %>% relocate(AVG_CATCH_RATIO)
    T1NC_proc_d = T1NC_proc_d %>% relocate(formula_components)

    T1NC_proc_d$AVG_CATCH = NULL
    T1NC_proc_d$RANK      = NULL
  }

  return(
    list(
      raw     = T1NC_proc_m,
      grouped = T1NC_proc_d
    )
  )
}
