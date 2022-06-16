---
title: "DEP_data_wrangling"

---

# part A
# combine season csv files
library(readr)
library(data.table)

dir="/Users/buzzlin99/Monash/S1_2022/FIT5147_data_exploration/Data Exploration Project/Allgame_stats"

file_list=list.files(path=dir, pattern="*.csv$", recursive=TRUE, full.names= TRUE)

store_csv=paste(dir, "allseason.csv")

for (i in 1:length(file_list))
{
alldf=fread(file=file_list[i], encoding="UTF-8")
write_csv(alldf, path=store_csv, append=TRUE,col_names= FALSE)
}

#dataframe

season<-read_csv("/Users/buzzlin99/Monash/S1_2022/FIT5147_data_exploration/Data Exploration Project/Allgame_stats/allseason.csv")

library(tidyverse)
library(janitor)

season <- season %>% row_to_names(row_number = 1)

# clean data

season[season=='Inactive'] <-NA
season[season=='Did Not Dress']<-NA
season[season=='Did Not Play']<- NA

cleanseason=na.omit(season)

store_csv=paste(dir, "cleanseason.csv")
write_csv(cleanseason, path=store_csv)


# combine shooting csv files

library(readr)
library(data.table)

dir2="/Users/buzzlin99/Monash/S1_2022/FIT5147_data_exploration/Data Exploration Project/shooting"

file_list2=list.files(path=dir2, pattern="*.csv$", recursive=TRUE, full.names= TRUE)

store_csv=paste(dir2, "allshooting.csv")

for (n in 1:length(file_list2))
{
shootingdf=fread(file=file_list2[n], encoding="UTF-8")
write_csv(shootingdf, path=store_csv, append=TRUE,col_names= FALSE)
}

# shooting dataframe

shooting<-read_csv("/Users/buzzlin99/Monash/S1_2022/FIT5147_data_exploration/Data Exploration Project/shooting allshooting.csv")

library(tidyverse)
library(janitor)

shooting <- shooting %>% row_to_names(row_number = 1)


store_csv=paste(dir2, "shootingclean.csv")

write_csv(shooting, path=store_csv)










