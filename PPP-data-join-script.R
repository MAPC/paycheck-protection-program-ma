library(readr)
library(dplyr)
library(RPostgres)


# 1 - read data in from GitHub
#------------------------------
urlfile="https://raw.githubusercontent.com/MAPC/paycheck-protection-program-ma/master/PPP-data-up-to-and-over-150K-MA-city-clean.csv"
mydata<-read.csv(url(urlfile))
#I'm getting 36,504 warnings for parsing failures due to column specs - GPH
#This is where we are losing business names, as BusinessName is spec'd as col_logical() - ?
#***fixed by using read.csv (base) as opposed to read_csv (tidyverse)***

#add leading zeros back to zip codes
mydata$Zip = sprintf("%05d", mydata$Zip)


# 2 - read in municipal keys and es202 data from database
#---------------------------------------------------------
con_in <- dbConnect(RPostgres::Postgres(), host='pg.mapc.org', port='5432', dbname='ds', user='viewer', password='mapcview451')

key_id = DBI::Id(schema='tabular', table='_datakeys_muni351')
es202_id = DBI::Id(schema='tabular', table='econ_es202_naics_2d_m')

#change to read off of database
#muni_keys <- read.csv("K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/tabular._datakeys_muni351.csv")
muni_keys <- dbReadTable(con_in, key_id, append = TRUE)
#es202 <- read.csv("K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/tabular.econ_es202_naics_2d_m_2018.csv")
es202 <- dbReadTable(con_in, es202_id, append = TRUE)

#rename naicscode, since there are a number of those fields across the data
#changed from NAICSCode3 to *2r, as these are 2 digit codes, just that this field contains some ranges - GPH
names(es202)[names(es202) == "naicscode"] <- "NAICSCode2r"

#only take 2018 records from es202; Ajay's file took care of this, but need this line when reading from DB - GPH
es202 <- es202[es202$cal_year == 2018,]

#add a 2-digit NAICScode field, using first 2 digits of NAICScode
mydata$NAICSCode2 <- substr(mydata$NAICSCode, start = 1, stop = 2)

#--------------------
#---it's irritating that we have to do this type of work around --GPH
# in es202, there are some ranges in the 2d NAICS codes, which match to NAICS titles
# NAICS titles are really what we are looking for

range <- as.character(11:99)
range2 <- as.character(11:99)

range2[21] <- "31-33"
range2[22] <- "31-33"
range2[23] <- "31-33"
range2[34] <- "44-45"
range2[35] <- "44-45"
range2[38] <- "48-49"
range2[39] <- "48-49"

#data frame of 2d NAICS codes and what range they fall in
x <- data.frame(NAICSCode2 = range, NAICSCode2r = range2, stringsAsFactors = FALSE)
#-------------------


# 3 - join municipal keys and es202 data
#----------------------------------------
#join x to mydata by NAICSCode2
mydata <- left_join(mydata, x, by=c("NAICSCode2"), match = "all")

#join muni keys to mydata on muni_id
mydata2 <- left_join(mydata, muni_keys, by = c("CITY" = "muni_upper"), match = "all")

#add a lower case muni name column to mydata and es202 to use for join
#mydata$munilower <- tolower(mydata$City)
#es202$munilower <- tolower(es202$municipal)

#-----------------------
# testing section - GPH
# I'd rather join the muni_key first, then use muni_id to join es202; munilower is unnecessary
# testing...
test_df = data.frame(City = unique(mydata$City), stringsAsFactors = FALSE)
test = anti_join(test_df, muni_keys, by = c("City" = "muni_upper"))
# - there are 22 non matches due to errors in the City field; this is causing some of the issues
test2 = anti_join(mydata, muni_keys, by = c("City" = "muni_upper"))
#------------------------

#join es202 data to mydata on munilower and NAICSCode3
mydata3 <- left_join(mydata, es202, by=c("muni_id", "NAICSCode2r"), match = "all")


# 4 - reorganize and rename columns
#-----------------------------------
ppp <- data.frame(
                  id = "...",
                  ln_amt_rng = mydata$Loan.Amount...Range,
                  nbhd_area = mydata$Neighborhood...Area,
                  muni_id = mydata$muni_id,
                  muni = mydata$muni_upper,
                  state = "MA",
                  zip = mydata$Zip,
                  tot_est = mydata$"...",
                  naicscode = mydata$NAICSCode,
                  naicscd_2d = mydata$NAICSCode2,
                  naicstitle = mydata$NAICS.Title,
                  bus_type = mydata$BusinessType,
                  race_eth = mydata$RaceEthnicity,
                  gender = mydata$Gender,
                  veteran = mydata$Veteran,
                  non_profit = mydata$NonProfit,
                  jobs_rtnd = mydata$JobsRetained,
                  date_appr = mydata$DateApproved,
                  lender = mydata$Lender,
                  stringsAsFactors = FALSE
                  )


# 5 - write mydata to file
#--------------------------
write_csv(ppp, "K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/econ_202_joined.csv")