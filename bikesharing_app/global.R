library(dplyr)
library(lubridate)
library(data.table)


## read BVG Data
df.bvg.start <- read.csv('../BVG_start_points.csv') %>% filter(ANFRAGE_DATUM == '2017-07-17')
print(head(df.bvg.start))
df.bvg.end <- read.csv('../BVG_end_points.csv') %>% filter(ANFRAGE_DATUM == '2017-07-17')


## read Bikesharing data


bikes.csv <- '../BikeSharing/data/preprocessed.csv'
  
  
dt <- fread(cmd = paste('head -n 500000', bikes.csv))
#dt <- fread(bikes.csv)

# drop dupes cols
df.bikes<- dt[, which(duplicated(names(dt))) := NULL]
df.bikes$timestamp<- ymd_hms(df.bikes$timestamp)
df.bikes$end_timestamp<- ymd_hms(df.bikes$end_timestamp)

bike.id.list <- unique(df.bikes$bikeId)


transpose.datetime <- function(id){
  
  print(id)
  df.test <- df.bikes %>% filter(bikeId==id)
  
  min(df.test$timestamp)
  
  datetime.index <-seq(from = ISOdatetime(2019,04,03,09,0,0),to=ISOdatetime(2019,07,11,9,0,0), by = "10 min") %>% as.data.frame()
  colnames(datetime.index)<-c('dt.index')
  
  setDT(df.test)
  setDT(datetime.index)
  
  #browser()
  
  setkey(df.test,  timestamp)[, dateMatch:=timestamp]
  merged <-df.test[datetime.index, roll='nearest']
  
  return (merged)
}

