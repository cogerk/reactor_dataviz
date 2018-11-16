library(googledrive)
library(tidyverse)
library(data.table)


# Get list of data files from google drive & download lastest
rct.list <- drive_ls(path='~/Data From Reactor', type='csv') %>%
  mutate(date.started=as.POSIXct(substr(name,2,16), format='%m%d%Y_%H%M%S')) %>%
  arrange(date.started)
drive_download(tail(rct.list, n=1))

# Assign to (fread is finicky about last line)
#TODO: Improve this part
headers <- fread('_11012018_215518.csv', nrows =1)
recent_data <- fread('_11012018_215518.csv', nrows = 6079388, skip=2, header= FALSE)

# Data cleaning, removing columns w/ no signal
descrip <- as.character(headers)
id <- colnames(headers)
rem.cols <- c(grep('N/A',descrip),grep('R2',descrip), 5, 39)
descrip <- descrip[-rem.cols]
descrip[c(1, 22)] <- c('Timestamp', 'R1 Ammonium Pump')
descrip <- gsub('R1 ','', descrip)
descrip <- gsub(' ','_', descrip)
id <- id[-rem.cols]
recent_cleaned <- recent_data %>%
  select(-rem.cols) 
  
# Give meaningful column names
colnames(recent_cleaned) <- descrip

# Remove disconnected probes w/ incorrect column headers
recent_cleaned2<- recent_cleaned[500000:nrow(recent_cleaned),] %>%
  select(-`Ca2+`, -`Na+_(2)`, -`NH4+_(2)`) %>%
  mutate(Timestamp=as.POSIXct(Timestamp+8*60*60, origin='1970-01-01'))

# Save as rda file
save(recent_cleaned2, file='latest_data.Rda')

