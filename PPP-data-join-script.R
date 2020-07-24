library(readr)
library(dplyr)

urlfile="https://raw.githubusercontent.com/MAPC/paycheck-protection-program-ma/master/PPP-data-up-to-and-over-150K-MA-city-clean.csv"

mydata<-read_csv(url(urlfile))
mydata <- read.csv("K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/PPP-data-up-to-and-over-150K-MA-city-clean2.csv")

df2 <- read.csv("K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/tabular._datakeys_muni351.csv")


df3 <- read.csv("K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/tabular.econ_es202_naics_2d_m_2018.csv")

names(df3)[names(df3) == "naicscode"] <- "NAICSCode3"

mydata$NAICSCode2 <- substr(mydata$NAICSCode, start = 1, stop = 2)

range <- as.character(11:99)
range2 <- as.character(11:99)

range2[21] <- "31-33"
range2[22] <- "31-33"
range2[23] <- "31-33"
range2[34] <- "44-45"
range2[35] <- "44-45"
range2[38] <- "48-49"
range2[39] <- "48-49"

x <- data.frame(NAICSCode2 = range, NAICSCode3 = range2)

mydata <- left_join(mydata, x, by=c("NAICSCode2"), match = "all")

mydata$munilower <- tolower(mydata$City)
df3$munilower <- tolower(df3$municipal)
mydata2 <- left_join(mydata, df3, by=c("munilower", "NAICSCode3"), match = "all")
mydata3 <- left_join(mydata2, df2, by=c("muni_id"), match = "all")

write_csv(mydata3, "K:/DataServices/Projects/Current_Projects/Data Intake Process/Other (do not enter)/econ_202_joined.csv")
