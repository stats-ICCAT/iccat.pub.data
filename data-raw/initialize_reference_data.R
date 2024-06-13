library(iccat.dev.base)

### Catch types
REF_CATCH_TYPES =
  tabular_query(
    DB_T1(), "
    SELECT
      CT.CatchTypeID AS ID,
      CT.CatchTypeCode AS CODE,
      CT.CatchType AS NAME_EN,
      NULL AS NAME_ES,
      NULL AS NAME_FR,
      CASE
        WHEN CT.CatchTypeGrp = 'Discards (OUT)' THEN 'Discards'
        ELSE CT.CatchTypeGrp
      END AS CATCH_TYPE_GROUP
    FROM
      CatchTypes CT
    ORDER BY
      CASE
        WHEN CT.CatchTypeGrp LIKE 'Catches' THEN 1
        WHEN CT.CatchTypeGrp LIKE 'Landings' THEN 2
        ELSE 3
      END,
      CT.CatchTypeCode
    "
  )

usethis::use_data(REF_CATCH_TYPES, overwrite = TRUE, compress = "gzip")

### Effort types
REF_EFFORT_TYPES =
  tabular_query(
    DB_STAT(), "
    SELECT
      EffortTypeCode AS CODE,
    	EffortType AS NAME_EN,
    	IsGearDep AS GEAR_DEPENDENT
    FROM
    	EffortTypes
    ORDER BY
    	CASE
    		WHEN EffortTypeCode <> '-none-' THEN 0
    		ELSE 1
    	END,
    	1"
  )

usethis::use_data(REF_EFFORT_TYPES, overwrite = TRUE, compress = "gzip")

### Species
REF_SPECIES =
  tabular_query(
    DB_T1(), "
    SELECT
    	SP.SpeciesID AS ID,
    	SP.Alfa3FAO AS CODE,
    	SP.ScieName AS SCIENTIFIC_NAME,
    	SP.NameUK AS NAME_EN,
    	SP.NameES AS NAME_ES,
    	SP.NameFR AS NAME_FR,
    	CASE
    		WHEN SP.Alfa3FAO IN ('BFT', 'ALB')                      THEN 'Temperate tunas'
    		WHEN SP.Alfa3FAO IN ('BET', 'YFT', 'SKJ')               THEN 'Tropical tunas'
    		WHEN SP.Alfa3FAO IN ('SWO', 'BUM', 'WHM', 'SAI', 'SPF') THEN 'Billfishes'
    		                                                        ELSE 'Other species'
    	END AS SPECIES_GROUP,
    	CASE
    		WHEN SpeciesGrp LIKE '1%'                               THEN 'Tunas and billfish (major)'
    		WHEN SpeciesGrp LIKE '2%'                               THEN 'Tunas (small)'
    		WHEN SpeciesGrp LIKE '3%'                               THEN 'Tunas (other)'
    		WHEN SpeciesGrp LIKE '4%'                               THEN 'Sharks (major)'
    		WHEN SpeciesGrp LIKE '5%'                               THEN 'Sharks (other)'
    		WHEN SpeciesGrp LIKE '7%'								                THEN 'Marine turtles'
    		WHEN SpeciesGrp LIKE '8%'							                	THEN 'Seabirds'
    		WHEN SpeciesGrp LIKE '9%'						                		THEN 'Cetaceans and marine mammals'
    		                                                        ELSE 'Other species'
    	END AS SPECIES_GROUP_ICCAT,
    	SP.StockBoundID AS STOCK_BOUNDARY_ID
    FROM
    	Species SP
    WHERE
    	SpeciesGrp <> 'DELETE' AND
    ( TAXOCODE IS NOT NULL OR SP.Alfa3FAO = 'DOL' ) -- Dolphinfish has currently a NULL taxocode in the Species table, but we want to keep it
    ORDER BY
    	LEFT(SP.SpeciesGrp, 1),
    	SP.SpeciesID
    "
  )

usethis::use_data(REF_SPECIES, overwrite = TRUE, compress = "gzip")

### Stocks metadata
REF_STOCKS =
  tabular_query(
    DB_GIS(), "
    SELECT
    	S.SPECIES_CODE,
    	CASE WHEN S.CODE = 'OTH' THEN '--' ELSE S.CODE END          AS STOCK_CODE,
    	COALESCE(S2ST.STATISTICAL_AREA_CODE, '--')                  AS STATISTICAL_AREA_CODE,
    	COALESCE(ST2SA.SAMPLING_AREA_CODE, S2SA.SAMPLING_AREA_CODE) AS SAMPLING_AREA_CODE
    FROM
    	STOCKS S
    LEFT JOIN
    	STOCKS_TO_STATISTICAL_AREAS S2ST
    ON
    	S2ST.STOCK_CODE = S.CODE
    LEFT JOIN
    	STOCKS_TO_SAMPLING_AREAS S2SA
    ON
    	S2ST.STATISTICAL_AREA_CODE IS NULL AND
    	S2SA.STOCK_CODE = S.CODE
    LEFT JOIN
    	STATISTICAL_TO_SAMPLING_AREAS ST2SA
    ON
    	S2ST.STATISTICAL_AREA_CODE IS NOT NULL AND
    	S2ST.STATISTICAL_AREA_CODE = ST2SA.STATISTICAL_AREA_CODE
    ORDER BY
      CASE
        WHEN S.SPECIES_CODE = 'BFT' THEN 1
        WHEN S.SPECIES_CODE = 'ALB' THEN 2
        WHEN S.SPECIES_CODE = 'BET' THEN 3
        WHEN S.SPECIES_CODE = 'YFT' THEN 4
        WHEN S.SPECIES_CODE = 'SKJ' THEN 5
        WHEN S.SPECIES_CODE = 'SWO' THEN 6
        WHEN S.SPECIES_CODE = 'BUM' THEN 7
        WHEN S.SPECIES_CODE = 'WHM' THEN 8
        WHEN S.SPECIES_CODE = 'SAI' THEN 9
        WHEN S.SPECIES_CODE = 'SPF' THEN 10
        ELSE 11
      END ASC
    "
  )

REF_STOCKS =
  merge(REF_STOCKS, REF_SPECIES,
        by.x = "SPECIES_CODE", by.y = "CODE",
        all.x = TRUE)[, .(SPECIES_ID = ID,
                          SPECIES_CODE,
                          SPECIES_GROUP,
                          STOCK_CODE,
                          STATISTICAL_AREA_CODE,
                          SAMPLING_AREA_CODE)]

usethis::use_data(REF_STOCKS, overwrite = TRUE, compress = "gzip")

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
      1, 2
    "
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
      GearID_fstat -- GearGrpID (for logical ordering) -- GearGrpCode (for lexical ordering)
    "
)

REF_GEAR_GROUPS = rbind(REF_GEAR_GROUPS, data.table(CODE = "OT", NAME_EN = "Other gears"))

usethis::use_data(REF_GEAR_GROUPS, overwrite = TRUE, compress = "gzip")

### Gears
REF_GEARS =
  tabular_query(
    DB_STAT(), "
    SELECT
        G.GearCode AS CODE,
    	GG.GearGrpCode AS GEAR_GROUP_CODE,
    	G.Gear AS NAME_EN,
    	G.Discards AS DISCARDS
    FROM
        [dbo].Gears G
    INNER JOIN
    	[dbo].GearGroups GG
    ON
    	G.GearGrpID = GG.GearGrpID
    ORDER BY
    	GG.GearID_fstat,
    	G.GearCode
    "
  )

usethis::use_data(REF_GEARS, overwrite = TRUE, compress = "gzip")

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
      2
    "
  )

usethis::use_data(REF_FLAGS, overwrite = TRUE, compress = "gzip")

### Fleets
REF_FLEETS =
  tabular_query(
    DB_STAT(), "
    SELECT
      F.FleetID AS ID,
      F.FleetCode AS CODE,
    	FL.FlagCode AS FLAG_CODE,
    	F.FlagOfVesselCode AS VESSEL_FLAG_CODE,
    	F.FleetName AS NAME_EN,
    	CASE WHEN [Status] = 'DELETE' THEN 1 ELSE 0 END AS DEPRECATED
    FROM
    	Fleets F
    LEFT JOIN
    	Flags FL
    ON
    	F.RepFlagID = FL.FlagID
    ORDER BY
    	4 -- NAME_EN"
  )

usethis::use_data(REF_FLEETS, overwrite = TRUE, compress = "gzip")

### Time periods
REF_TIME_PERIODS =
  tabular_query(
    DB_STAT(), "
    SELECT
      TimePeriodID AS CODE,
      TimePeriodGroup AS TIME_PERIOD_GROUP_CODE,
      TimePeriod AS NAME_EN
    FROM
      dbSTAT.dbo.TimePeriods
    ORDER BY
      TimePeriodGroup, 1 ASC"
  )

usethis::use_data(REF_TIME_PERIODS, overwrite = TRUE, compress = "gzip")

### Time period groups
REF_TIME_PERIOD_GROUPS =
  tabular_query(
    DB_STAT(), "
    SELECT DISTINCT
      TimePeriodGroup AS CODE,
      TPeriodDescrip AS NAME_EN
    FROM
      dbSTAT.dbo.TimePeriods
    ORDER BY
      1 ASC"
  )

usethis::use_data(REF_TIME_PERIOD_GROUPS, overwrite = TRUE, compress = "gzip")

### Square types
REF_SQUARE_TYPES =
  tabular_query(
    DB_STAT(), "
    SELECT
      SquareTypeCode AS CODE,
    	KSquareDescrip AS NAME_EN,
    	CASE WHEN [Status] = 'descontinued' THEN 1 ELSE 0 END AS DEPRECATED
    FROM
    	SquareTypes
    ORDER BY
    	CASE
    		WHEN SquareTypeCode = 'LatLon' THEN 0
    		WHEN SquareTypeCode =    '1x1' THEN 10
    		WHEN SquareTypeCode =    '5x5' THEN 11
    		WHEN SquareTypeCode =  '10x10' THEN 12
    		WHEN SquareTypeCode =  '20x20' THEN 13
    		WHEN SquareTypeCode =   '5x10' THEN 14
    		WHEN SquareTypeCode =  '10x20' THEN 15
    		WHEN SquareTypeCode =  'Stock' THEN 20
    		WHEN SquareTypeCode =  'ICCAT' THEN 40
    		WHEN SquareTypeCode =   'BFWG' THEN 50
    		ELSE 100
    	END,
    	2"
  )

usethis::use_data(REF_SQUARE_TYPES, overwrite = TRUE, compress = "gzip")
