install.packages("tidycensus")
install.packages("tidyverse")
install.packages("dplyr") 
install.packages("plotly")
install.packages(c("sf", "tigris"))
install.packages("writexl")

library(tidycensus)
library(tidyverse)
library(dplyr)
library(plotly)
library(sf)
library(tigris)
library(writexl)

#for ACS5
ACS5_2023_variables <- load_variables(2023, "acs5", cache = TRUE)
View(ACS5_2023_variables)



poverty_est_df23 <- get_acs(geography = "county", 
                            variables = "B05010_001",
                            state = "Iowa", 
                            geometry = FALSE, 
                            survey = "acs5",
                            year = 2023)
poverty_est_df23 <- poverty_est_df23 %>%
  mutate(acsPool = "2019-2023")
view(poverty_est_df23)


poverty_est_df18 <- get_acs(geography = "county", 
                            variables = "B05010_001",
                            state = "Iowa", 
                            geometry = FALSE, 
                            survey = "acs5",
                            year = 2018)
poverty_est_df18 <- poverty_est_df18 %>%
  mutate(acsPool = "2014-2018")
view(poverty_est_df18)


poverty_est_df13 <- get_acs(geography = "county", 
                            variables = "B05010_001",
                            state = "Iowa", 
                            geometry = FALSE, 
                            survey = "acs5",
                            year = 2013)
poverty_est_df13 <- poverty_est_df13 %>%
  mutate(acsPool = "2009-2013")
view(poverty_est_df13)


df <- bind_rows(poverty_est_df23, poverty_est_df18, poverty_est_df13)


write_xlsx(df, "povertyDataACS.xlsx", col_names=TRUE)


#alternate to write individual XLS files
write_xlsx(poverty_est_df23, "povertyDataACS23.xlsx", col_names=TRUE)
write_xlsx(poverty_est_df18, "povertyDataACS18.xlsx", col_names=TRUE)
write_xlsx(poverty_est_df13, "povertyDataACS13.xlsx", col_names=TRUE)
