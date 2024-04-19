DEFAULT_REL_DIFF_LIMITS =
  list(
    T0_100      = list(LOW = .9),
    T100_1000   = list(LOW = .5 , MED = .9),
    T1000_10000 = list(LOW = .1,  MED = .5, HIGH = .9),
    T10000_     = list(LOW = .05, MED = .1, HIGH = .5, VERY_HIGH = .9)
  )

#' TBD
#'
#' @param t1nc_data TBD
#' @param by_species TBD
#' @param by_stock TBD
#' @param by_gear TBD
#' @return TBD
#' @export
t1nc.summarise = function(t1nc_data,
                          by_species = TRUE, by_stock = TRUE, by_gear = TRUE) {

  T1NC_proc = t1nc_data[, .(CATCH = round(sum(Qty_t, na.rm = TRUE), 0)),
                        keyby = .(SPECIES_CODE = Species, FLAG_CODE = FlagName, GEAR_GROUP_CODE = GearGrp, STOCK_CODE = Stock, YEAR = YearC)]

  T1NC_proc[, SPECIES_CODE    := as.factor(SPECIES_CODE)]
  T1NC_proc[, FLAG_CODE       := as.factor(FLAG_CODE)]
  T1NC_proc[, GEAR_GROUP_CODE := as.factor(GEAR_GROUP_CODE)]
  T1NC_proc[, STOCK_CODE      := as.factor(STOCK_CODE)]
  T1NC_proc[, YEAR            := as.factor(YEAR)]

  formula_components = c()
  grouped_columns = 0

  formula_components = append(formula_components, "FLAG_CODE")
  grouped_columns = grouped_columns + 1

  if(by_species) {
    formula_components = append(formula_components, "SPECIES_CODE")
    grouped_columns = grouped_columns + 1
  }

  if(by_gear) {
    formula_components = append(formula_components, "GEAR_GROUP_CODE")
    grouped_columns = grouped_columns + 1
  }

  if(by_stock) {
    formula_components = append(formula_components, "STOCK_CODE")
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
      fill = NA, drop = TRUE
    )

  T1NC_proc_m =
    melt.data.table(
      T1NC_proc_d,
      id.vars = 1:grouped_columns,
      measure.vars = (grouped_columns + 1):ncol(T1NC_proc_d),
      variable.name = "YEAR",
      value.name = "CATCH"
    )

  T1NC_proc_m[, YEAR := as.integer(as.character(YEAR))]

  return(
    list(
      raw     = T1NC_proc_m,
      grouped = T1NC_proc_d
    )
  )
}
