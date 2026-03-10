## ----Install-packages---------------------------------------------------------
# Load one at a time
install.packages("tidycensus")
install.packages("tidyverse")
install.packages("leaflet") 
install.packages("htmlwidgets")
install.packages("htmltools")
#loads two at a time
install.packages(c("sf", "tigris"))

## ----Load Libraries-----------------------------------------------------------
# Load one at a time
library(tidycensus)
library(tidyverse)
library(sf)
library(tigris)
library(leaflet)
library(htmlwidgets)
library(htmltools)


## ----Get the ACS5 Data--------------------------------------------------------
# For ACS5 find a variable of interest.
ACS5_2024_variables <- load_variables(2024, "acs5", cache = TRUE)
View(ACS5_2024_variables)


#	Replace the B19013_001 with your own indicator
# Note I called the result myVariable
# B19013_001 is Median household income in the past 12 months
#  (in 2024 inflation-adjusted dollars)

myVariable <- get_acs(
  survey = "acs5",
  year = 2024,
  variables = "B19013_001",
  state = "Iowa", 
  county = "Boone", #remove this line will get entire state
  geography = "tract", #could use county, tract, block group, place
  output = "wide",
  geometry = TRUE
)
# Look at the data frame and notice the number of results!
view(myVariable)

#view as a map
# Quick plots of all four columns as a preview
plot(myVariable)

# quick plot of just the estimate
plot(myVariable["B19013_001E"])

# Optionally if you want to use this in Tableau you can save it as a geoJSON
# but make sure you have first gone to session --> Set Working Directory!
st_write(myVariable, "someFileName.geojson")




## ----Alternative if you wanted just cities in a county------------------------
# Get all places in the state with geometry
myVariable <- get_acs(
  survey = "acs5",
  year = 2024,
  variables = "B19013_001",
  state = "Iowa", 
  geography = "place", #could use county, tract, block group, place
  output = "wide",
  geometry = TRUE
)

# Get the county boundary for Story County
county <- counties(state = "IA", cb = TRUE) |>
  filter(NAME == "Story")

# Spatially filter places that intersect the county
cities_in_county <- myVariable[st_intersects(myVariable, county, sparse = FALSE)[,1], ]
plot(cities_in_county["B19013_001E"]) #just to preview the data
myVariable <- cities_in_county






## ----Leaflet Mapping-----------------------------------------------------------

# Ensure spatial data is in WGS84 (EPSG:4326) for Leaflet
myVariableTransform <- st_transform(myVariable, crs = 4326)



# Define a color palette to use for the values
# You will need to replace B19013_001E with the column name found in the list
# of the variable you want to map. You need to adjust this throughout 
# the rest of the leaflet mapping code. 

# As for the colors you can adjust the value of the palette =
# "Blues" (Various shades of blue)
# "Reds" (Various shades of red)
# "Greens" (Various shades of green)
# "Oranges" (Various shades of orange)
# "Purples" (Various shades of purple)
# "BuGn" (Blue-Green gradient)
# "RdYlBu" (Red-Yellow-Blue diverging)
# "Viridis" (Colorblind-friendly, yellow to blue)

income_pal <- colorNumeric(
  palette = "YlGnBu", # Yellow-Green-Blue color scheme
  domain = myVariableTransform$B19013_001E
)

# A manually defined color pallete can alos be created
# income_pal <- colorNumeric(
#  palette = c("#440154", "#21908C", "#FDE725"),  # Dark purple → Teal → Yellow
#  domain = myVariableTransform$B19013_001E
# )


# Create Leaflet interactive map
myMap <- leaflet(myVariableTransform) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%  # Use a light basemap
  addPolygons(
    fillColor = ~income_pal(B19013_001E), #replace B19013_001Ewith your  value
    color = "black", #Outline color - you can select a color
    weight = 0.5, #line thinckness is 0 - 1
    smoothFactor = 0.3,
    fillOpacity = 0.6,  #transparency value of 0-1, you can edit this
    #Prof Seeger will provide more detail on this label in an updated version
    #replace B19013_001E with your  value
    label = ~paste0(NAME, " Median Income: $", format(B19013_001E, big.mark = ",")),
    labelOptions = labelOptions(
      sticky = FALSE,  # Ensures tooltips disappear when not hovering
      interactive = TRUE,  # Ensures tooltips respond to mouse hover
      opacity = 1,  # Keeps tooltips visible when hovered
      style = list(
        "background-color" = "white", #optionally change if it fits your design
        "border" = "1px solid black", #You could make this larger, but don't
        "padding" = "5px" #distance from text to edge of box
      )
    ),
    highlightOptions = highlightOptions(
      weight = 2,
      color = "red", #the outline color of the selected feature
      fillOpacity = 0.9, #0-1 transparency
      bringToFront = TRUE
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = income_pal,
    values = myVariableTransform$B19013_001E, #replace B19013_001E with your  value
    title = "Median Household Income",   #you will need to edit this!
    labFormat = labelFormat(prefix = "$")
  ) %>%
  addControl("<strong>Iowa Median Household Income (2023)</strong>", position = "topright", className = "leaflet-control-title")
#replace the text above

myMap

# make sure and save and set session to location of local file!!!
# Save the map as an HTML widget
saveWidget(myMap, file = "wednesdayDemo.html") #name the file
