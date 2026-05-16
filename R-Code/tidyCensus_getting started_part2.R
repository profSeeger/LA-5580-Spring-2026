## ----Install-packages---------------------------------------------------------
#load one at a time
install.packages("tidycensus")
install.packages("tidyverse")
install.packages("dplyr") #this is actually also loaded in the tidyverse
#or several at once, these are more for visual display
install.packages(c("tidyverse", "plotly"))
install.packages("highcharter") #interactive charts
#and these help with spatial
install.packages(c("sf", "tigris"))



## ----Load Libraries-----------------------------------------------------------
#load one at a time
library(tidycensus)
library(tidyverse)
library(dplyr)
library(sf)
library(tigris)

library(ggplot2)
library(plotly)
library(highcharter)

## ----Loading Tidy Census ACS Data---------------------------------------------
# For this example, we are going to look at Poverty
# To calculate income to poverty, you divide a person or family's total 
# income before taxes by the federally established poverty threshold that 
# corresponds to their household size; if the result is less than 1, then 
# their income is considered below the poverty line.
# official documentation on this data is at 
# https://www.census.gov/topics/income-poverty/poverty/guidance/poverty-measures.html



#Display all the variable in the 2024 1 year ACS and open a tab to view the info
ACS1_2024_variables <- load_variables(2024, "acs1", cache = TRUE)
View(ACS1_2024_variables)

#for ACS5
ACS5_2024_variables <- load_variables(2024, "acs5", cache = TRUE)
View(ACS5_2024_variables)

#name, label, concept and lowest level of geography available are displayed.
# this table is searchable
#search for the word Poverty and we find  there are two variables of interest

# B05010_001 total number in the estimate
# B05010_002 total number with a ratio value below 1, by definition in poverty

# Now that we have two variables to work with, we want to retrieve them from 
# The US Census using a package called TidyCensus

# Save the results of this in data frame which I am calling something like poverty_df

#Example looking at ACS1 data, remove the survey = "acs1" to use acs5
degree_est_df <- get_acs(geography = "county", 
              variables = "B15012_001",
              state = "Iowa", 
              output = "wide",
              geometry = TRUE, 
              survey = "acs5",
              year = 2024)
#look at the data frame and notice only 10 results!
view(degree_est_df)




#now get the B05010_002 total number with a ratio value below 1
degree_cs_math_stat_df <- get_acs(geography = "county", 
                             variables = "B15012_002",
                             state = "Iowa", 
                             output = "wide",
                             geometry = TRUE,
                             survey = "acs5",
                             year = 2024)
mapview(degree_cs_math_stat_df)





#now get the B05010_002 total number with a ratio value below 1
degree_eng_df <- get_acs(geography = "county", 
                                  variables = "B15012_007",
                                  state = "Iowa", 
                                  output = "wide",
                                  geometry = TRUE,
                                  survey = "acs5",
                                  year = 2024)
#mapview(degree_eng_df)









#now get the B05010_002 total number with a ratio value below 1
degree_bus_df <- get_acs(geography = "county", 
                         variables = "B15012_010",
                         state = "Iowa", 
                         output = "wide",
                         geometry = TRUE,
                         survey = "acs5",
                         year = 2024)
#mapview(degree_bus_df)






#maybe preview this as a map
#add Mapview package and library. In the future include this at the top of script!
install.packages("mapview")
library(mapview)

mapview(degree_est_df)



## ----Getting down to business---------------------------------------------

# Before we get to far, we need to set our working directory. So first save this file.
# From the Session Menu --> Set Working Directory --> To Source File Location
getwd() #this will display your working directory

#Get the ACS5 data, remove the survey = "acs1" to use acs5
degree_est_df <- get_acs(geography = "county", 
                          variables = "B15012_001",
                          state = "Iowa", 
                          output = "wide",
                          geometry = TRUE,
                          year = 2024)
mapview(degree_est_df)




#now get the B05010_002 total number with a ratio value below 1
degree_cs_math_stat_df <- get_acs(geography = "county", 
                          variables = "	B15012_002",
                          state = "Iowa", 
                          output = "wide",
                          geometry = TRUE,
                          year = 2024)
mapview(degree_cs_math_stat_df)


#but now we have two data frames, it would be better if we had this in just one
bs_degree_df <- get_acs(geography = "county", 
                      variables = c(all_degree = "B15012_001",
                                    cs_math_stat = "B15012_002",
                                    eng_degree = "B15012_007",
                                    bus_degree = "B15012_010"),
                      state = "Iowa", 
                      output = "wide",
                      geometry = TRUE,
                     year = 2024)
view(bs_degree_df)
mapview(bs_degree_df)

#Looks good so we can create a shapefile
st_write(bs_degree_df, "iowa_bs_degree.shp")

#note error message about ESRI field name abbreviation
#so save as a geojson!
st_write(bs_degree_df, "iowa_bs_degree.geojson")

#If we just wanted the data as a CSV, we could run the code above with geometry = FALSE
poverty_df_noGeo <- get_acs(geography = "county", 
                      variables = c(poverty_est = "B05010_001",
                                    poverty_und1 = "B05010_002"),
                      state = "Iowa", 
                      output = "wide",
                      geometry = FALSE,
                      year = 2024)
view(poverty_df_noGeo)
write_csv2(poverty_df_noGeo, "povertyRatio.csv", append = FALSE)



# Sometimes you might want to get all the data from a table instead of 
# listing it out like above. For example, to get the values for the 25 columns
# that are part of B05010 "Ratio of Income to Poverty Level by Nativity of 
# Children in Families and Subfamilies by Living Arrangements and Nativity of 
# Parents" for Polk County, Iowa use the folloing script.
# For more info on this data https://censusreporter.org/tables/B05010/
polk_IncomePovertyLevel <- get_acs(
  geography = "county", 
  county = "Polk",
  state = "IA",
  table = "B05010", 
  year = 2024
)
view(polk_IncomePovertyLevel)



#one more example of how this combined variables works for getting three 
#variables. Note you can't combine the year using c(2024, 2019) you 
# have to do separate request and merge results.
polk_education <- get_acs(
  geography = "county",
  county = "Polk",
  state = "IA",
  variables = c(percent_high_school = "DP02_0062P", 
                percent_bachelors = "DP02_0065P",
                percent_graduate = "DP02_0066P"),
  #output = "wide",
  geometry = TRUE,
  year = 2024
)
view(polk_education)
st_write(polk_education, "polk_education.geojson")

