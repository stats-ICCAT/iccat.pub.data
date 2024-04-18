library(iccat.dev.base)

### Species

REF_SPECIES =
  tabular_query(
    DB_T1(), "
      SELECT
        SP.Alfa3FAO AS CODE,
        SP.ScieName AS SCIENTIFIC_NAME,
        SP.NameUK AS NAME_EN,
        SP.NameFR AS NAME_FR,
        SP.NameES AS NAME_ES,
        CASE
          WHEN SP.Alfa3FAO IN ('BFT', 'ALB')                      THEN 'Temperate tunas'
          WHEN SP.Alfa3FAO IN ('BET', 'YFT', 'SKJ')               THEN 'Tropical tunas'
          WHEN SP.Alfa3FAO IN ('SWO', 'BUM', 'WHM', 'SAI', 'SPF') THEN 'Billfishes'
          ELSE 'Other species'
        END AS SPECIES_GROUP
      FROM
        [T1].[dbo].Species SP
      ORDER BY
        SP.Alfa3FAO
    "
  )

usethis::use_data(REF_SPECIES, overwrite = TRUE, compress = "gzip")

### Species metadata

REF_SPECIES_META =
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

usethis::use_data(REF_SPECIES_META, overwrite = TRUE, compress = "gzip")

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

### Stocks metadata
REF_STOCKS =
  tabular_query(
    DB_GIS(), "
    SELECT
    	S.SPECIES_CODE,
    	CASE
    		WHEN S.SPECIES_CODE IN ('BFT', 'ALB') THEN                      'Temperate tunas'
    		WHEN S.SPECIES_CODE IN ('BET', 'YFT', 'SKJ') THEN               'Tropical tunas'
    		WHEN S.SPECIES_CODE IN ('SWO', 'BUM', 'WHM', 'SAI', 'SPF') THEN 'Billfishes'
    		ELSE                                                            'Other species'
    	END                                                         AS SPECIES_GROUP,
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
      END ASC"
  )

usethis::use_data(REF_STOCKS, overwrite = TRUE, compress = "gzip")

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
