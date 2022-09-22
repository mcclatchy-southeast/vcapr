
<!-- README.md is generated from README.Rmd. Please edit that file -->

# vcapr

<!-- badges: start -->
<!-- badges: end -->

Tools to efficiently import and parse data extracts from the N.C.
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
#load the package
library(vcapr)

#load all specifications per a specified data dictionary
all_specs <- loadAllSpecs(civil_data_dict)
#> ...TABLE LIST CREATED
#> ...COMMON SPECS CREATED
#> ...SPEC FOR NOBC0 CREATED
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
#> ...SPEC FOR NOBC3 CREATED
#> ...SPEC FOR NOBA4 CREATED
#> ...SPEC FOR NOBA3 CREATED
#> ...SPEC FOR NOBA36 CREATED
#> ...SPEC FOR NOBA21 CREATED
#> ...SPEC FOR NOBA5 CREATED
#> ...SPEC FOR NOBA37 CREATED
#> ...SPEC FOR NOBA6 CREATED
#> ...SPEC FOR NOBA7 CREATED
#> ...SPEC FOR NOBA8 CREATED
#> ...SPEC FOR NOBA9 CREATED
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
#> ...SPEC LOAD COMPLETE. ELAPSED TIME: 3.107 seconds

#load relevant tables from civil data
issue_type <- loadCivilTable('../../aoc/2022/sep/NOBC23', all_specs)
#> x  ERROR: ../../aoc/2022/sep/NOBC23 DOES NOT EXIST
party_names <- loadCivilTable('../../aoc/2022/sep/NOBC48', all_specs)
#> x  ERROR: ../../aoc/2022/sep/NOBC48 DOES NOT EXIST
```

<!--## Example

This is a basic example which shows you how to solve a common problem:


```r
library(vcapr)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`? You can include R chunks like so:


```r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You'll still need to render `README.Rmd` regularly, to keep `README.md` up-to-date. `devtools::build_readme()` is handy for this. You could also use GitHub Actions to re-render `README.Rmd` every time you push. An example workflow can be found here: <https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don't forget to commit and push the resulting figure files, so they display on GitHub and CRAN.-->
