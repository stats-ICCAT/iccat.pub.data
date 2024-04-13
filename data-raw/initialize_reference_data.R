library(iccat.dev.base)

### Species

REF_SPECIES =
  tabular_query(
    DB_T1(), "
    SELECT
    	Alfa3FAO AS CODE,
    	NameUK AS NAME_EN,
    	NameFR AS NAME_FR,
    	NameES AS NAME_ES,
    	StockBoundID AS STOCK_BOUNDARY_ID,
    	SpeciesGrp AS SPECIES_GROUP
    FROM
    	[dbo].[Species]
    WHERE
    	LEFT(SpeciesGrp, 1) IN ('1', '2', '3')
    ORDER BY
    	6 ASC, 1 ASC"
  )

usethis::use_data(REF_SPECIES, overwrite = TRUE, compress = "gzip")

### Stock areas

REF_STOCK_AREAS =
  tabular_query(
    DB_T1(), "
    SELECT DISTINCT
      SAreaName AS CODE,
      SAreaDesc AS NAME_EN
    FROM
      [dbo].[StocksAreas]
    ORDER BY
      1, 2"
  )

usethis::use_data(REF_STOCK_AREAS, overwrite = TRUE, compress = "gzip")

### Gear groups

REF_GEAR_GROUPS =
  tabular_query(
    DB_STAT(), "
      SELECT
        GearGrpCode AS CODE,
        GearGroup   AS NAME_EN
      FROM
        [dbo].GearGroups
      ORDER BY
        GearID_fstat --GearGrpCode
    "
)

REF_GEAR_GROUPS = rbind(REF_GEAR_GROUPS, data.table(CODE = "OT", NAME_EN = "Other gears"))
usethis::use_data(REF_GEAR_GROUPS, overwrite = TRUE, compress = "gzip")

### Flags

REF_FLAGS =
  tabular_query(
    DB_STAT(), "
    SELECT DISTINCT
      FlagCode AS CODE,
      FlagName AS NAME_EN
    FROM
      [dbo].[Flags]
    ORDER BY
      2"
  )

usethis::use_data(REF_FLAGS, overwrite = TRUE, compress = "gzip")
