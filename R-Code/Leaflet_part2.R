## ----Install-packages---------------------------------------------------------
#load one at a time
install.packages("tidycensus")
install.packages("dplyr") #this is actually also loaded in the tidyverse
#or several at once, these are more for visual display
install.packages(c("tidyverse", "plotly"))
install.packages("highcharter") #interactive charts
#and these help with spatial
install.packages(c("sf", "tigris", "mapview"))


## ----Load Libraries-----------------------------------------------------------
#load one at a time
library(tidycensus)
library(tidyverse)
library(dplyr)
library(sf)
library(tigris)
library(mapview)
library(ggplot2)
library(plotly)
library(highcharter)

## ----Get some Census Data--------------------------------------------------------

# Before we get to far, we need to set our working directory. So first save this file.
# From the Session Menu --> Set Working Directory --> To Source File Location


#Grab Census tracts in Iowa with geometry
totalPopIA_tracts <- get_decennial(
  geography = "tract", 
  state = "IA",
  variables = "P1_001N",  #Total Population
  year = 2020,
  sumfile = "dhc",  #Demographic and Housing Characteristics
  geometry = TRUE
)

totalPopIA_tracts #note the value is actually located in a column named "value"


#basic plot
plot(totalPopIA_tracts["value"])


#Leaflet map via mapview package
mapview(totalPopIA_tracts, zcol = "value")


# You can export this from Viewer tab and then select Export --> Save as Web Page ...
# this will create an html page that you can then rename and copy to your GitHub repo and link to it there.




#building on lecture 7A
# We need Leaflet
install.packages("leaflet") 
library(leaflet)


# Get median household income data for a state (e.g., California) at the county level
income_data <- get_acs(
  geography = "county",
  variables = "B19013_001", # Median household income variable
  state = "IA", # Change to your desired state
  year = 2023,
  geometry = TRUE # Get spatial data
)

# Ensure spatial data is in WGS84 (EPSG:4326) for Leaflet
income_data <- st_transform(income_data, crs = 4326)

# Define a color palette for the income values
income_pal <- colorNumeric(
  palette = "YlGnBu", # Yellow-Green-Blue color scheme
  domain = income_data$estimate
)


# Create Leaflet interactive map
myMap <- leaflet(income_data) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%  # Use a light basemap
  addPolygons(
    fillColor = ~income_pal(estimate),
    color = "black",
    weight = 0.5,
    smoothFactor = 0.3,
    fillOpacity = 0.6,
    label = ~paste(NAME, "<br>Median Income: $", format(estimate, big.mark = ",")),
    highlightOptions = highlightOptions(
      weight = 2,
      color = "red",
      fillOpacity = 0.9,
      bringToFront = TRUE
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = income_pal,
    values = income_data$estimate,
    title = "Median Household Income",
    labFormat = labelFormat(prefix = "$")
  ) %>%
  addControl("<strong>Iowa Median Household Income (2023)</strong>", position = "topright", className = "leaflet-control-title")

myMap



install.packages("htmlwidgets")
library(htmlwidgets)

# Save the map as an HTML widget - however make sure you have set your working directory first!
saveWidget(myMap, file = "IowaHouseholdIncome_v2.html")


