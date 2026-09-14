#------------------------------------------------------------------------------#
#                      auk Full Workflow:  AOS 2026 Workshop                   #
#                      Aimee M. Van Tatenhove & Fabiola Rodríguez Vásquez      #
#                                       06/17/2026.                            #
#------------------------------------------------------------------------------#
rm(list = ls())

# !REMEMBER! IF ON WINDOWS, MUST INSTALL CYGWIN TO GET AWK (a.k.a. GAWK)
# https://www.cygwin.com/install.html

#------------------------------------------------------------------------------#
# Script 01: Import and explore ebd data----
#------------------------------------------------------------------------------#
library(tidyverse)
library(auk)
source("code/custom-functions.R")
set_theme(custom.theme())

# Section 1: Load EBD (eBird Basic Dataset) and effort (sampling) files
## Set paths for EBD & effort data
in_ebd_small <- "./data/eBird/ebd_filtered_cam_AOS_2026.txt"
in_effort_small <- "./data/eBird/effort_filtered_cam_AOS_2026.txt"

## Smallish files, so we can load into R memory directly
get.filesize(in_ebd_small)
get.filesize(in_effort_small)

## How do we read the files
?read_ebd()

## Apply read_ebd()
ebd <- read_ebd(in_ebd_small) 
effort <- read_sampling(in_effort_small) 

## What are these files?
nrow(ebd) # Data of observations of species 
nrow(effort) # All sampling events

# Section 2: Explore the dataset
class(ebd)
glimpse(ebd)
glimpse(effort)
unique(ebd$common_name)

## --Exercise--
## Using the appropriate function of those above or other determine how many countries appear in the ebd dataset?


## Explore how many observations you have for main data attributes: location and species
table(ebd$country)
table(ebd$common_name)

## Explore visually by using ggplot's geom_bar which counts occurrences for a category
## Observations dataset
ggplot(ebd) +
  geom_bar(aes(x = country)) +
  ggtitle("Observations by country") +
  xlab("Country") + ylab("Count")

ggplot(ebd) +
  geom_bar(aes(x = country, color = common_name, fill = common_name),position=position_dodge()) +
  ggtitle("Observations by Country and Species") +
  xlab("Country") + ylab("Count") +
  labs(color = "Species",
       fill = "Species") 

ggplot(ebd) +
  geom_bar(aes(x = observation_date, color = common_name, fill = common_name)) +
  ggtitle("Observation Date by Species") +
  xlab("Checklist date") + ylab("Count") +
  labs(color = "Species",
       fill = "Species")

## Effort dataset
ggplot(effort) +
  geom_bar(aes(x = observation_type)) +
  ggtitle("Observation Type") +
  xlab("Type") + ylab("Count")

ggplot(effort) + # You can safely ignore the plotting error here
  geom_bar(aes(x = duration_minutes)) +
  ggtitle("Checklist Duration") +
  xlab("Duration in minutes") + ylab("Count")

# Section 3: Pipes- the building block of the 'auk' workflow 
## Pipes come in two flavors: base "|>" and magrittr (tidyverse) "%>%"
## We will use base pipes today
## Example: no pipes (stepwise)
tmp1 <- subset(effort, !is.na(duration_minutes))
tmp1 <- transform(tmp1, duration_hours = duration_minutes / 60)
duration_hours <- tmp1$duration_hours
duration_max_no_pipe <- max(duration_hours)

duration_max_no_pipe

## Example: with base R pipe 
duration_max_pipe <- effort |>
  subset(!is.na(duration_minutes)) |>
  transform(duration_hours = duration_minutes / 60) |>
  _$duration_hours |> # "_" passes object to next line of code
  max()

duration_max_pipe

## STOPPING POINT- QUESTIONS?


#------------------------------------------------------------------------------#
# Script 02: Set and execute filters in 'auk' ----
#------------------------------------------------------------------------------#
library(tidyverse)
library(auk)
source("code/custom-functions.R")

# Section 1:  Set paths for raw EBD & effort data in
in_ebd <- "data/eBird/ebd_filtered_cam_AOS_2026.txt"

## Observe how large these files are compared to those from the previous section
get.filesize(in_ebd) 

# Section 2: Define auk filters for checklist data
?auk_ebd() #The first function of the filtering process is always this one! 
?auk_species() #This function works to filter species, see the pattern? auk_
## Get familiar with a few essential functions we will use below: auk_unique, auk_complete, auk_rollup

## Filters are set up using the pipe to sequence the attributes of the data we want
filters1 <-
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Species: common and scientific names can be mixed
  auk_species(species = "Crested Guan") 

filters1

## OR define filters outside of pipeline; useful for complicated filters
species <- "Crested Guan"
species_names <- ebird_species(species, type = "common")
species_names

filters2 <-
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Species: common and scientific names can be mixed
  auk_species(species = species_names) 

filters2 # Should look identical to filters1

## Exploring tailored filters: Thinking about sampling design and reducing variation
filters3<-auk_ebd(in_ebd) |>
  auk_species(species = species_names) |>
  auk_country("Honduras")|>
  # Date: use standard ISO date format `"YYYY-MM-DD"`
  auk_date(date = c("*-01-01", "*-12-31")) |>
  # Time: 24h format with beginning and end times
  auk_time(start_time = c("06:00", "14:00")) 

filters3

##---Exercise---
# Design your own filters and print them out. The collection of filters can be thought of as the 'sampling design' of this eBird data as it describes time, place and other factors tailored to a question.

#filters4<-

# Section 3: Apply filters to EBD object
## Call AWK to execute filters; time depends on the size of your file 
presence_out <- auk_filter(filters3,
                           file = "data/eBird/ebd_filtered_cregua_presence.txt",
                           overwrite = TRUE) |>
  # Read filtered data into R environment
  read_ebd()


#------------------------------------------------------------------------------#
# Script 03: Using the sampling and ebd files to zerofill ----
#------------------------------------------------------------------------------#

library(tidyverse)
library(auk)
library(lubridate)
library(cowplot)
library(sf)
source("code/custom-functions.R")
set_theme(custom.theme())

# Section 1:  Set paths for raw EBD & effort data in
in_ebd <- "data/eBird/ebd_filtered_us_AOS_2026.txt"
in_effort <- "data/eBird/effort_filtered_us_AOS_2026.txt"

## Observe how large these files are compared to those from the previous section
get.filesize(in_ebd) 
get.filesize(in_effort)

## Read these files 

# Section 2: Explore and define new auk filters for checklist AND effort data 
species_names=c("amewoo")

filters <-
  # Set EBD & effort file paths
  auk_ebd(in_ebd, file_sampling = in_effort) |>
  # Species: common and scientific names can be mixed
  auk_species(species = species_names) |>
  # State: two-part 4-6 character codes
  ## (2-letter ISO country code & 1-3 character state code). E.g., "US-NY"
  auk_state(state = "US-MA") |>
  # Date: use standard ISO date format `"YYYY-MM-DD"`
  auk_date(date = c("2025-01-01", "2025-12-31")) |>
  # Time: 24h format with beginning and end times
  auk_time(start_time = c("17:00", "23:00")) |>
  # Complete: all species seen or heard are recorded (important!)
  auk_complete()
filters

# Apply filters to EBD & effort objects

## Note: We can also define output file names outside of pipeline
f_ebd <- "data/eBird/ebd_filtered_amewoo_presabs.txt"
f_effort <- "data/eBird/effort_filtered_amewoo_presabs.txt"

## Call AWK to execute filters
f_ebd_effort <- auk_filter(filters,
                          file = f_ebd,
                          file_sampling = f_effort,
                          overwrite = TRUE) |>
  read_ebd()

glimpse(f_ebd_effort) # EBD and effort datasets are now single object filtered by sampling event which will allow us to have necessary information to generate a "presence-absence" data set

# Section 3: Zerofill to generate a "presence-absence" data set

## Execute zero-filtering function
presabs_zf <-auk_zerofill(f_ebd,
              sampling_events=f_effort,
               collapse = TRUE)

glimpse(presabs_zf$observation_count) #observation
glimpse(presabs_zf$sampling_event_identifier) #for each sampling event

# Section 4: Transform effort variables for easier filtering & comprehension
zf_eff_transf <- presabs_zf |>
  mutate(
    # Convert count to integer and X to NA (ignore NA warning!)
    ## X indicates species was present, but a number wasn't recorded
    observation_count = as.integer(observation_count),
    # effort_distance_km to 0 for stationary counts
    effort_distance_km = if_else(observation_type == "Stationary",
                                 0, effort_distance_km),
    # Convert duration to hours
    effort_hours = duration_minutes / 60,
    # Convert speed km/h
    effort_speed_kmph = effort_distance_km / effort_hours,
    # Split date into year and day of year
    year = year(observation_date),
    day_of_year = yday(observation_date)
  )

# Apply effort filters
zf_eff_filtered <- zf_eff_transf |>
  filter(observation_type %in% c("Stationary", "Traveling"),
         !is.na(effort_hours), effort_hours >= 0.17, effort_hours <= 5,
         !is.na(effort_distance_km), effort_distance_km <= 10,
         effort_speed_kmph <= 50,
         number_observers <= 10)

# Compare the filtered and transformed datasets
table(zf_eff_transf$species_observed)
table(zf_eff_filtered$species_observed)

# Visualize before and after effort standardization
plot_grid(
  ggplot(zf_eff_transf) +
    aes(x = effort_hours) +
    geom_histogram(binwidth = 0.5,
                   aes(y = after_stat(count / sum(count)))) +
    scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
    labs(x = "Duration (hours)",
         y = "% of eBird checklists",
         title = "Distribution of eBird checklist duration",
         subtitle = "Before effort filtering"),
  
  ggplot(zf_eff_filtered) +
    aes(x = effort_hours) +
    geom_histogram(binwidth = 0.5,
                   aes(y = after_stat(count / sum(count)))) +
    scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
    labs(x = "Duration (hours)",
         y = "% of eBird checklists",
         title = "Distribution of eBird checklist duration",
         subtitle = "After effort filtering"),
  ncol = 2)


# Section 5: Extra- mapping observations
# Spatialize zerofilled object
zf_sf <- zf_eff_filtered |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Load GIS and shapefile data
ee_landcover <- read.csv("data/gis/EarthEnv-landcover-northeast.csv") |>
  left_join(landcover_palette) # Add map colors for nice plotting

ne_states_sf <- read_sf("data/gis/usa-northeast-states.shp") |>
  st_transform(crs = 4326)

# Plot results, colored by species presence & absence
## Basic map
ggplot() +
  geom_sf(data = ne_states_sf) +
  geom_sf(data = zf_sf, aes(color = species_observed), alpha = 0.5)

# Clip checklists to land; safe to ignore warning message
zf_clip_sf <- st_intersection(zf_sf, ne_states_sf)

## Clipped map
ggplot() +
  geom_sf(data = usa_sf) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  coord_sf(xlim = c(-74, -67), ylim = c(38, 47.5)) +
  ggtitle("eBird Observations by Checklist") +
  labs(color = "Species observed")

## Add landcover data
ggplot() +
  geom_tile(data = ee_landcover,
              aes(x = x, y = y,
                  fill = class_names), alpha = 0.7) +
  geom_sf(data = ne_states_sf, color = "grey30", fill = NA) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  scale_fill_manual(breaks = unique(ee_landcover$class_names),
                    values = unique(ee_landcover$colors)) +
  labs(color = "Species observed",
       fill = "Landcover class")

# Try zooming in (using coord_sf) to see if you can identify any associations
## with observations of your species and landcover types.
ggplot() +
  geom_tile(data = ee_landcover,
            aes(x = x, y = y,
                fill = class_names), alpha = 0.7) +
  geom_sf(data = ne_states_sf, color = "grey30", fill = NA) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  coord_sf(xlim = c(-72.9, -72.3), ylim = c(42, 42.5)) + # Adjust to your liking
  scale_fill_manual(breaks = unique(ee_landcover$class_names),
                    values = unique(ee_landcover$colors)) +
  xlab("Longitude") + ylab("Latitude") +
  labs(color = "Species observed",
       fill = "Landcover class")

#------------------------------------------------------------------------------#
# Script 04: Practical instructions----
#------------------------------------------------------------------------------#

## Clean your environment first. Use this practice to put together the 'auk' workflow:

## Set the path to ebd and sampling files used in this workshop, use the ones your prefer.

## Identify and set the filters that would interest you. Think about a hypothetical research question including species, regions or effort types.

## Generate a new dataset for your analyses by applying the filters, read this new data and explore it. If you wish zerofill this data to generate a presence-absence dataset.


## auk functions glossary:
# auk_species(): filter by species using common or scientific names.
# auk_country(): filter by country using the standard English names or ISO 2-letter country codes.
# auk_state(): filter by state using eBird state codes, see ?ebird_states.
# auk_bcr(): filter by Bird Conservation Region (BCR) using BCR codes, see ?bcr_codes.
# auk_bbox(): filter by spatial bounding box, i.e. a range of latitudes and longitudes in decimal degrees.
# auk_date(): filter to checklists from a range of dates. To extract observations from a range of dates, regardless of year, use the wildcard “*” in place of the year, e.g. date = c("*-05-01", "*-06-30") for observations from May and June of any year.
# auk_last_edited(): filter to checklists from a range of last edited dates, useful for extracting just new or recently edited data.
# auk_protocol(): filter to checklists that following a specific search protocol, either stationary, traveling, or casual.
# auk_project(): filter to checklists collected as part of a specific project (e.g. a breeding bird survey).
# auk_time(): filter to checklists started during a range of times-of-day.
# auk_duration(): filter to checklists with observation durations within a given range.
# auk_distance(): filter to checklists with distances traveled within a given range.
# auk_breeding(): only retain observations that have an associate breeding bird atlas code.
# auk_complete(): only retain checklists in which the observer has specified that they recorded all species seen or heard. It is necessary to retain only complete records for the creation of presence-absence data, because the “absence”” information is inferred by the lack of reporting of a species on checklists.

## Begin...
