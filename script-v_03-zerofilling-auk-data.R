#------------------------------------------------------------------------------#
#                             AOS 2026 Workshop                                #
#                       03. Zerofilling auk data                               #
#                   Aimee Van Tatenhove & Fabiola Rodríguez                    #
#------------------------------------------------------------------------------#

# 3.1 Set section 3 R environment----
library(tidyverse)
library(auk)
library(lubridate)
library(cowplot)
library(sf)
source("custom-functions.R")

theme_set(custom.theme())

# 3.2 Setting the path----
## Set the paths for the US AOS 2026 dataset:
in_ebd <- 
in_effort <- 
  
## Observe how large these files are compared to those from the previous section
get.filesize(in_ebd) 
get.filesize(in_effort)

# 3.3 Setting filters----
## Prepare the species filtering object for the American Woodcock
species_names = c("amewoo")

filters <-
  ## Set EBD & effort file paths:
  
  ## Set the species object filter:
  
  ## Set a filter for the US state of Massachusetts. E.g., "US-NY"
  
  ## Set a filter for date range between January 1, 2025 and December 12, 2025:
  
  ## Set a filter for time range between 5 and 11 pm (Time follows a 24h format with beginning and end times):
  
  ## Always call auk_complete: all species seen or heard are recorded (important!)
  auk_complete()

# 3.4 Apply the filters----

## Set the path and filename for the ebd and effort output files:
f_ebd <- "data/ebd_filtered_amewoo_presabs.txt"
f_effort <- "data/effort_filtered_amewoo_presabs.txt"

## Filter the data using the filtering object, indicate the output files: 
f_ebd_effort <- auk_filter() |>
  ## Call read_ebd
  read_ebd()

glimpse(f_ebd_effort) 
filters

# 3.5 Apply zerofill----
## Call zerofill including the effort and ebd files:
presabs_zf <-auk_zerofill()

glimpse(presabs_zf)

glimpse(presabs_zf$observation_count) # observation
glimpse(presabs_zf$checklist_id) # for each sampling event

range(presabs_zf$observation_count)

# 3.6 Process zerofilled dataset----

## Clean presence-absence dataset
zf_eff_transf <- presabs_zf |>
  mutate(
    # Convert count to integer and X to NA (ignore NA warning!):
    observation_count = as.integer(observation_count),
    # Effort_distance_km to 0 for stationary counts:
    effort_distance_km = if_else(observation_type == "Stationary",
                                 0, effort_distance_km),
    # Convert duration to hours:
    effort_hours = duration_minutes / 60,
    # Convert speed km/h:
    effort_speed_kmph = effort_distance_km / effort_hours,
    # Split date into year and day of year:
    month = month(observation_date),
    day_of_year = yday(observation_date)
  )

## Explore balance of observations
table(zf_eff_transf$species_observed)

## Plot effort by distance
ggplot(zf_eff_transf) +
  geom_bar(aes(x = effort_distance_km)) +
  ggtitle("Sampling effort: distance covered") +
  xlab("Distance (km)")

## Plot effort by hours
ggplot(zf_eff_transf) +
  geom_bar(aes(x = effort_hours)) +
  ggtitle("Sampling effort: hours of observation") +
  xlab("No. hours")

## Plot effort by period
ggplot(zf_eff_transf) +
  geom_bar(aes(x = observation_date)) +
  ggtitle("Sampling effort: month") +
  xlab("Month")

## Tweaking filters
zf_eff_filtered <- zf_eff_transf |>
  # Filter to include only stationary and traveling protocols:
  filter(observation_type %in% c("", ""),
         # To include between up to 5 hours:
         !is.na(effort_hours), effort_hours >= 0.17, effort_hours <= ,
         # To include distances up to 10 km:
         !is.na(effort_distance_km), effort_distance_km <= ,
         # To include up to 50 km/h:
         effort_speed_kmph <= ,
         # To include up to 10 observers:
         number_observers <= )

# Compare the filtered and transformed datasets
table(zf_eff_transf$species_observed)
table(zf_eff_filtered$species_observed)

## Checking dataset coverage
plot_grid(
  ggplot(zf_eff_transf) +
    aes(x = effort_hours) +
    geom_histogram(binwidth = 0.5,
                   aes(y = after_stat(count / sum(count)))) +
    scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
    labs(x = "Duration (hours)",
         y = "% of eBird checklists",
         subtitle = "eBird checklists duration\nbefore effort filtering"),
  
  ggplot(zf_eff_filtered) +
    aes(x = effort_hours) +
    geom_histogram(binwidth = 0.5,
                   aes(y = after_stat(count / sum(count)))) +
    scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
    labs(x = "Duration (hours)",
         y = "% of eBird checklists",
         subtitle = "eBird checklists duration\nafter effort filtering"),
  ncol = 2)

## Final preparations for auk dataset
zf <- zf_eff_filtered |>
  # Select only columns that you would use in your analysis:
  select(checklist_id,
         latitude,
         longitude,
         observation_date,
         effort_distance_km,
         number_observers,
         scientific_name,
         observation_count,
         species_observed,
         effort_hours,
         month,
         day_of_year)

# 3.7 Visualization----
## Spatialize zerofilled object
zf_sf <- zf |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

## Load GIS and shapefile data
ee_landcover <- read.csv("data/gis/EarthEnv-landcover-northeast.csv") |>
  left_join(landcover_palette) # Add map colors for nice plotting

ne_states_sf <- read_sf("data/gis/usa-northeast-states.shp") |>
  st_transform(crs = 4326)

## Plot distribution of observations
ggplot() +
  geom_sf(data = ne_states_sf) +
  geom_sf(data = zf_sf, aes(color = species_observed), alpha = 0.5)

## Plot observations for sites of interest
state_sf <- ne_states_sf[ne_states_sf$NAME == "Massachusetts", ]
# Clip checklists to land; safe to ignore warning message
zf_clip_sf <- st_intersection(zf_sf, state_sf)

## Clipped map
ggplot() +
  geom_sf(data = state_sf) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  coord_sf(xlim = c(-74, -69), ylim = c(41, 43)) +
  ggtitle("eBird Observations by Checklist") +
  labs(color = "Species observed")

## Plotting observations with other spatial objects
ggplot() +
  geom_raster(data = ee_landcover,
              aes(x = x, y = y,
                  fill = class_names), alpha = 0.7) +
  geom_sf(data = ne_states_sf, color = "grey30", fill = NA) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  scale_fill_manual(breaks = unique(ee_landcover$class_names),
                    values = unique(ee_landcover$colors)) +
  xlab("Longitude") + ylab("Latitude") +
  labs(color = "Species observed",
       fill = "Landcover class")

ggplot() +
  geom_raster(data = ee_landcover,
              aes(x = x, y = y,
                  fill = class_names), alpha = 0.7) +
  geom_sf(data = ne_states_sf, color = "grey30", fill = NA) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  coord_sf(xlim = c(-73, -72), ylim = c(42, 42.5)) + # Adjust to your liking
  scale_fill_manual(breaks = unique(ee_landcover$class_names),
                    values = unique(ee_landcover$colors)) +
  xlab("Longitude") + ylab("Latitude") +
  labs(color = "Species observed",
       fill = "Landcover class")
