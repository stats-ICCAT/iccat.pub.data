# ICCAT `data` `public` library

A set of data-specific functions providing ways to manipulate some of the core ICCAT data artifacts (assuming these are available to the consumers) 
and including several data tables containing all ICCAT key reference data.  

This library is meant for public usage, and for this reason it does not have dependencies from the (development) ICCAT libraries that provide access to the databases.
Nevertheless, the script (not exported with the library) that updates the reference data tables comes indeed with a direct dependency from the [iccat.dev.base](https://github.com/stats-ICCAT/iccat.dev.base) library. 

## Artifacts that can be manipulated using the dataset-specific functions provided by the library

1) Task1 nominal catches
  + The library provides a function that can summarize (in _wide_ tabular format) the original tabular T1NC data as retrieved using the [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) library.

2) SCRS catalogue 
  + The library provides functions to **build** the SCRS catalogue using fishery ranks and base catalogue data as retrieved using the [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) library, as well as a utility method to split the final output in multiple tables
  
3) Species' stock data and metadata
  + The library provides functions to extract stock metadata and summary information for one or more species
  
## Reference data artifacts exported by the library <a name="reference_data"></a>

Each of the following artifacts (hereby referenced by their object name) represents the content (as an R `data.table`) of a reference data table included in one of the ICCAT databases (generally, `DATABASE_T1`) with standardized column names.

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

Each `REF_xyz` object should be properly described within the [`R\data.R`](https://github.com/stats-ICCAT/iccat.pub.data/blob/main/R/data.R) file and explicitly exported to be visible to the library consumers.

E.g.: 

![image](https://github.com/user-attachments/assets/b07e8a37-1e28-4da4-bfae-e83cb46274f8)

> See each exported item for its description and structure

## External dependencies (CRAN) <a name="external_deps"></a>
+ `data.table`
+ `dplyr`

### Installation
```R
install.packages(c("data.table", "dplyr", "stringr"))
```

## Internal dependencies <a name="internal_deps"></a>
+ [iccat.dev.base](https://github.com/stats-ICCAT/iccat.dev.base) [`OPTIONAL`]
+ [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) [`OPTIONAL`]

These dependencies are only required if we need to update the reference data. In this case, please ensure to follow the steps for the installation of all internal / external requirements for the `iccat.dev.data` and `iccat.dev.base` libraries as available [here](https://github.com/stats-ICCAT/iccat.dev.data/?tab=readme-ov-file#external-dependencies-cran-).

### Installation (straight from GitHub)
```R
library(devtools)

# To get a GitHub auth token: https://github.com/settings/tokens (ensure that the 'repo' permissions are assigned to the token)
GITHUB_AUTH_TOKEN = < put your GitHub authentication token here >

install_github("stats-ICCAT/iccat.dev.base", dependencies = TRUE, auth_token = GITHUB_AUTH_TOKEN)
install_github("stats-ICCAT/iccat.dev.data", dependencies = TRUE, auth_token = GITHUB_AUTH_TOKEN)
```

# Updating the reference data
This repository also includes a script ([`data-raw\initialize_reference_data.R`](https://github.com/stats-ICCAT/iccat.pub.data/blob/main/data-raw/initialize_reference_data.R)) which takes care - when explicitly executed - of extracting reference data from the standard ICCAT databases and update the exported [reference data objects](#reference_data).
The script is **not** exported with the library, requires loading the `iccat.dev.base` library, and can be run only by users that have read access to the ICCAT databases.

This script needs to be extended every time a new reference data is added to the list, and the [`R\data.R`](https://github.com/stats-ICCAT/iccat.pub.data/blob/main/R/data.R) script should then be updated accordingly, to include the new object to be exported, and describe its content.

Updates to the reference data shall be performed *before* building the library, otherwise the updated artifacts will not be included in the package.

# Building the library

Assuming that all [external](#external_deps) and [internal](#internal_deps) dependencies are already installed in the R environment, and that the `devtools` package and [RTools](https://cran.r-project.org/bin/windows/Rtools/) are both available, the building process can be either started within R studio by selecting the Build > Build Source Package menu entry:

![image](https://github.com/user-attachments/assets/f209d8d4-568c-4200-bcf2-fb1fa0e1d2ef)

or by executing the following statement:

`devtools::document(roclets = c('rd', 'collate', 'namespace'))`

## Usage examples

### Loading the library

For the examples to work, the following statement should be executed only once per session:

```R
library(iccat.pub.data)
```

### T1NC

> To run these examples we assume that the `T1NC` object contains all T1NC data as retrieved using the `iccat.dev.data::t1nc` function.

#### Producing a T1NC data summary by species, fleet, and gear
```R
# T1NC = t1nc() # Requires access to the iccat.dev.data library

T1NC_summary = t1nc.summarise(T1NC, by_species = TRUE, by_gear = TRUE, by_stock = FALSE, by_catch_type = FALSE)
```
```R
> View(T1NC_summary$grouped)
```
![image](https://github.com/user-attachments/assets/469dc26d-50f5-4077-b457-a880d2b1c722)
#### Producing a T1NC data summary for Albacore tuna by stock and fleet only, including catch ranks (absolute and cumulative) for each stratum since 1994 (included) 
```R
# T1NC = t1nc() # Requires access to the iccat.dev.data library

T1NC_summary_ALB = t1nc.summarise(T1NC[Species == "ALB"], year_min = 1994, by_species = FALSE, by_gear = FALSE, by_stock = TRUE, by_catch_type = FALSE, rank = TRUE)
```
```R
> View(T1NC_summary_ALB$grouped)
```
![image](https://github.com/user-attachments/assets/511fa695-9407-4fed-809d-d81fddd03ae0)

### T1 + T2 SCRS catalogue

> To run these examples we assume that the `FR` and `CA` objects contain fishery ranks and base catalogue data as retrieved using the `iccat.dev.data::catalogue.fn_getT1NC_fisheryRanks` and `iccat.dev.data::catalogue.fn_genT1NC_CatalSCRS` functions, respectively.

#### Producing the T1 + T2 SCRS catalogue for all species from 1950 onwards
```R
# FR = catalogue.fn_getT1NC_fisheryRanks() # Requires access to the iccat.dev.data library
# CA = catalogue.fn_genT1NC_CatalSCRS()    # Requires access to the iccat.dev.data library

CAT = catalogue.compile(FR, CA, year_from = 1950) 
```
```R
> View(CAT)
```
![image](https://github.com/user-attachments/assets/542894bf-b258-44a6-807a-aec510b37afc)

#### Producing the T1 + T2 SCRS catalogue for all species from 1994 onwards
```R
# FR = catalogue.fn_getT1NC_fisheryRanks(species_codes = "ALB") # Requires access to the iccat.dev.data library
# CA = catalogue.fn_genT1NC_CatalSCRS(species_codes = "ALB")    # Requires access to the iccat.dev.data library

CAT_ALB_1994 = catalogue.compile(FR, CA, year_from = 1994) 
```
```R
> View(CAT_ALB_1994)
```
![image](https://github.com/user-attachments/assets/b798dc27-25e1-47dc-a5d9-91b65e38c67f)

## Future extensions
+ [ ] ensure that the explicit external dependency from `dplyr` is really needed
+ [ ] change the `t1nc.summarise` function to explicitly include / exclude flag data from the stratification (now it's always included)
