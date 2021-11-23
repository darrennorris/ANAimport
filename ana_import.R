# R function to import ANA rain and river data
ana_import <- function(x, type, out_val = NA){
  typech <- nchar(type)
  class <- ifelse(type%in%c("Vazao","Cota"), "river", "rain")
  if(type=="Vazao"){
    #Flow
    dfw <- readr::read_delim(x, ";", escape_double = FALSE, 
                             col_types = cols(EstacaoCodigo = col_character(), 
                                              MediaAnual = col_double()), 
                             locale = locale(decimal_mark = ","), 
                             trim_ws = TRUE, skip = 13)
    #Unique months
    dfc1 <- plyr::ddply(dfw, .(Data), summarise, 
                        maxc = max(NivelConsistencia))
    dfw <- merge(dfc1, dfw, by.x=c("Data", "maxc"), 
                 by.y=c("Data", "NivelConsistencia"), all.x=TRUE)
    dfw$Data_m <- as.Date(dfw$Data, "%d/%m/%Y")
  }
  if(type=="Cota"){
    #River level
    dfw <- readr::read_delim(x, ";", escape_double = FALSE, 
                             col_types = cols(EstacaoCodigo = col_character()),
                             trim_ws = TRUE,  skip = 13)
    #Unique months
    dfc1 <- plyr::ddply(dfw, .(Data), summarise, 
                        maxc = max(NivelConsistencia), 
                        maxm = max(MediaDiaria))
    dfw <- merge(dfc1, dfw, by.x=c("Data", "maxc", "maxm"), 
                 by.y=c("Data", "NivelConsistencia", "MediaDiaria"), all.x=TRUE)
    dfw$Data_m <- as.Date(dfw$Data, "%d/%m/%Y")
  }
  if(type=="Chuva"){
    #Rain
    dfw <- read_delim(x, ";", escape_backslash = TRUE, 
                      col_types = cols(EstacaoCodigo = col_character()),
                      locale = locale(decimal_mark = ","), 
                      trim_ws = TRUE, skip = 12) 
    #Unique months
    dfc1 <- plyr::ddply(dfw, .(Data), summarise, 
                        maxc = max(NivelConsistencia))
    dfw <- merge(dfc1, dfw, by.x=c("Data", "maxc"), 
                 by.y=c("Data", "NivelConsistencia"), all.x=TRUE)
    dfw$Data_m <- as.Date(dfw$Data, "%d/%m/%Y")
  }
  #
  #reshape to long structure
  myvarv<-c(paste(type,"0", c(1:9),sep=""), paste(type, c(10:31),sep=""))
  dflong <- reshape2::melt(data=dfw,id=c("EstacaoCodigo","Data_m"),
                           measure.vars=myvarv)
  # Add useful date formats
  dflong$ayear <- as.numeric(as.character(dflong$Data_m, format="%Y"))
  dflong$amonth <- as.numeric(as.character(dflong$Data_m, format="%m"))
  dflong$aday <- as.numeric(substr(str_trim(dflong$variable),typech + 1, typech +2))
  dflong$datam <- as.Date(paste(dflong$aday, dflong$amonth, 
                                dflong$ayear, sep="/"), 
                          format = "%d/%m/%Y", tz="UTC")
  dflong$datax <- as.POSIXct(strptime(paste(dflong$aday, dflong$amonth, 
                                            dflong$ayear, sep="/"), 
                                      format = "%d/%m/%Y", tz="UTC"))
  dflong$julian_day <- as.numeric(format(dflong$datax, "%j"))
  
  #Exclude outliers from our stations, based on values outside timeseries
  if(!is.na(out_val)){
    #exclude outlier/error
    dflong[which(dflong$value >= out_val), 'value'] <- NA
  }
  #exclude invalid (NA) dates
  seldlo <- which(is.na(dflong$datam))
  dflong <- dflong[-seldlo, ]
  #exclude any outside measurements
  selvlo <-which(!is.na(dflong$value))
  selfvlo <- min(dflong$datax[selvlo], na.rm = TRUE)#date of first measurement
  sellvlo <- max(dflong$datax[selvlo], na.rm=TRUE)#date of last measurement
  #exclude any before first measurement
  dflong <- dflong[which(dflong$datax >= selfvlo), ]
  #exclude any after last measurement
  dflong <- dflong[which(dflong$datax <= sellvlo), ]
  
  #exclude any duplicate dates e.g April 2015 in Calcoene 8250002
  seldupe <- which(duplicated(dflong$datax))
  if(!is.null(seldupe) && !is.na(seldupe) && (length(seldupe)>0)){
    dflong <- dflong[-seldupe, ]
  }
  #Tidy and add variables for gam modelling
  dflong$aweek <- as.numeric(as.character(dflong$datax, format="%V"))
  dflong$yearweek <- paste(dflong$ayear,as.character(dflong$datax, format="%V"), sep="")
  dflong$yearmonth <- paste(dflong$ayear, as.character(dflong$datax, format="%m"), sep="")
  dflong$yearmonthn <- as.numeric(dflong$yearmonth)
  dflong$datan <- as.numeric(dflong$datax)
  dflong$datangam <- dflong$datan /10000 #to avoid large values affecting model stability
  dflong$ayearf <- as.factor(dflong$ayear)
  #river levels from capivara, sequence 
  # 1 = low; 2 = rising, 3 = high, 4 = decreasing
  dflong$river_level <- ifelse(dflong$amonth %in% c(9, 10, 11), 1, 0)
  dflong[which(dflong$amonth %in% c(12, 1, 2)), 'river_level'] <- 2
  dflong[which(dflong$amonth %in% c(3, 4, 5)), 'river_level'] <- 3
  dflong[which(dflong$amonth %in% c(6, 7, 8)), 'river_level'] <- 4
  dflong$river_levelf <- as.factor(dflong$river_level)
  levels(dflong$river_levelf) <- c("low", "rising", "high", "decreasing")
  #
  #return ordered by date
  dfout <- data.frame(class = class, type = type, dflong[order(dflong$datax), ])
  row.names(dfout) <- NULL
  dfout <- data.frame(aname = paste(dfout$type, dfout$EstacaoCodigo, sep="_"), 
                      dfout)
  return(dfout)
}