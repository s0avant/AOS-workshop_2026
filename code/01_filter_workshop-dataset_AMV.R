#------------------------------------------------------------------------------#
#         auk Filtering Workflow: Subset Dataset for AOS 2026 Workshop         #
#                      Aimee M. Van Tatenhove 06/11/2026                       #
#------------------------------------------------------------------------------#
rm(list = ls())
library(tidyverse)
library(auk)
library(cowplot)
library(terra)
library(sf)
source("code/custom-functions.R")
set_theme(custom.theme())

# IF ON WINDOWS, MUST INSTALL CYGWIN TO GET AWK (a.k.a. GAWK)
# https://www.cygwin.com/install.html

#------------------------------------------------------------------------------#
# Explore small example datasets ----
#------------------------------------------------------------------------------#
# Load EBD and effort files
## Set paths for EBD & effort data in
in_ebd_small <- "data/ebd_example-small.txt"
in_effort_small <- "data/effort_example-small.txt"

## Smallish files, so we can load into R memory directly
get.filesize(in_ebd_small)
get.filesize(in_effort_small)

## Read in files
ebd_small <- read_ebd(in_ebd_small) # Takes ~25 seconds
effort_small <- read_sampling(in_effort_small) # Takes ~3 seconds

# Explore variables in these datasets
glimpse(ebd_small)
glimpse(effort_small)

summary(ebd_small)
summary(effort_small)

unique(ebd_small$common_name)
mean(effort_small$effort_distance_km, na.rm = TRUE)

## EXERCISE #1: (5 minutes) ----
# Explore other variables in these datasets. How do the two datasets differ?
# If you're unsure about any of the variables, consult the metadata document:
# ("eBird_Basic_Dataset_Metadata_v1.16.pdf")



# Even "small" datasets are quite large! Let's visualize some variables
## Observations dataset
ggplot(ebd_small) +
  geom_bar(aes(x = state)) +
  ggtitle("Observations by US State") +
  xlab("US state") + ylab("Count")

ggplot(ebd_small) +
  geom_bar(aes(x = state, color = common_name, fill = common_name)) +
  ggtitle("Observations by US State and Species") +
  xlab("US state") + ylab("Count") +
  labs(color = "Species",
       fill = "Species") 

ggplot(ebd_small) +
  geom_bar(aes(x = observation_date, color = common_name, fill = common_name)) +
  ggtitle("Observation Date by Species") +
  xlab("Checklist date") + ylab("Count") +
  labs(color = "Species",
       fill = "Species")

## Effort dataset
ggplot(effort_small) +
  geom_bar(aes(x = observation_type)) +
  ggtitle("Observation Type") +
  xlab("Type") + ylab("Count")

ggplot(effort_small) + # You can safely ignore the plotting error here
  geom_bar(aes(x = duration_minutes)) +
  ggtitle("Checklist Duration") +
  xlab("Duration in minutes") + ylab("Count")

## EXERCISE #2: (10 minutes) ----
# Visualize a variable of interest that we haven't explored yet



# Taxonomic rollup
## By default, auk "rolls up" subspecies information to their species-level
## taxonomy. We can change this default to import all taxonomic categories.
## Read in files
ebd_small_norollup <- read_ebd(in_ebd_small, rollup = FALSE) # Takes ~25 seconds

## Compare with original EBD object
unique(ebd_small$category) # Original
unique(ebd_small_norollup$category) # Not rolled up

## Rollup taxonomy
ebd_small_rollup <- auk_rollup(ebd_small_norollup)

## Compare with original EBD object; should be identical
unique(ebd_small$category) # Original
unique(ebd_small_rollup$category) # Rolled up

## Visualize species taxonomies
plot_grid(
  ggplot(ebd_small_norollup) +
  geom_bar(aes(x = state, color = common_name, fill = common_name)) +
    ggtitle("Observations by US State",
            subtitle = "Taxonomy before rollup") +
    xlab("US state") + ylab("Count") +
  labs(color = "Species",
       fill = "Species"),
  
  ggplot(ebd_small_rollup) +
    geom_bar(aes(x = state, color = common_name, fill = common_name)) +
    ggtitle("Observations by US State",
            subtitle = "Taxonomy after rollup") +
    xlab("US state") + ylab("Count") +
    labs(color = "Species",
         fill = "Species"),
  ncol = 2)

# Pipes
## Pipes come in two flavors: base "|>" and magrittr (tidyverse) "%>%"
## We will use base pipes today
## Example: no pipes (stepwise)
tmp1 <- subset(effort_small, !is.na(duration_minutes))
tmp1 <- transform(tmp1, duration_hours = duration_minutes / 60)
duration_hours <- tmp1$duration_hours
duration_max_no_pipe <- max(duration_hours)

duration_max_no_pipe

## Example: with base R pipe
duration_max_pipe <- effort_small |>
  subset(!is.na(duration_minutes)) |>
  transform(duration_hours = duration_minutes / 60) |>
  _$duration_hours |> # "_" passes object to next line of code
  max()

duration_max_pipe

## EXERCISE #3: (5 minutes) ----
# Practice manipulating example datasets using base R pipes



#------------------------------------------------------------------------------#
# Set and execute filters on full (large) datasets ----
#------------------------------------------------------------------------------#
# Set paths for raw EBD & effort data in
## Large files, so we DON'T want to read these directly into R memory
in_ebd <- "data/ebd_filtered_AOS_2026.txt"
in_effort <- "data/effort_filtered_AOS_2026.txt"

get.filesize(in_ebd)
get.filesize(in_effort)

# Define auk filters for checklist data
## For simplicity, ignore effort data for now (presence-only data)
filters1 <-
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Species: common and scientific names can be mixed
  auk_species(species = "American Woodcock") 

filters1

## Can also define filters outside of pipeline; useful for complicated filters
species <- "amewoo"
species_names <- ebird_species(species, type = "common")
species_names

filters2 <-
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Species: common and scientific names can be mixed
  auk_species(species = species_names) 

filters2 # Should look identical to filters1

# Apply filters to EBD object
## Call AWK to execute filters; takes ~30 seconds
presence_out <- auk_filter(filters2,
                           file = "data/ebd_filtered_amewoo_presence.txt",
                           overwrite = TRUE) |>
  # Read filtered data into R environment
  read_ebd()

# Explore variables in filtered dataset
glimpse(presence_out)

ggplot(presence_out) +
  geom_bar(aes(x = state, color = common_name, fill = common_name)) +
  ggtitle("Observations by US State and Species") +
  xlab("US state") + ylab("Count") +
  labs(color = "Species",
       fill = "Species") 

# Define auk filters for checklist AND effort data (presence-absence data)
## More complicated filters
filters_zerofill1 <-
  # Set EBD & effort file paths
  auk_ebd(in_ebd, file_sampling = in_effort) |>
  # Species: common and scientific names can be mixed
  auk_species(species = species_names) |>
  # State: two-part 4-6 character codes
  ## (2-letter ISO country code & 1-3 character state code). E.g., "US-NY"
  auk_state(state = "US-MA") |>
  # Date: use standard ISO date format `"YYYY-MM-DD"`
  auk_date(date = c("2012-01-01", "2012-12-31")) |>
  # Time: 24h format with beginning and end times
  auk_time(start_time = c("17:00", "23:00")) |>
  # Complete: all species seen or heard are recorded (important!)
  auk_complete()

# Apply filters to EBD & effort objects
## Note: We can also define output file names outside of pipeline
out_ebd <- "data/ebd_filtered_amewoo_presabs.txt"
out_effort <- "data/effort_filtered_amewoo_presabs.txt"

## Call AWK to execute filters; takes ~65 seconds
presabs_out <- auk_filter(filters_zerofill1,
                          file = out_ebd,
                          file_sampling = out_effort,
                          overwrite = TRUE) |>
  # Read filtered data into R environment
  read_ebd()

glimpse(presabs_out) # EBD and effort datasets are now single object

# Compare file sizes between unfiltered & filtered datasets
## GB = KB x 1,048,576
get.filesize(in_ebd) # Original
get.filesize(out_ebd) # Filtered; much smaller!
get.filesize(in_effort) # Original
get.filesize(out_effort) # Filtered; much smaller!

## EXERCISE #4: (15 minutes) ----
# Apply your own filters to EBD & effort objects. We will use these files for the
# remainder of workshop. What are you interested in exploring?
# Any of the following filters can be applied:
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

## Define auk filters for checklist AND effort data (presence-absence data)
filters_zerofill2 <-
  # Set EBD & effort file paths
  auk_ebd(in_ebd, file_sampling = in_effort)    ### FABI: do you think we should also include auk_complete() or let them remember they need to use it?
  # Add other filters of interest below with |>
  
## Apply filters to EBD & effort objects

## Explore variables in filtered dataset



#------------------------------------------------------------------------------#
# Zerofill checklists ----
#------------------------------------------------------------------------------#
# eBird observations tell us where a species is present, but we also need
# information on where a species is absent to understand what habitats are
# important, how ecological change affects species distributions, etc.
# Zero filling uses complete eBird checklists that report no observations of a
# species to generate species absence data at those checklist locations.

# Set paths for raw EBD & effort data in and out
## Remember, these contain both species presences and absences
in_ebd <- "data/ebd_filtered_amewoo_presabs.txt"
in_effort <- "data/effort_filtered_amewoo_presabs.txt"

# Execute zero-filtering function
## Run time varies depending on the filters you chose; should be < 2 minutes
## "collapse = FALSE" produces two lists and is efficient for storage because
## checklist information isn’t duplicated. "collapse = TRUE" produces a single
## data frame that is easier to manipulate for analysis. We will collapse.
presabs_zf <-
  auk_zerofill(in_ebd,
               in_effort,
               collapse = TRUE)

glimpse(presabs_zf)

# Transform effort variables for easier filtering & comprehension
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
## It's often a good idea to reduce detectability variation between checklists
## by imposing constraints on the effort variables. You can think of this as
## partially standardizing the observation process. Let's impose some filters:
## Traveling or stationary counts with fewer than 10 observers
## Duration <= 5 h and >= 10 minutes, length <= 10 km, speed <= 50km/h
zf_eff_filtered <- zf_eff_transf |>
  filter(observation_type %in% c("Stationary", "Traveling"),
         !is.na(effort_hours), effort_hours >= 0.17, effort_hours <= 5,
         !is.na(effort_distance_km), effort_distance_km <= 10,
         effort_speed_kmph <= 50,
         number_observers <= 10)

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

## EXERCISE #5 (5 minutes) ----
# Pick one of the other effort variables and explore remaining variation



#------------------------------------------------------------------------------#
# Maps ----
#------------------------------------------------------------------------------#
# Spatialize zerofilled object
zf_sf <- zf_eff_filtered |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)

# Load GIS and shapefile data
ee_landcover <- read.csv("data/gis/EarthEnv-landcover-northeast.csv")

usa_sf <- read_sf("data/gis/usa-all-states.shp") |>
  st_transform(crs = 4326)

ne_states_sf <- read_sf("data/gis/usa-northeast-states.shp") |>
  st_transform(crs = 4326)

# Plot results, colored by species presence & absence
## Basic map
ggplot() +
  geom_sf(data = ne_states_sf) +
  geom_sf(data = zf_sf, aes(color = species_observed), alpha = 0.5)

# Clip checklists to land
zf_clip_sf <- st_intersection(zf_sf, ne_states_sf)

## Clipped map
ggplot() +
  geom_sf(data = usa_sf) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) +
  coord_sf(xlim = c(-74, -67),
           ylim = c(38, 47.5)) +
  ggtitle("eBird Observations by Checklist") +
  labs(color = "Species observed")

## Add landcover data
ggplot() +
geom_raster(data = ee_landcover,
            aes(x = x, y = y,
                fill = class_names)) +
  geom_sf(data = ne_states_sf, color = "grey30", fill = NA) +
  geom_sf(data = zf_clip_sf, aes(color = species_observed), alpha = 0.5) #+
  # scale_fill_manual(breaks = 1:12,
  #                   labels = landcover_palette$class_names,
  #                   values = landcover_palette$colors)

## Exercise #6: (10 minutes) ----
# Choose one of the other environmental variables and make a map. Does
# the spatial pattern match what you know about the region? Hint: "zoom" your
# map by setting "coord_sf(xlim = c(), ylim = c())" to a smaller range


