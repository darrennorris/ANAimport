# ANAimport
R code to import and tidy rainfall and river flow data from ANA weather stations across Brazil https://www.snirh.gov.br/hidroweb/mapa . Creates a data.frame with daily values including some (probably) useful date formats.

The function (`ana_import.R`) will work with rain (Chuva), river flow (Vazao) and river level (Cota) data downloaded from https://www.snirh.gov.br/hidroweb/serieshistoricas . Function currently works only with data downloaded in the text (.txt) format. Example data from a rain station included (file: chuvas_T_08361007.txt).

## Inputs
Uses .txt file with historic weather station data. See example data file 
<a href="https://github.com/darrennorris/ANAimport/blob/main/chuvas_T_08361007.txt"><em>chuvas_T_08361007.txt</em></a>
## Result
A data.frame with daily values including (hopefully) useful date formats.

## Required R libraries
- <code>plyr</code>
- <code>tidyverse</code>

Must be loaded in the following sequence:

`library(plyr)`

`library(tidyverse)`

## Example
1. Search and find a weather station https://www.snirh.gov.br/hidroweb/mapa . Use the station id code to search for historical data https://www.snirh.gov.br/hidroweb/serieshistoricas .
Download the data in the ".txt" format. Save the data file ("...txt"") to a folder.

2. Run the following in R

`library(plyr)`

`library(tidyverse)`

2.1 Load the function. Here a copy of the function has been downloaded and saved in the working directory.

`source("ana_import.R")`

2.2 Tell R the name and location of the .txt file with the data. Here the text file with the data is in the working directory.

`chmaraca <- "chuvas_T_08361007.txt"`

2.3 Import data. Type must be specified as one of: Chuva, Vazao or Cota.

`df_rain_maraca <- ana_import(x=chmaraca, type="Chuva")`