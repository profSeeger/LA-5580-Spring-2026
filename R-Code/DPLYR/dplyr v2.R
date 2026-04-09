## ----Install-packages---------------------------------------------------------
install.packages("tidyverse")

## ----Load Libraries-----------------------------------------------------------
library(tidyverse)

## ----Setup and Load Data------------------------------------------------------

# The original data for this demo came from https://data.iowa.gov/Primary-Secondary-Ed/Math-And-Reading-Proficiency-in-Iowa-by-School-Yea/f3h8-mnxi/data_preview

# Save file
# Set your script to use 
# Session-->Set Working Directory --> To Source File Location

# confirm the data file you want to load is in the same directory as this file

# Load the external csv file into a dataframe
# we will use readr package which is loaded as part of the tidyverse
# https://readr.tidyverse.org/

scores <- read.csv2("Math_And_Reading_Proficiency.csv", sep = "," )
glimpse(scores)
View(scores)



## Reference
## https://dplyr.tidyverse.org/reference/


## ----Filter------------------------------------------------------

#Filter for a year
scores_2017 <-  scores %>% filter(School.Year == 2017)

#Filter for a year and topic
scores_2017_math <-  scores %>% filter(School.Year == 2017 & Topic == 'Math')


## ----Mutate------------------------------------------------------
# change Proficiency column from string to numeric
scores <- scores %>%
  mutate(percentProficient = as.numeric(X..Proficient))
glimpse(scores)

# remove records that have no results. NA
scores_clean1 <- scores %>% drop_na(percentProficient)

# Alternatively find records that have total > 0.  or != 0
scores_clean2 <- scores %>% filter(Total != 0)



## ----GroupBy------------------------------------------------------

scores_mean_math <- scores_clean2 %>%
  filter(Topic == 'Math') %>%
  group_by(District.Name) %>%
  summarize(Math_Mean = mean(percentProficient, na.rm=TRUE))


#
#Filter for a district and school year
scores_Perry <-  scores %>% filter(District.Name == "Perry" & School.Year == 2013)

#Filter for a year and grade
scores_Same <-  scores %>% filter(School.Year == 2016 & Grade == 3)

#Filter for a year and other characteristics
scores_Gilbert <-  scores %>% filter(Topic == "Math" & School.Year == 2010 & Grade == 3 & District.Name == "Gilbert")

#Filter for a found error
scores_Error <-  scores %>% filter(Total == 16 & Proficient == 12 & Grade == 3)