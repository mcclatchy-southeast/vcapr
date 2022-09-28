
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vcapr

<!-- badges: start -->
<!-- badges: end -->

An R package to efficiently import and parse data extracts from the N.C.
Administrative Office of the Courts VCAP system for civil court data.

## Installation

You can install the development version of vcapr from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mcclatchy-southeast/vcapr")
```

## Usage

``` r
# load the package
library(vcapr)

# import, parse and write a single file to a destination directory
# change this to wherever the raw files are stored on your machine
# and where you want to the separated files to be saved
process_results <- processCivilFile('/vcap/NOBC0001', '/vcap/tables/')
#> ...STARTING FILE IMPORT AT 22:00:51 
#> x  ERROR: FILE DOES NOT EXIST.

# loop through a series of files
# change this to wherever the raw files are stored on your machine
# and where you want to the separated files to be saved
# TODO Add a function like this to get a directory
#
# create a list of filenames
files <- c('/vcap/NOBC0001',
           '/vcap/NOBC0002',
           '/vcap/NOBC0003'
)
# loop through the filenames, processing each and producing a results file
for(file in files){
  if(!exists('process_results')){
    process_results <- processCivilFile(file, '~/Dropbox/projects/newsobserver/sfr_investors/data/aoc/2022/upload_test/')
  }
  else{
    process_results <- rbind(
      process_results,
      processCivilFile(file, '~/Dropbox/projects/newsobserver/sfr_investors/data/aoc/2022/upload_test/')
    )
  }
}
#> ...STARTING FILE IMPORT AT 22:00:51 
#> x  ERROR: FILE DOES NOT EXIST.
#> ...STARTING FILE IMPORT AT 22:00:51 
#> x  ERROR: FILE DOES NOT EXIST.
#> ...STARTING FILE IMPORT AT 22:00:51 
#> x  ERROR: FILE DOES NOT EXIST.
```

## Background

Data from the N.C. Administrative Office of the Courts is provided via
public records request in a 5-year “extract” every six months. The
agency exports its database into a sequential series of fixed-width 2.1
GB files made up of data from several tables.

Those tables fall into one of three categories:

-   Cases records
-   Abstract records
-   Support records

Each of these three record categories has a number of associated record
types, identified by a two-digit number that corresponds with a layout
described [in the provided data
dictionary](https://www.documentcloud.org/documents/23070366-nc-aoc-vcap-extract-file-layout).

This document, provided by the AOC, was manually translated into a CSV
preloaded into the package.

### Preprocessing

A small number of rows in the AOC data appear to contain embedded nulls,
non-UTF characters that R seems to interpret as line breaks. These
appear in text editors as `<0x00>` characters, and are discoverable via
`grep`.

``` bash
grep '\x0' NOBC0004raw
```

Because they’re interpreted as line breaks, they incorrectly increase
the number of rows and make the resulting broken lines impossible to
parse automatically.

To fix these embedded nulls, we can replace them with a space using a
`perl` command in Terminal.

``` bash
perl -pe 's/\0/ /g' < NOBC0017 > NOBC0017fix
```

The vcapr package attempts to catch other encoding issues and correct
them during parsing.

h/t to [Michael Toren](https://twitter.com/michael_toren) for the assist
with this issue via the NICAR listserv.

## Other/old functions

In the process of moving away from these after refactoring. So consider
everything below deprecated.

``` r
# load the package
library(vcapr)

# import, parse and write a single file
processCivilFile('/vcap/NOBC0001', 'vcap/tables/')
#> ...STARTING FILE IMPORT AT 22:00:51 
#> x  ERROR: FILE DOES NOT EXIST.
#> # A tibble: 0 × 4
#> # … with 4 variables: file_name <chr>, table_name <chr>, rows <dbl>,
#> #   parse_seconds <dbl>

#load all case record data from the civil extract into one dataframe
all_tables <- importFiles('c', civil_data_dict, 'path/to/raw/vcap/files/')
#> ...STARTING FILE IMPORT AT 22:00:51 
#> x  ERROR: DIRECTORY DOES NOT EXIST.

#examine the data dicionary
head(civil_data_dict)
#> # A tibble: 6 × 10
#>   table_type table_code table…¹ col_n…² type  null_…³ descr…⁴ start   end length
#>   <chr>      <chr>      <chr>   <chr>   <chr> <chr>   <chr>   <int> <int>  <int>
#> 1 case       NOBC       00      cntyno  <NA>  NOT NU… County…     1     3      3
#> 2 case       NOBC       00      v2      <NA>  NOT NU… unknown     4     6      3
#> 3 case       NOBC       00      rectype <NA>  NOT NU… Record…     7     8      2
#> 4 case       NOBC       00      caseno  <NA>  NOT NU… Case F…     9    19     11
#> 5 case       NOBC       00      f1      <NA>  NULL    Update…    20    24      5
#> 6 case       NOBC       28      cnty_n… CHAR… NOT NU… This f…    25    27      3
#> # … with abbreviated variable names ¹​table_id, ²​col_names, ³​null_option,
#> #   ⁴​description

#load all specifications per a specified data dictionary
all_specs <- loadAllSpecs(civil_data_dict)
#> ...TABLE LIST CREATED
#> ...COMMON SPECS CREATED
#> ...SPEC FOR NOBC28 CREATED
#> ...SPEC FOR NOBC57 CREATED
#> ...SPEC FOR NOBC58 CREATED
#> ...SPEC FOR NOBC59 CREATED
#> ...SPEC FOR NOBC53 CREATED
#> ...SPEC FOR NOBC48 CREATED
#> ...SPEC FOR NOBC55 CREATED
#> ...SPEC FOR NOBC61 CREATED
#> ...SPEC FOR NOBC65 CREATED
#> ...SPEC FOR NOBC46 CREATED
#> ...SPEC FOR NOBC47 CREATED
#> ...SPEC FOR NOBC37 CREATED
#> ...SPEC FOR NOBC29 CREATED
#> ...SPEC FOR NOBC60 CREATED
#> ...SPEC FOR NOBC23 CREATED
#> ...SPEC FOR NOBC50 CREATED
#> ...SPEC FOR NOBC27 CREATED
#> ...SPEC FOR NOBC38 CREATED
#> ...SPEC FOR NOBC21 CREATED
#> ...SPEC FOR NOBC71 CREATED
#> ...SPEC FOR NOBC72 CREATED
#> ...SPEC FOR NOBC73 CREATED
#> ...SPEC FOR NOBC74 CREATED
#> ...SPEC FOR NOBC17 CREATED
#> ...SPEC FOR NOBC22 CREATED
#> ...SPEC FOR NOBC24 CREATED
#> ...SPEC FOR NOBC32 CREATED
#> ...SPEC FOR NOBC33 CREATED
#> ...SPEC FOR NOBC69 CREATED
#> ...SPEC FOR NOBC70 CREATED
#> ...SPEC FOR NOBC36 CREATED
#> ...SPEC FOR NOBC03 CREATED
#> ...SPEC FOR NOBA04 CREATED
#> ...SPEC FOR NOBA03 CREATED
#> ...SPEC FOR NOBA36 CREATED
#> ...SPEC FOR NOBA21 CREATED
#> ...SPEC FOR NOBA05 CREATED
#> ...SPEC FOR NOBA37 CREATED
#> ...SPEC FOR NOBA06 CREATED
#> ...SPEC FOR NOBA07 CREATED
#> ...SPEC FOR NOBA08 CREATED
#> ...SPEC FOR NOBA09 CREATED
#> ...SPEC FOR NOBA10 CREATED
#> ...SPEC FOR NOBA11 CREATED
#> ...SPEC FOR NOBA12 CREATED
#> ...SPEC FOR NOBA13 CREATED
#> ...SPEC FOR NOBA14 CREATED
#> ...SPEC FOR NOBA20 CREATED
#> ...SPEC FOR NOBA15 CREATED
#> ...SPEC FOR NOBA16 CREATED
#> ...SPEC FOR NOBA18 CREATED
#> ...SPEC FOR NOBA19 CREATED
#> ...SPEC FOR NOBS26 CREATED
#> ...SPEC FOR NOBS37 CREATED
#> ...SPEC FOR NOBS25 CREATED
#> ...SPEC FOR NOBS42 CREATED
#> ...SPEC FOR NOBS10 CREATED
#> ...ALL SPECS LOADED
#> ...SPEC LOAD COMPLETE. ELAPSED TIME: 2.298 seconds

#load relevant tables from civil data
issue_type <- loadCivilTable('../../aoc/2022/sep/NOBC23', all_specs)
#> x  ERROR: ../../aoc/2022/sep/NOBC23 DOES NOT EXIST
party_names <- loadCivilTable('../../aoc/2022/sep/NOBC48', all_specs)
#> x  ERROR: ../../aoc/2022/sep/NOBC48 DOES NOT EXIST
```

<!--You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/v1/examples>.\-->
