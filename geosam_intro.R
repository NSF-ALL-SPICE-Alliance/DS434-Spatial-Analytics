library(geosam)
library(sf)
library(terra)

Sys.setenv(PROJ_LIB = "/opt/homebrew/Cellar/proj/9.4.1/share/proj")

# Try the detection again
field <- sam_detect(
  bbox = c(-97.372, 32.707, -97.366, 32.712),
  text = "football field",
  source = "mapbox",
  zoom = 17
)


plot(field)

sam_view(field)


car <- sam_detect(
  bbox = c(-97.372, 32.707, -97.366, 32.712),
  text = "car",
  source = "mapbox",
  zoom = 17
)

plot(car)
sam_view(car)


tree <- sam_detect(
  bbox = c(-97.372, 32.707, -97.366, 32.712),
  text = "tree",
  source = "mapbox",
  zoom = 17
)

plot(tree)
sam_view(tree)


result <- sam_explore(source = "mapbox")


sam_result <- sam_explore(
  center = c(-97.373, 32.719),
  zoom = 16
)



solar_panels <- sam_detect(
  bbox = c(-157.815, 21.285, -157.810, 21.290),
  text = "solar panel",
  source = "mapbox",  # or "esri" if you don't have Mapbox token
  zoom = 19  # High zoom for rooftop detail
)

plot(solar_panels)
sam_view(solar_panels)


solar_sf <- sam_as_sf(solar_panels)

library(mapgl)

maplibre_view(solar_sf)
