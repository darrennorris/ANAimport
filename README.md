# ANAimport
R code to import and tidy rainfall and river flow data from ANA weather stations https://www.snirh.gov.br/hidroweb/mapa

The function (ana_import.R) will work with rain (Chuva), river flow (Vazao) and river level (Cota) data downloaded from https://www.snirh.gov.br/hidroweb/serieshistoricas . Function currently works only with data downloaded in the text (.txt) format. Example data from a rain station included (chuvas_T_08361007.txt).

## Inputs
Uses .txt file with historic weather station data. See example data file "chuvas_T_08361007.txt".
## Result
Creates a data.frame with daily values including useful date formats.

## Required R libraries
- <code>plyr</code>
- <code>tidyverse</code>

Must be loaded in the following sequence:

`library(plyr)`

`library(tidyverse)`

## Example
`library(plyr)`

`library(tidyverse)`

`source("ana_import.R")`

`#Tell R name and location of the file with the data. Here the rain data file is in the working directory`

`chmaraca <- "chuvas_T_08361007.txt"`

`#Import data. Type must be specified as one of: Chuva, Vazao or Cota`

`df_rain_maraca <- ana_import(x=chmaraca, type="Chuva")`