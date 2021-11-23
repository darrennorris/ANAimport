# ANAimport
R code to import and tidy rainfall and river flow data from ANA weather stations https://www.snirh.gov.br/hidroweb/mapa

The function will work with rain (chuva), river flow (Vazao) and river level (Cota) data downloaded from https://www.snirh.gov.br/hidroweb/serieshistoricas .

Data needs to be downloaded in the text (txt) format.

## Required R libraries
- <code>plyr</code>
- <code>tidyverse</code>
Must be loaded in the following sequence
library(plyr)
library(tidyverse)