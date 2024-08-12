#' The data sources
#'
#' @format
#' \describe{
#'   \item{CODE}{The data source code}
#'   \item{NAME_EN}{The data source English name}
#' }
#' @export
"REF_DATA_SOURCES"

#' The data source contents
#'
#' @format
#' \describe{
#'   \item{CODE}{The data source content code}
#'   \item{NAME_EN}{The data source content English name}
#'   \item{NAME_ES}{The data source content Spanish name}
#'   \item{NAME_FR}{The data source content French name}
#' }
#' @export
"REF_DATA_SOURCE_CONTENTS"

#' The reference time periods
#'
#' @format
#' \describe{
#'   \item{CODE}{The time period code}
#'   \item{TIME_PERIOD_GROUP_CODE}{The time period group code}
#'   \item{NAME_EN}{The time period English name}
#' }
#' @export
"REF_TIME_PERIODS"

#' The reference time period groups
#'
#' @format
#' \describe{
#'   \item{CODE}{The time period group code}
#'   \item{NAME_EN}{The time period group English name}
#' }
#' @export
"REF_TIME_PERIOD_GROUPS"

#' The reference parties (CPCs)
#'
#' @format
#' \describe{
#'   \item{CODE}{The party code}
#'   \item{STATUS_TYPE_CODE}{The party status code}
#'   \item{ENTITY_TYPE_CODE}{The party entity code}
#'   \item{NAME_EN}{The party English name}
#'   \item{ACCESSION_DATE}{The party accession date}
#' }
#' @export
"REF_PARTIES"

#' The reference party status
#'
#' @format
#' \describe{
#'   \item{CODE}{The party status code}
#'   \item{NAME_EN}{The party status English name}
#'   \item{DESCRIPTION_EN}{The party status English description}
#' }
#' @export
"REF_PARTY_STATUS"

#' The reference flags
#'
#' @format
#' \describe{
#'   \item{CODE}{The flag code}
#'   \item{NAME_EN}{The flag English name}
#' }
#' @export
"REF_FLAGS"

#' The reference fleets
#'
#' @format
#' \describe{
#'   \item{ID}{The fleet ID}
#'   \item{CODE}{The fleet code}
#'   \item{FLAG_CODE}{The flag code for the fleet}
#'   \item{VESSEL_FLAG_CODE}{The vessel flag code for the fleet}
#'   \item{NAME_EN}{The fleet English name}
#'   \item{DEPRECATED}{If the fleet is deprecated and kept for historical reasons only}
#' }
#' @export
"REF_FLEETS"

#' The reference square types
#'
#' @format
#' \describe{
#'   \item{CODE}{The square type code}
#'   \item{NAME_EN}{The square type English name}
#'   \item{DEPRECATED}{If the square type is deprecated and kept for historical reasons only}
#' }
#' @export
"REF_SQUARE_TYPES"

#' The reference fishing zones
#'
#' @format
#' \describe{
#'   \item{CODE}{The fishing zone code}
#'   \item{NAME_EN}{The fishing zone English name}
#' }
#' @export
"REF_FISHING_ZONES"

#' The reference fishing zones
#'
#' @format
#' \describe{
#'   \item{CODE}{The fishing zone code}
#'   \item{QUADRANT_CODE}{The fishing area quadrant code}
#'   \item{GEO_AREA_CODE}{The fishing area geographical area code}
#'   \item{NAME_EN}{The fishing area English name}
#'   \item{DEPRECATED}{If the fishing area is deprecated and kept for historical reasons only}
#' }
#' @export
"REF_AREAS"

#' The reference sampling areas
#'
#' @format
#' \describe{
#'   \item{CODE}{The sampling area code}
#'   \item{NAME_EN}{The sampling area English name}
#' }
#' @export
"REF_SAMPLING_AREAS"

#' The reference data quality levels
#'
#' @format
#' \describe{
#'   \item{CODE}{The quality level code}
#'   \item{QUALITY_GROUP_CODE}{The quality level group code}
#'   \item{NAME_EN}{The quality level English name}
#'   \item{DESCRIPTION_EN}{The quality level English description}
#' }
#' @export
"REF_QUALITY_LEVELS"

#' The reference gear groups
#'
#' @format
#' \describe{
#'   \item{CODE}{The gear group code}
#'   \item{NAME_EN}{The gear group English name}
#' }
#' @export
"REF_GEAR_GROUPS"

#' The reference gears
#'
#' @format
#' \describe{
#'   \item{CODE}{The gear code}
#'   \item{GEAR_GROUP_CODE}{The gear group code}
#'   \item{NAME_EN}{The gear English name}
#'   \item{DISCARDS}{If the specific gear is used to report discards - DEPRECATED}
#' }
#' @export
"REF_GEARS"

#' The reference gear groups by species
#'
#' @format
#' \describe{
#'   \item{SPECIES_CODE}{The species code}
#'   \item{GEAR_GROUP_CODE}{The gear group code}
#'   \item{SPECIES_GEAR_GROUP}{The species gear group}
#'   \item{SPECIES_GEAR_GROUP_ORDER}{The species gear group order}
#' }
#' @export

"REF_SPECIES_GEAR_GROUPS"

#' The reference effort types
#'
#' @format
#' \describe{
#'   \item{CODE}{The effort type code}
#'   \item{NAME_EN}{The effort type English name}
#'   \item{GEAR_DEPENDENT}{If the effort type is associated to a specific gear}
#' }
#' @export
"REF_EFFORT_TYPES"

#' The reference catch types
#'
#' @format
#' \describe{
#'   \item{ID}{The catch type ID}
#'   \item{CODE}{The catch type code}
#'   \item{NAME_EN}{The catch type English name}
#'   \item{NAME_ES}{The catch type Spanish name}
#'   \item{NAME_FR}{The catch type French name}
#'   \item{CATCH_TYPE_GROUP}{The catch type group}
#' }
#' @export
"REF_CATCH_TYPES"

#' The reference species
#'
#' @format
#' \describe{
#'   \item{ID}{The species ID (ICCAT)}
#'   \item{CODE}{The species code (FAO 3-ALPHA)}
#'   \item{SCIENTIFIC_NAME}{The species scientific name}
#'   \item{NAME_EN}{The species English name}
#'   \item{NAME_ES}{The species Spanish name}
#'   \item{NAME_FR}{The species French name}
#'   \item{SPECIES_GROUP}{The species group}
#'   \item{SPECIES_GROUP_ICCAT}{The ICCAT species group}
#' }
#' @export
"REF_SPECIES"

#' The reference species metadata
#'
#' @format
#' \describe{
#'   \item{CODE}{The species code}
#'   \item{NAME_EN}{The species English name}
#'   \item{NAME_ES}{The species Spanish name}
#'   \item{NAME_FR}{The species French name}
#'   \item{STOCK_BOUNDARY_ID}{The species stock boundary ID}
#'   \item{SPECIES_GROUP_CODE}{The species group code}
#' }
#' @export
"REF_SPECIES_META"

#' The reference stock metadata
#'
#' @format
#' \describe{
#'   \item{SPECIES_CODE}{The species code}
#'   \item{SPECIES_GROUP}{The species group}
#'   \item{STOCK_CODE}{The stock code}
#'   \item{STATISTICAL_AREA_CODE}{The statistical area code}
#'   \item{SAMPLING_AREA_CODE}{The sampling area code}
#' }
#' @export
"REF_STOCKS"

#' The reference stock areas
#'
#' @format
#' \describe{
#'   \item{CODE}{The stock area code}
#'   \item{NAME_EN}{The stock area English name}
#' }
#' @export
"REF_STOCK_AREAS"

#' The product types
#'
#' @format
#' \describe{
#'   \item{CODE}{The product type code}
#'   \item{NAME_EN}{The product type English name}
#'   \item{IS_WEIGHT}{If the product type refers to a weight (1) or to a number (0)}
#' }
#' @export
"REF_PRODUCT_TYPES"

#' The sampling units
#'
#' @format
#' \describe{
#'   \item{CODE}{The sampling unit code}
#'   \item{NAME_EN}{The sampling unit English name}
#' }
#' @export
"REF_SAMPLING_UNITS"

#' The sampling locations
#'
#' @format
#' \describe{
#'   \item{CODE}{The sampling location code}
#'   \item{NAME_EN}{The sampling location English name}
#' }
#' @export
"REF_SAMPLING_LOCATIONS"

#' The frequency types
#'
#' @format
#' \describe{
#'   \item{CODE}{The frequency type code}
#'   \item{NAME_EN}{The frequency type English name}
#'   \item{FREQUENCY_TYPE_GROUP_CODE}{The frequency type group code}
#' }
#' @export
"REF_FREQUENCY_TYPES"

#' The reference size class limits
#'
#' @format
#' \describe{
#'   \item{CODE}{The size class limit code}
#'   \item{NAME_EN}{The size class limit English name}
#' }
#' @export
"REF_SIZE_CLASS_LIMITS"
