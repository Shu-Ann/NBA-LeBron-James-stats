library(tidyverse)  # data handling and plotting
library(rvest)      # scrape data

# Geography and travel
library(sf)         # handle geographies
library(osrm)       # fetch travel info

# Interactive elements
library(leaflet)    # interactive maps
library(DT)         # interactive tables
library(plotly)     # interactive plots

nba_scrape <-
  read_html("https://en.wikipedia.org/wiki/National_Basketball_Association") %>% 
  html_nodes(xpath = "/html/body/div[3]/div[3]/div[5]/div[1]/table[4]") %>%
  html_table(fill = TRUE, header = NA) %>%.[[1]]  # list was returned, so extract first list element

glimpse(nba_scrape)  # a data frame

nba_wrangle <- nba_scrape %>% 
  select(-length(.)) %>%  # remove the last column (NA)
  dplyr::filter(!str_detect(Division, "Conference")) %>% 
  mutate(
    Conference = c(rep("Eastern", 15), rep("Western", 15)),
    Capacity = as.numeric(str_remove(Capacity, ","))
  ) %>% 
  separate(Location, c("City", "State"), sep = ", ") %>% 
  separate(Coordinates, c("Coords1", "Coords2", "Coords3"), " / ") %>% 
  separate(Coords3, c("Latitude", "Longitude"), sep = "; ") %>% 
  separate(Longitude, c("Longitude", "X"), sep = " \\(") %>% 
  mutate(
    Latitude = as.numeric(Latitude),
    Longitude = as.numeric(
      str_remove(Longitude, "\\ufeff")  # remove rogue unicode
    )  
  ) %>% 
  select(
    Team, Conference, everything(),
    -Founded, -Joined, -Coords1, -Coords2, -X
  ) %>% 
  as_tibble()  # convert to tibble

glimpse(nba_wrangle)


nba_abbr_cols <- 
  read_html(
    "https://en.wikipedia.org/wiki/Wikipedia:WikiProject_National_Basketball_Association/National_Basketball_Association_team_abbreviations"
  ) %>% 
  html_nodes(xpath = "/html/body/div[3]/div[3]/div[5]/div[1]/table") %>%
  html_table(header = TRUE) %>%
  .[[1]] %>% 
  rename(Code = `Abbreviation/Acronym`) %>% 
  mutate(
    # {leaflet} markers take a named colour
    colour_marker = case_when(
      Code == "ATL" ~ "red",
      Code == "BKN" ~ "black",
      Code == "BOS" ~ "green",
      Code == "CHA" ~ "darkblue",
      Code == "CHI" ~ "red",
      Code == "CLE" ~ "darkred",
      Code == "DAL" ~ "blue",
      Code == "DEN" ~ "darkblue",
      Code == "DET" ~ "red",
      Code == "GSW" ~ "blue",
      Code == "HOU" ~ "red",
      Code == "IND" ~ "darkblue",
      Code == "LAC" ~ "red",
      Code == "LAL" ~ "blue",
      Code == "MEM" ~ "lightblue",
      Code == "MIA" ~ "red",
      Code == "MIL" ~ "darkgreen",
      Code == "MIN" ~ "darkblue",
      Code == "NOP" ~ "darkblue",
      Code == "NYK" ~ "blue",
      Code == "OKC" ~ "blue",
      Code == "ORL" ~ "blue",
      Code == "PHI" ~ "blue",
      Code == "PHX" ~ "darkblue",
      Code == "POR" ~ "red",
      Code == "SAC" ~ "purple",
      Code == "SAS" ~ "black",
      Code == "TOR" ~ "red",
      Code == "UTA" ~ "darkblue",
      Code == "WAS" ~ "darkblue"
    ),
    # {leaflet} marker icons take hex
    colour_icon = case_when(
      Code == "ATL" ~ "#C1D32F",
      Code == "BKN" ~ "#FFFFFF",
      Code == "BOS" ~ "#BA9653",
      Code == "CHA" ~ "#00788C",
      Code == "CHI" ~ "#000000",
      Code == "CLE" ~ "#FDBB30",
      Code == "DAL" ~ "#B8C4CA",
      Code == "DEN" ~ "#FEC524",
      Code == "DET" ~ "#1D42BA",
      Code == "GSW" ~ "#FFC72C",
      Code == "HOU" ~ "#000000",
      Code == "IND" ~ "#FDBB30",
      Code == "LAC" ~ "#1D428A",
      Code == "LAL" ~ "#FDB927",
      Code == "MEM" ~ "#12173F",
      Code == "MIA" ~ "#F9A01B",
      Code == "MIL" ~ "#EEE1C6",
      Code == "MIN" ~ "#9EA2A2",
      Code == "NOP" ~ "#C8102E",
      Code == "NYK" ~ "#F58426",
      Code == "OKC" ~ "#EF3B24",
      Code == "ORL" ~ "#C4CED4",
      Code == "PHI" ~ "#ED174C",
      Code == "PHX" ~ "#E56020",
      Code == "POR" ~ "#000000",
      Code == "SAC" ~ "#63727A",
      Code == "SAS" ~ "#C4CED4",
      Code == "TOR" ~ "#000000",
      Code == "UTA" ~ "#F9A01B",
      Code == "WAS" ~ "#E31837"
    )
  ) %>% 
  as_tibble()


nba_table <- nba_wrangle %>% 
  left_join(nba_abbr_cols, by = c("Team" = "Franchise")) %>%
  select(Code, everything())

glimpse(nba_table)


nba_table <- subset(nba_table, select = -c(3,4,5,6,7,8,11,12))
nba_table$Opp<-nba_table$Code
nba_table<-subset(nba_table, select=-c(1))
names(nba_table)[1] <- "Name"

store_csv=paste("nba_location.csv")
write_csv(nba_table, path=store_csv)
