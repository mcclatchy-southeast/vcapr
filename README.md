
<!-- README.md is generated from README.Rmd. Please edit that file -->

    ____    ____  ______     ___      .______   .______      
    \   \  /   / /      |   /   \     |   _  \  |   _  \     
     \   \/   / |  ,----'  /  ^  \    |  |_)  | |  |_)  |    
      \      /  |  |      /  /_\  \   |   ___/  |      /     
       \    /   |  `----./  _____  \  |  |      |  |\  \----.
        \__/     \______/__/     \__\ | _|      | _| `._____|
                                                             

<!-- badges: start -->
<!-- badges: end -->

An R package to efficiently import and parse data extracts from the N.C.
Administrative Office of the Courts VCAP system for civil court data.

Use `vcapr` to:

-   load in raw data from the AOC civil extract (either case, abstract
    or support record types)
-   parse the data line by line according to the data layout for each
    table
-   write parse tables to CSV files for easy loading

In testing, the entire processing of loading, parsing and writing the
tables took less than 30 minutes.

## Installation

You can install the development version of `vcapr` from
[GitHub](https://github.com/) with:

``` r
# if you haven't installed devtools, uncomment the line below
# install.packages("devtools")

# install the package from GitHub
devtools::install_github("mcclatchy-southeast/vcapr")
```

## Usage

After installation, you can load the library like any other package.

``` r
# load the package
library(vcapr)

# examine the data dictionary
head(civil_data_dict)

# examine the documentation
?processCivilFile
```

You can process a single file. By default, `vcapr` will use the
preloaded data layout and will process case records. If you want to
change this, you can pass in another record type. See the documentation
for details

``` r
# import, parse and write a single file to a destination directory
#
# NOTE: change this to wherever the raw files are stored on your machine
# and where you want to the separated files to be saved
process_results <- processCivilFile('/vcap/NOBC0001', '/vcap/tables/')
```

Or (recommended) you can point `vcapr` to the directory containing the
files you want to process. By default, `vcapr` will use the preloaded
data layout and will process case records. If you want to change this,
you can pass in another record type. See the documentation for details

``` r
# import, parse and write files from a directory of raw files to a destination
# directory. only accepts files for the relevant table type (e.g. case)
# 
# NOTE: change this to wherever the raw files are stored on your machine
# and where you want to the separated files to be saved
process_results <- processCivilDirectory('/vcap/raw_files/', 'vcap/2022/tables/')
```

In case you want to pass in several specific files, `vcapr` is designed
to loop efficiently.

``` r
# loop through a series of files specified by the user
# NOTE: change this to wherever the raw files are stored on your machine
# and where you want to the separated files to be saved
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
preloaded into the package for ease of use.

*NOTE: It’s not advisable to load all the data into memory at once, so
we’ve refactored vcapr to loop through a file or directory and
reconstruct the tables line by line.*

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

#load all case record data from the civil extract into one dataframe
all_tables <- importFiles('c', civil_data_dict, 'path/to/raw/vcap/files/')

#load all specifications per a specified data dictionary
all_specs <- loadAllSpecs(civil_data_dict)

#load relevant tables from civil data
issue_type <- loadCivilTable('../../aoc/2022/sep/NOBC23', all_specs)
party_names <- loadCivilTable('../../aoc/2022/sep/NOBC48', all_specs)
```

<!--You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/v1/examples>.\-->
