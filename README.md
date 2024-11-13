# ICCAT `data` `public` library

A set of data-specific functions providing ways to manipulate some of the core ICCAT data artifacts (assuming these are available to the consumers) 
and including several data tables containing all ICCAT key reference data.  

This library is meant for public usage, and for this reason it does not have dependencies from the (development) ICCAT libraries that provide access to the databases.
Nevertheless, the script (not exported with the library) that updates the reference data tables comes indeed with a direct dependency from the [iccat.dev.base](https://github.com/stats-ICCAT/iccat.dev.base) library. 

## Artifacts that can be manipulated using the dataset-specific functions provided by the library

1) T1NC - Task1 nominal catches
  + The library provides a function that can summarize (in wide format) the original tabular T1NC data as retrieved using the [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) library.

2) T1 & T2 - SCRS catalogue 
  + The library provides functions to **build** the SCRS catalogue using fishery ranks and base catalogue data as retrieved using the [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) library, as well as a utility method to split the final output
  
3) Species' stock data and metadata
  + The library provides functions to extract stock metadata and summary information for one or more species
  
## Reference data artifacts exported by the library (see each exported item for its description and structure)

+ `REF_DATA_SOURCES`
+ `REF_DATA_SOURCE_CONTENTS`
+ `REF_TIME_PERIODS`
+ `REF_TIME_PERIOD_GROUPS`
+ `REF_PARTIES`
+ `REF_PARTY_STATUS`
+ `REF_FLAGS`
+ `REF_FLEETS`
+ `REF_SQUARE_TYPES` (**deprecated**)
+ `REF_FISHING_ZONES`
+ `REF_AREAS`
+ `REF_SAMPLING_AREAS`
+ `REF_QUALITY_LEVELS`
+ `REF_GEAR_GROUPS`
+ `REF_GEARS`
+ `REF_SPECIES_GEAR_GROUPS`
+ `REF_EFFORT_TYPES`
+ `REF_CATCH_TYPES`
+ `REF_SPECIES`
+ `REF_SPECIES_META`
+ `REF_STOCKS`
+ `REF_STOCK_AREAS`
+ `REF_STOCK_AREAS_SIMPLIFIED`
+ `REF_PRODUCT_TYPES`
+ `REF_SAMPLING_UNITS`
+ `REF_SAMPLING_LOCATIONS`
+ `REF_FREQUENCY_TYPES`
+ `REF_SIZE_CLASS_LIMITS`

## External dependencies (CRAN) <a name="external_deps"></a>
+ `data.table`
+ `dplyr`

### Installation
```
install.packages(c("data.table", "dplyr", "stringr"))
```

## Internal dependencies <a name="internal_deps"></a>
+ [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) 

This dependency is only required if we need to update the reference data (but not to use the library by itself). 
In this case, please ensure to follow the steps for the installation of all internal / external requirements for the `iccat.dev.data` library as available [here](https://github.com/stats-ICCAT/iccat.dev.data/edit/main/README.md#external-dependencies-cran-).

### Installation (straight from GitHub)
```
library(devtools)

install_github("stats-ICCAT/iccat.dev.data")
```

> As the `iccat.dev.*` repositories are private, when installing `iccat.dev.base` you might be prompted to provide your GitHub credentials for a user that has read access to the repo. These will be stored in the R environment and won't be required for subsequent installations

# Building the library

Assuming that all [external](#external_deps) and [internal](#internal_deps) dependencies are already installed in the R environment, and that the `devtools` package and [RTools](https://cran.r-project.org/bin/windows/Rtools/) are both available, the building process can be either started within R studio by selecting the Build > Build Source Package menu entry:

![image](https://github.com/user-attachments/assets/f209d8d4-568c-4200-bcf2-fb1fa0e1d2ef)

or by executing the following statement:

`devtools::document(roclets = c('rd', 'collate', 'namespace'))`

## Usage examples

### Loading the library

For the examples to work, the following statement should be executed only once per session:

```
library(iccat.dev.data)
```

> The R session should run on a machine that has direct access to the ICCAT database servers, and by a user that has trusted credentials (i.e., a Windows login) allowing access to the specific databases and schemata in read-only mode.

### T1NC

#### Producing the default T1NC Excel output for retained catches and dead discards only (all species, years from 1950 onwards)
```
t1nc.export(species_codes = NULL)
```
> Exceuting the above statement will create a file named `t1nc-ALL_YYYYMMDD.xlsx` in the current directory

#### Producing the default T1NC Excel output for live discards only (all species, years from 1950 onwards)
```
t1nc.export(species_codes = NULL, exclude_discarded_live = FALSE, out_filename_prefix = "t1nc-DL-")
```
> Executing the above statement will create a file named `t1nc-DL-ALL_< YYYYMMDD >.xlsx` in the current directory.
> If no `output_filename_prefix` is specified, then the name of the output file will automatically be set to `t1nc-ALL_< YYYYMMDD >.xlsx`

#### Extracting T1NC retained catches and dead discards data for Albacore tuna (entire time series) 
```
t1nc_ALB = t1nc(species_codes = "ALB")
```
#### Exporting T1NC retained catches and dead discards data for Albacore tuna (entire time series) in a customly-named Excel file 
```
t1nc.export(species_codes = "ALB", overridden_filename = "t1nc-ALB.xlsx")
```
> Executing the above statement will create a file named `t1nc-ALB.xlsx` in the current directory

#### Extracting T1NC retained catches and dead discards data for Albacore tuna, reported for years between 2010 and 2020 by longline gears only)  
```  
t1nc_alb_2010_2020_LL = t1nc(species_codes = "ALB", year_min = 2010)[YearC <= 2020 & GearGrp == "LL"]
```
#### Extracting T1NC live discards data for Albacore tuna reported for years from 2010 onwards
```
t1nc_alb_ld = t1nc(species_codes = "ALB", year_min = 2010, exclude_discarded_live = FALSE)
```
#### Extracting T1NC live discards data for Albacore tuna reported for years from 2010 onwards and stored in a T1 database hosted on server *test_db_server*
```
t1nc_alb_ld = t1nc(species_codes = "ALB", year_min = 2010, exclude_discarded_live = FALSE, db_connection = DB_T1(server = "test_db_server"))
```

### T2CE

#### Extracting T2CE catch and effort data for all species (entire time series) 
```
t2ce_all = t2ce()
```
#### Extracting T2CE catch and effort data for all billfish species reported for years from 2010 onwards
```
t2ce_billfish_2010 = t2ce(species_family = "Istiophoridae", year_min = 2010)
```

### T2SZ

#### Extracting T2 ***observed*** bluefin tuna size samples reported for years between 2000 and 2009 (included)
```
t2sz_bft = t2sz(species_codes = "BFT", year_min = 2000, year_max = 2009, type_of_records = T2SZ_SIZE)
``` 
#### Exporting T2 ***observed*** bluefin tuna size samples (entire time series) in a customly-named, gzipped  CSV file 
```
t2sz.export(species_codes = "BFT", type_of_records = T2SZ_SIZE, overridden_filename = "t2sz-BFT")
```
> Executing the above statement will create a file named `t2sz-BFT.xlsx` in the current directory

### T2CS

#### Extracting T2 ***estimated*** bluefin tuna catch-at-size reported for years between 2000 and 2009 (included)
```
t2sz_bft = t2sz(species_codes = "BFT", year_min = 2000, year_max = 2009, type_of_records = T2SZ_SIZE)
``` 
#### Exporting T2 ***estimated*** bluefin tuna catch-at-size (entire time series) in a customly-named, gzipped CSV file 
```
t2sz.export(species_codes = "BFT", type_of_records = T2SZ_CAS, overridden_filename = "t2cs-BFT")
```
> Executing the above statement will create a file named `t2cs-BFT.csv.gz` in the current directory

### T2SZ+T2CS

#### Extracting a detailed catalogue of T2 **observed** size samples and T2 ***estimated*** bluefin tuna catch-at-size reported for years from 2009 onwards
```
t2sz_cs_bft = t2sz_cs(species_codes = "BFT", year_min = 2009)
```
#### Extracting a detailed catalogue of T2 **observed** size samples and T2 ***estimated*** billfish catch-at-size (entire time series)
```
t2sz_cs_bill = t2sz_cs(species_family = "Istiophoridae")
```
#### Exporting a detailed catalogue of T2 **observed** size samples and T2 ***estimated*** billfish catch-at-size (entire time series)
```
t2sz_cs.export(species_family = "Istiophoridae")
```
> Executing the above statement will create a file named `t2sz+cs-ALL-Istiophoridae_<yyyyMMdd>.xlsx` in the current directory

### SCRS catalogues

#### Producing a data table for the SCRS catalogue for Albacore tuna (Mediterranean stock) for all years from 1994 onwards

```
cat_alb_1994 = catalogue(species_codes = "ALB", stock_area_codes = "MED", year_from = 1994)
```
> This artifact **is not** the final SCRS catalogue generally disseminated in Excel format at each working group / SCRS session, but rather an internal representation of the data necessary to produce the final output (via functions exported by the [iccat.pub.viz](https://github.com/stats-ICCAT/iccat.pub.viz) package).

### CATDIS data

#### Extracting Albacore and Bluefin tuna CATDIS data for all years from 1994 onwards
```
catdis_alb_bft_1994 = catdis(c("ALB", "BFT"), year_min = 1994)
```

#### Producing the standard CATDIS CSV file for all years and species (among those for which CATDIS data are available), and saving it with the `CATDIS_all.csv` name in gzipped format
```
catdis.export(overridden_filename = "CATDIS_all.csv", gzipped = TRUE)
```
> Executing the above statement will create a file named `CATDIS_all.csv.gz` in the current directory

### Statistical data export

#### ST01 - Processing and exporting data (fishing craft statistics) as reported by EU-Spain for the year 2023

```
### ST01A (ICCAT registered vessels)

# Extracts ST01A fisheries data for vessels reported by EU-Spain for the year 2023
ST01A_F = ST01A.load_data_fisheries(reporting_flag = "EU-ESP", year_from = 2023, year_to = 2023)

# Extracts ST01A data for vessels reported by EU-Spain for the year 2023
ST01A_V = ST01A.load_data_vessels(reporting_flag = "EU-ESP", year_from = 2023, year_to = 2023)

# Further filters the fisheries and vessels data above and produces a *wide* version of the combined data
ST01A = ST01A.filter_data(ST01A_data_vessels = ST01A_V, ST01A_data_fisheries = ST01A_F, reporting_flag = "EU-ESP", year_from = 2023, year_to = 2023)

### ST01B (artisanal vessels)

# Extracts ST01B fisheries data for vessels reported by EU-Spain for the year 2023
ST01B_F = ST01B.load_data_fisheries(reporting_flag = "EU-ESP", year_from = 2023, year_to = 2023)

# Extracts ST01B data for vessels reported by EU-Spain for the year 2023
ST01B_V = ST01B.load_data_vessels(reporting_flag = "EU-ESP", year_from = 2023, year_to = 2023)

# Further filters the fisheries and vessels data above and produces a *wide* version of the combined data
ST01B = ST01B.filter_data(ST01B_data_vessels = ST01B_V, ST01B_data_fisheries = ST01B_F, reporting_flag = "EU-ESP", year_from = 2023, year_to = 2023)

# Exports the extracted information in a standard ST01 form
ST01.export(ST01A_filtered_data = ST01A, ST01B_filtered_data = ST01B,
            # Optional
            statistical_correspondent = list(
                # Optional, to be set to the actual first name & last name of the person that wants to produce a pre-loaded form ST01 on his / her name
                name = "Firstname Lastname", 
                # Optional, same consideration as above 
                email = "foo@bar.com",
                # Optional, same consideration as above
                phone = "+0123456789",
                # Optional, same consideration as above
                institution = "Dummy institution",
                # Optional, same consideration as above
                department = "Dummy department",
                # Optional, same consideration as above
                address = "Dummy address",
                # Optional, same consideration as above
                country = "EU-ESP" 
            ),
            version_reported = "Final", # To specify the version of the data that the exported form contains
            content_type = "Revision (full)", # To specify the type of content that the exported form contains
            reporting_flag = "EU-ESP",
            year_from = 2023,
            year_to = 2023,
            destination_file = "ST01_EU-ESP_2023.xlsx"
)
```
> Executing the above statements will create a file named `ST01_EU-ESP_2023.xlsx` in the current directory

#### ST02 - Processing and exporting data (nominal catch statistics) as reported by EU-Spain for the years 2020-2023

```
### ST02 (nominal catches)

# Extracts ST02 nominal catch data reported by EU-Spain for the year 2020-2023
ST02 = ST02.load_data(reporting_flag = "EU-ESP", year_from = 2020, year_to = 2023)

# Further filters the nominal catch data above and produces a *wide* version of the original data
ST02_F = ST02.filter_data(ST02, reporting_flag = "EU-ESP", year_from = 2020, year_to = 2023)

# Exports the extracted information in a standard ST02 form
ST02.export(ST02_filtered_data = ST02_F,
            # Optional
            statistical_correspondent = list(
              # Optional, to be set to the actual first name & last name of the person that wants to produce a pre-loaded form ST01 on his / her name
              name = "Firstname Lastname", 
              # Optional, same consideration as above 
              email = "foo@bar.com",
              # Optional, same consideration as above
              phone = "+0123456789",
              # Optional, same consideration as above
              institution = "Dummy institution",
              # Optional, same consideration as above
              department = "Dummy department",
              # Optional, same consideration as above
              address = "Dummy address",
              # Optional, same consideration as above
              country = "EU-ESP" 
            ),
            version_reported = "Final", # To specify the version of the data that the exported form contains
            content_type = "Revision (full)", # To specify the type of content that the exported form contains
            reporting_flag = "EU-ESP",
            year_from = 2023,
            year_to = 2023,
            destination_file = "ST02_EU-ESP_2020-2023.xlsx"
)
```
> Executing the above statement will create a file named `ST02_EU-ESP_2020-2023.xlsx` in the current directory

#### ST03 - Processing and exporting data (nominal catch statistics) as collected by EU-Spain through logbooks and reported for the years 2020-2023

```
### ST03 (catch and effort)

# Extracts ST03 effort data collected by EU-Spain through logbooks and reported for the years 2020-2023
ST03_EF = ST03.load_data_EF(reporting_flag = "EU-ESP", year_from = 2020, year_to = 2023, data_source = "C.LB")

# Extracts ST03 catch data collected by EU-Spain through logbooks and reported for the years 2020-2023
ST03_CA = ST03.load_data_CA(reporting_flag = "EU-ESP", year_from = 2020, year_to = 2023, data_source = "C.LB")

# Further filters the catch and effort data above and produces a *wide* version of the combined data
ST03_CE = ST03.filter_data_CE(ST03_data_EF = ST03_EF, ST03_data_CA = ST03_CA, 
                              reporting_flag = "EU-ESP", year_from = 2020, year_to = 2023,
                              data_source = "C.LB")

# Exports the extracted information in a standard ST03 form
ST03.export(ST03_filtered_data = ST03_CE, 
            # Optional
            statistical_correspondent = list(
              # Optional, to be set to the actual first name & last name of the person that wants to produce a pre-loaded form ST01 on his / her name
              name = "Firstname Lastname", 
              # Optional, same consideration as above 
              email = "foo@bar.com",
              # Optional, same consideration as above
              phone = "+0123456789",
              # Optional, same consideration as above
              institution = "Dummy institution",
              # Optional, same consideration as above
              department = "Dummy department",
              # Optional, same consideration as above
              address = "Dummy address",
              # Optional, same consideration as above
              country = "EU-ESP" 
            ),
            version_reported = "Final", # To specify the version of the data that the exported form contains
            content_type = "Revision (full)", # To specify the type of content that the exported form contains
            reporting_flag = "EU-ESP",
            year_from = 2020,
            year_to = 2023,
            data_source = "C.LB",
            destination_file = "ST03_EU-ESP_2020-2023-LB.xlsx"
)
```
> Executing the above statements will create a file named `ST03_EU-ESP_2020-2023-LB.xlsx` in the current directory

#### ST04 - Processing and exporting SKJ data (observed, unraised, straight fork length samples) collected by EU-Spain on an unspecified sampling location, with single trip as sampling unit, lower limit as class limit, a size interval of 1 cm, and reported for the years 2022-2023
```
### ST04 (observed size frequency)

# Extracts SKJ data (observed, unraised, straight fork length samples) collected by EU-Spain on an unspecified sampling location, with single trip as sampling unit, lower limit as class limit, a size interval of 1 cm, and reported for the years 2022-2023
ST04 = ST04.load_data(reporting_flag = "EU-ESP", year_from = 2022, year_to = 2023,
                      species = "SKJ", raised = FALSE, sampling_location = "OTH", sampling_unit = "TPS", frequency_type = "SFL", class_limit = "LL", size_interval = 1)

# Further filters the samples data above and produces a *wide* version
ST04_F = ST04.filter_data(ST04_data = ST04, reporting_flag = "EU-ESP", year_from = 2022, year_to = 2023,
                          species = "SKJ", raised = FALSE, sampling_location = "OTH", sampling_unit = "TPS", frequency_type = "SFL", class_limit = "LL", size_interval = 1)

# Exports the extracted information in a standard ST04 form
ST04.export(ST04_filtered_data = ST04_F, 
            # Optional
            statistical_correspondent = list(
              # Optional, to be set to the actual first name & last name of the person that wants to produce a pre-loaded form ST01 on his / her name
              name = "Firstname Lastname", 
              # Optional, same consideration as above 
              email = "foo@bar.com",
              # Optional, same consideration as above
              phone = "+0123456789",
              # Optional, same consideration as above
              institution = "Dummy institution",
              # Optional, same consideration as above
              department = "Dummy department",
              # Optional, same consideration as above
              address = "Dummy address",
              # Optional, same consideration as above
              country = "EU-ESP" 
            ),
            version_reported = "Final", # To specify the version of the data that the exported form contains
            content_type = "Revision (full)", # To specify the type of content that the exported form contains
            reporting_flag = "EU-ESP", 
            year_from = 2022, 
            year_to = 2023,
            species = "SKJ", 
            product_type = NULL, # This information is not stored anywhere in the DB
            raised = FALSE, 
            sampling_location = "OTH", 
            sampling_unit = "TPS", 
            frequency_type = "SFL", 
            class_limit = "LL", 
            size_interval = 1,
            destination_file = "ST04_EU-ESP_2022-2023-SKJ.xlsx"
)
```
> Executing the above statements will create a file named `ST04_EU-ESP_2022-2023-SKJ.xlsx` in the current directory

#### ST05
```
## ST05 (estimated catch at size)

# Extracts SKJ data (catch at size in straight fork lengths) estimated for EU-Spain, with lower limit as class limit, a size interval of 1 cm, and reported for the years 2022-2023
ST05 = ST05.load_data(reporting_flag = "EU-ESP", year_from = 2022, year_to = 2023,
                      species = "SKJ", frequency_type = "SFL", class_limit = "LL", size_interval = 1)

# Further filters the samples data above and produces a *wide* version
ST05_F = ST05.filter_data(ST05_data = ST05, reporting_flag = "EU-ESP", year_from = 2022, year_to = 2023,
                          species = "SKJ", frequency_type = "SFL", class_limit = "LL", size_interval = 1)

# Exports the extracted information in a standard ST04 form
ST05.export(ST05_filtered_data = ST05_F, 
            # Optional
            statistical_correspondent = list(
              # Optional, to be set to the actual first name & last name of the person that wants to produce a pre-loaded form ST01 on his / her name
              name = "Firstname Lastname", 
              # Optional, same consideration as above 
              email = "foo@bar.com",
              # Optional, same consideration as above
              phone = "+0123456789",
              # Optional, same consideration as above
              institution = "Dummy institution",
              # Optional, same consideration as above
              department = "Dummy department",
              # Optional, same consideration as above
              address = "Dummy address",
              # Optional, same consideration as above
              country = "EU-ESP" 
            ),
            version_reported = "Final", # To specify the version of the data that the exported form contains
            content_type = "Revision (full)", # To specify the type of content that the exported form contains
            reporting_flag = "EU-ESP", 
            year_from = 2022, 
            year_to = 2023,
            species = "SKJ", 
            frequency_type = "SFL", 
            class_limit = "LL", 
            size_interval = 1,
            destination_file = "ST05_EU-ESP_2022-2023-SKJ.xlsx"
)
```
> Executing the above statements will create a file named `ST05_EU-ESP_2022-2023-SKJ.xlsx` in the current directory

## Future extensions
+ [ ] ensure that the explicit external dependency from `dplyr` is really needed.

+ [ ] Update `t1nc` / `t2ce` function signatures to accept a year range (`year_min` and `year_max`) rather than just the starting year (`year_min`)
+ [ ] Update `t1nc` function signature to independentyl specify if a) retained catches and dead discards and b) live discards shall be included in the output
+ [ ] Remove dependency from `openxlsx` (while keeping that from `openxlsx2`) 
+ [ ] Move all `export` functions in the ICCAT visualization library ([iccat.pub.viz](https://github.com/stats-ICCAT/iccat.pub.viz))
+ [ ] Rationalise the filtering process of all underlying datasets for the various `ST0x` functions, as it is currently done **twice**: 1) when *loading* the data from the database, and 2) when *filtering* the data and preparing the *wide* version of the output. The former is required to avoid loading the *entire* form-specific dataset all at once, whereas in the latter it is necessary to ensure that the filtering criteria (`reporting_flag`, but most of all the `year_from` and `year_to` criteria) are available to populate the form heading, and also that a full dataset (as it happens, for instance, with the interactive and REST data exporter apps) could be filtered right before exporting its content.
