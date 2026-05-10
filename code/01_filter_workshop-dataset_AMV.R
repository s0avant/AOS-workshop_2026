#------------------------------------------------------------------------------#
#         auk Filtering Workflow: Subset Dataset for AOS 2026 Workshop         #
#                      Aimee M. Van Tatenhove 05/05/2026                       #
#            ---------------------------------------------------------         #
#       Start here for workshop; 00_filter_full-dataset_AMV.R already run      #
#------------------------------------------------------------------------------#
rm(list = ls())
library(tidyverse)
library(auk)

#------------------------------------------------------------------------------#
# Read in data ----
#------------------------------------------------------------------------------#
# Define filepath for EBD file
## Example only; modify filepath to access YOUR folder containing EBD data
# path <- "/Volumes/Eco Data/eBird_EBD_2026.05.05/ebd_US_smp_relMar-2026/" # Mac example
path <- "D:/eBird_EBD_2026.05.05/ebd_US_smp_relMar-2026/" # Windows example

# IF ON WINDOWS, MUST INSTALL CYGWIN TO GET AWK (AKA GAWK)
# https://www.cygwin.com/install.html

# Set paths for EBD & effort data in
in_ebd <- paste0(path, "ebd_filtered_AOS_2026.txt")
in_eff <- paste0(path, "eff_filtered_AOS_2026.txt")

# Set paths for EBD & effort data out
out_ebd <- paste0(path, "ebd_filtered_AOS_2026_amewoo.txt")
out_eff <- paste0(path, "eff_filtered_AOS_2026_amewoo.txt")

#------------------------------------------------------------------------------#
# Set and execute filters ----
#------------------------------------------------------------------------------#
# Define species of interest
species <- "amewoo"
species_names <- ebird_species(species, type = "common")

# Define regions of interest
states <- "US-MA"

## For checklist data only (presence-only data)
filters_presence <- 
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = states)

## For checklist AND sampling data (presence-absence data)
filters_zerofill <-
  # Set EBD & sampling file paths
  auk_ebd(in_ebd, file_sampling = in_eff) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = states) |>
  # Keep only complete checklists
  auk_complete()

# # Call AWK to filter presence-only data
a1 <- Sys.time() # Start timer; may take multiple hours
  # Execute filters
presence_out <- auk_filter(filters_presence,
             file = out_ebd,
             overwrite = TRUE) |>                                               ### REMOVE OVERWRITE?
  # Read filtered data into R environment
  read_ebd()
(runtime1 <- Sys.time() - a1) # End timer and save duration

# # Call AWK to filter presence-absence data
a2 <- Sys.time() # Start timer; may take multiple hours
  # Execute filters
presabs_out <- auk_filter(filters_zerofill,
             file = out_ebd,
             file_sampling = out_eff,
             overwrite = TRUE) |>                                               ### REMOVE OVERWRITE?
  # Read filtered data into R environment
  read_ebd()
(runtime2 <- Sys.time() - a2) # End timer and save duration

#------------------------------------------------------------------------------#
# Additional filters ----
#------------------------------------------------------------------------------#
amewoo_MA_2012 <- presence_out |> auk_ebd() |>
  # Species: common and scientific names can be mixed
  auk_species(species = species_names) |>
  auk_state(state = "US-MA") |>
  # Date: use standard ISO date format `"YYYY-MM-DD"`
  auk_date(date = c("2012-01-01", "2012-12-31")) |>
  # Time: 24h format
  auk_time(start_time = c("06:00", "09:00")) |>
  # Duration: length in minutes of checklists
  auk_duration(duration = c(0, 60)) |>
  # Complete: all species seen or heard are recorded
  auk_complete() |>
  # Execute filters
  auk_filter(file = "presence-test.txt") |>
  # Read filtered data into R environment
  read_ebd()




# Other options
# Any of the following filters can be applied:
# auk_species(): filter by species using common or scientific names.
# auk_country(): filter by country using the standard English names or ISO 2-letter country codes.
# auk_state(): filter by state using the eBird state codes, see ?ebird_states.
# auk_bcr(): filter by Bird Conservation Region (BCR) using BCR codes, see ?bcr_codes.
# auk_bbox(): filter by spatial bounding box, i.e. a range of latitudes and longitudes in decimal degrees. Formatted as `c(lng_min, lat_min, lng_max, lat_max)`
# auk_date(): filter to checklists from a range of dates. To extract observations from a range of dates, regardless of year, use the wildcard “*” in place of the year, e.g. date = c("*-05-01", "*-06-30") for observations from May and June of any year.
# auk_last_edited(): filter to checklists from a range of last edited dates, useful for extracting just new or recently edited data.
# auk_protocol(): filter to checklists that following a specific search protocol, either stationary, traveling, or casual.
# auk_project(): filter to checklists collected as part of a specific project (e.g. a breeding bird survey).
# auk_time(): filter to checklists started during a range of times-of-day.
# auk_duration(): filter to checklists with observation durations within a given range.
# auk_distance(): filter to checklists with distances travelled within a given range.
# auk_breeding(): only retain observations that have an associate breeding bird atlas code.
# auk_complete(): only retain checklists in which the observer has specified that they recorded all species seen or heard. It is necessary to retain only complete records for the creation of presence-absence data, because the “absence” information is inferred by the lack of reporting of a species on checklists.






















# Get checklist data
f_samp <- glue("{path}/ebd_US_relMar-2026_sampling.txt")
checklists_all <- read_sampling(f_samp)
glimpse(checklists_all)

# Observation data
f_ebd <- glue("{path}/ebd_US_smp_relMar-2026.txt")
observations_all <- read_ebd(f_ebd)
glimpse(observations_all)

# EXERCISE: Take some time to explore the variables in these datasets. If
# you're unsure about any of the variables, consult the metadata document that
# came with the data download ("eBird_Basic_Dataset_Metadata_v1.15.pdf").

#------------------------------------------------------------------------------#
# Shared checklists ----
#------------------------------------------------------------------------------#
# Import checklist data without collapsing shared checklists
checklists_shared <- read_sampling(f_sed, unique = FALSE)
# Identify shared checklists
checklists_shared |>
  filter(!is.na(group_identifier)) |>
  arrange(group_identifier) |>
  select(sampling_event_identifier, group_identifier)
# Collapse shared checklists
checklists_unique <- auk_unique(checklists_shared, checklists_only = TRUE)
nrow(checklists_shared)
nrow(checklists_unique)

#------------------------------------------------------------------------------#
# Taxonomic rollup ----
#------------------------------------------------------------------------------#
# import one of the auk example datasets without rolling up taxonomy
obs_ex <- system.file("extdata/ebd-rollup-ex.txt", package = "auk") |>
  read_ebd(rollup = FALSE)
# rollup taxonomy
obs_ex_rollup <- auk_rollup(obs_ex)
# identify the taxonomic categories present in each dataset
unique(obs_ex$category)
unique(obs_ex_rollup$category)
# yellow-rumped warbler observations prior to rollup
obs_ex |>
  filter(common_name == "Yellow-rumped Warbler") |>
  select(checklist_id, category, common_name, subspecies_common_name,
         observation_count)
# yellow-rumped warbler observations after rollup
obs_ex_rollup |>
  filter(common_name == "Yellow-rumped Warbler") |>
  select(checklist_id, category, common_name, observation_count)


# Filter to region and season ----

# filter to complete checklists from the last 10 years
checklists <- checklists_all |>
  filter(all_species_reported,
         between(year(observation_date), 2015, 2024))

# subset to andinas region boundary polygon
# convert checklist locations to points geometries
checklists_sf <- st_as_sf(checklists,
                          coords = c("longitude", "latitude"),
                          crs = 4326,
                          remove = FALSE)
# boundary of andinas region
region_boundary <- read_sf("data/gis-data.gpkg", layer = "region") |>
  st_transform(crs = st_crs(checklists_sf))
# spatially subset the checklists to those in the study region
checklists <- checklists_sf[region_boundary, ] |>
  st_drop_geometry()

# remove observations without matching checklists
# this applies the same filters to observations that were applied to checklists
observations <- semi_join(observations_all, checklists, by = "checklist_id")


# Zero-fill eBird data ----

# combine checklist and observation data to produce detection/non-detection data
zf <- auk_zerofill(observations, checklists, collapse = TRUE)
# function to convert observation time to hours since midnight
time_to_decimal <- function(x) {
  x <- hms(x, quiet = TRUE)
  hour(x) + minute(x) / 60 + second(x) / 3600
}
# transform effort variables
# 1. convert counts to integer and "X" to NA
# 2. set distance to 0 for stationary checklists
# 3. convert duration to hours
# 4. create speed variable
# 5. convert time to hours since midnight
# 6. split date into year and day of year
zf <- zf |>
  mutate(
    # convert count to integer and X to NA
    # ignore the warning "NAs introduced by coercion"
    observation_count = as.integer(observation_count),
    # effort_distance_km to 0 for stationary counts
    effort_distance_km = if_else(observation_type == "Stationary",
                                 0, effort_distance_km),
    # convert duration to hours
    effort_hours = duration_minutes / 60,
    # speed km/h
    effort_speed_kmph = effort_distance_km / effort_hours,
    # convert time to decimal hours since midnight
    hours_of_day = time_to_decimal(time_observations_started),
    # split date into year and day of year
    year = year(observation_date),
    day_of_year = yday(observation_date)
  )


# Apply effort filters ----

# traveling or stationary counts with fewer than 10 observers
# duration <= 8 h and >= 2 minutes, length <= 10 km, speed <= 100km/h
zf_filtered <- zf |>
  filter(observation_type %in% c("Stationary", "Traveling"),
         !is.na(effort_hours), effort_hours >= 0.032, effort_hours <= 8,
         !is.na(effort_distance_km), effort_distance_km <= 10,
         effort_speed_kmph <= 100,
         number_observers <= 10)

# EXERCISE: Pick one of the four effort variables we filtered on above and
# explore how much variation remains.
ggplot(zf) +
  aes(x = effort_hours) +
  geom_histogram(binwidth = 0.5,
                 aes(y = after_stat(count / sum(count)))) +
  scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
  labs(x = "Duration [hours]",
       y = "% of eBird checklists",
       title = "Distribution of eBird checklist duration",
       subtitle = "Before effort filtering")
ggplot(zf_filtered) +
  aes(x = effort_hours) +
  geom_histogram(binwidth = 0.5,
                 aes(y = after_stat(count / sum(count)))) +
  scale_y_continuous(limits = c(0, NA), labels = scales::label_percent()) +
  labs(x = "Duration [hours]",
       y = "% of eBird checklists",
       title = "Distribution of eBird checklist duration",
       subtitle = "After effort filtering")


# Test-train split ----

# split checklists into 20/80 test/train
zf_filtered$type <- if_else(runif(nrow(zf_filtered)) <= 0.8, "train", "test")
table(zf_filtered$type) / nrow(zf_filtered)

# subset to only those columns we need
checklists <- zf_filtered |>
  select(checklist_id, observer_id, type,
         observation_count, species_observed,
         state_code, locality_id, latitude, longitude,
         observation_type,
         observation_date, year, day_of_year, hours_of_day,
         effort_hours, effort_distance_km, effort_speed_kmph,
         number_observers)
# save dataset for use in next lesson
write_csv(checklists, glue("data/checklists-zf_{species}_co.csv"), na = "")


# Mapping ----

# load gis data
land <- read_sf("data/gis-data.gpkg", "land") |>
  st_geometry()
country_lines <- read_sf("data/gis-data.gpkg", "country_lines") |>
  st_geometry()
region_boundary <- read_sf("data/gis-data.gpkg", "region") |>
  st_geometry()

# prepare ebird data for mapping
checklists_sf <- checklists |>
  # convert to spatial points
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  select(species_observed)

# map
par(mar = c(0.25, 0.25, 4, 0.25))
# set up plot area
plot(st_geometry(checklists_sf),
     main = glue("{species_name} eBird observations\n 2015-2024"),
     col = NA, border = NA)
# contextual gis data
plot(land, col = "#cfcfcf", border = "#888888", lwd = 0.5, add = TRUE)
plot(region_boundary, col = "#e6e6e6", border = NA, add = TRUE)
plot(country_lines, col = "#ffffff", lwd = 1.5, add = TRUE)
# ebird observations
# not observed
plot(filter(checklists_sf, !species_observed),
     pch = 19, cex = 0.05, col = alpha("#555555", 0.1),
     add = TRUE)
# observed
plot(filter(checklists_sf, species_observed),
     pch = 19, cex = 0.15, col = alpha("#4daf4a", 0.5),
     add = TRUE)
# legend
legend("topleft", bty = "n",
       col = c("#555555", "#4daf4a"),
       legend = c("eBird checklist", "Detections"),
       pch = 19)
box()


# Environmental variables ----

# load and explore the environmental variable dataset
f_habitat <- "data/environmental-variables_checklists_co.parquet"
habitat <- read_parquet(f_habitat)
glimpse(habitat)


# Prediction surface ----

# load the prediction surface environmental variables
pred_grid <- read_parquet("data/prediction-grid_co.parquet")
# load the raster template for the grid
r <- rast("data/prediction-grid_co.tif")

# insert evergreen broadleaf forest % landcover into the raster
forest_cover <- pred_grid |>
  # convert to spatial features
  st_as_sf(coords = c("x", "y"), crs = crs(r)) |>
  # rasterize points
  rasterize(r, field = "landcover_evergreen_broadleaf_pland")

# make a map of deciduous broadleaf forest cover
plot(forest_cover,
     axes = FALSE, box = FALSE, col = viridis(10),
     main = "Evergreen Broadleaf Forest (% cover)")

# EXERCISE: Choose one of the other environmental variables and make a map. Does
# the spatial pattern match what you know about the region?







# library(arrow)
# library(dplyr)
# library(fs)
# library(glue)
# library(lubridate)
# library(readr)
# library(rnaturalearth)
# library(sf)
# library(stringr)
# library(terra)
# setwd(here::here("workshop/humboldt-2025/"))

# prepare data for covariate assignment ----

# ebird
checklists <- read_sampling("data-raw/ebd_CO_smp_relAug-2025_sampling.txt") |>
  filter(all_species_reported,
         observation_type %in% c("Traveling", "Stationary")) |>
  group_by(row_id = locality_id, year = year(observation_date)) |>
  summarize(latitude = first(latitude), longitude = first(longitude),
            .groups = "drop")

# prediction grid
# colombia centered albers equal area conic
aeac_crs <- st_crs("+proj=aea +lat_1=-4 +lat_2=8 +lat_0=2 +lon_0=-73")

# study region
study_region <- ne_countries(scale = 10, country = "Colombia")
# clip out islands
clip_bb <- st_bbox(c(xmin = -79.4, ymin = -4.2, xmax = -66.9, ymax = 12.6),
                   crs = 4326) |>
  st_as_sfc()
study_region <- st_intersection(study_region, clip_bb) |>
  st_transform(crs = aeac_crs) |>
  st_geometry() |>
  vect()

# create a raster template covering the region with 3 km resolution
r <- study_region |>
  buffer(3000) |>
  rast(res = c(3000, 3000))

# fill the raster with 1s inside the study region
r <- rasterize(study_region, r, touches = TRUE) |>
  setNames("study_region")

# save for later use
r <- writeRaster(r, filename = "data/prediction-grid_co.tif",
                 overwrite = TRUE,
                 gdal = "COMPRESS=DEFLATE")

# cell coordinates
cell_coordinates <- as.data.frame(r, cells = TRUE, xy = TRUE) |>
  select(cell_id = cell, x, y) |>
  st_as_sf(coords = c("x", "y"), crs = st_crs(r), remove = FALSE) |>
  st_transform(crs = 4326)
cell_coordinates <- st_coordinates(cell_coordinates) |>
  as.data.frame() |>
  select(latitude = Y, longitude = X) |>
  bind_cols(cell_coordinates) |>
  mutate(row_id = paste0("PG", cell_id), year = 2024) |>
  select(cell_id, row_id, year, x, y, latitude, longitude)
write_csv(cell_coordinates, "data-raw/prediction-grid_cell-coordinates_co.csv")

# combine and save for covariate assignment
combined <- bind_rows(
  checklists,
  select(cell_coordinates, row_id, year, latitude, longitude)
)
write_parquet(combined, "data-raw/erd_co_year.parquet")
combined <- checklists |>
  group_by(row_id) |>
  summarize(latitude = first(latitude), longitude = first(longitude)) |>
  bind_rows(select(cell_coordinates, row_id, latitude, longitude))
write_parquet(combined, "data-raw/erd_co_static.parquet")


# assign covariates ----

# crop elevation
# sinu_crs <- crs("+proj=sinu +lon_0=0 +x_0=0 +y_0=0 +R=6371007.181 +units=m +no_defs")
# e <- project(r, sinu_crs) |> ext() |> as.list()
# elev_dir <- "/ocean/projects/deb200005p/sligocki/erd_prep/covariates/elevation"
# glue("gdal_translate -projwin {e$xmin} {e$ymax} {e$xmax} {e$ymin} ",
#      "{elev_dir}/astgtm_sinu_full.tif {elev_dir}/astgtm_sinu.tif")

# assign
# interact -n 64
# module load anaconda3
# conda activate conda-env
# for x in elevation slope_1km mountains roads ntl mcd12q1_lccs1; do
#   python3 schedule_assign_covars.py 2024 erd $x 4 --label=erd_co --num-procs=8 --no-canary
# done
# sq | grep covar | awk '{p rint $1}' | sort | uniq | join_str ,

# combine shards
# interact -n 64
# module load anaconda3
# conda activate conda-env
# for x in elevation slope_1km mountains roads ntl mcd12q1_lccs1; do
#   python3 finish_covar.py 2024 erd_co $x 4
# done

# combine
base_dir <- "/ocean/projects/deb200005p/sligocki/erd_prep/erd2024/covar_assignment"
inputs_dir <- path(base_dir, "inputs")
assign_dir <- path(base_dir, "erd_co")
outputs_dir <- "/ocean/projects/deb200005p/mstrimas"

erd_srd <- path(inputs_dir, "erd_co_year.parquet") |>
  read_parquet() |>
  select(row_id, year)

covs <- dir_ls(assign_dir) |> basename()
covs <- c("elevation", "mcd12q1_lccs1", "mountains",
          "ntl", "roads", "slope_1km", "slope_90m")
for (cov in covs) {
  message(cov)
  assignment <- path(assign_dir, cov, "assignment.parquet") |>
    read_parquet()
  if ("year" %in% names(assignment)) {
    erd_srd <- left_join(erd_srd, assignment, by = c("row_id", "year"))
  } else {
    erd_srd <- left_join(erd_srd, assignment, by = "row_id")
  }
}
stopifnot(complete.cases(erd_srd))
write_parquet(erd_srd, path(outputs_dir, "erd-srd_3km_co.paquet"))


# merge features into erd/srd ----

assignments <- read_parquet("data-raw/erd-srd_3km_co.paquet") |>
  select(row_id, year,
         starts_with("elevation"),
         starts_with("northness_90m"),
         starts_with("eastness_90m"),
         mountain,
         starts_with("mcd12q1"),
         starts_with("road")) |>
  select(-mcd12q1_lccs1_diversity)

# swap in descriptive names
lc <- read_csv("data-raw/mcd12q1_lccs1_classes.csv")
old_names <- c(glue("mcd12q1_lccs1_c{lc$class}_pland"),
               glue("mcd12q1_lccs1_c{lc$class}_ed"))
new_names <- c(glue("landcover_{lc$label}_pland"),
               glue("landcover_{lc$label}_ed"))
lookup <- match(names(assignments), old_names)
index <- which(!is.na(lookup))
lookup <- lookup[!is.na(lookup)]
names(assignments)[index] <- new_names[lookup]

# erd
assignments |>
  filter(str_starts(row_id, "L")) |>
  rename(locality_id = row_id) |>
  write_parquet("data/environmental-variables_checklists_co.parquet")

# srd
srd <- read_csv("data-raw/prediction-grid_cell-coordinates_co.csv")
assignments |>
  filter(str_starts(row_id, "PG")) |>
  inner_join(srd, y = _, by = c("row_id", "year")) |>
  select(-row_id, -year) |>
  write_parquet("data/prediction-grid_co.parquet")


# gis data ----

f_gpkg <- "data/gis-data.gpkg"
if (file_exists(f_gpkg)) file_delete(f_gpkg)

# focal region
region <- read_sf("data-raw/RegionFis_Col_WGS84_Andinas.gpkg") |>
  st_transform(crs = 4326) |>
  mutate(region = "Andinas") |>
  select(region) |>
  write_sf(dsn = f_gpkg, layer = "region")

clip_region <- st_geometry(st_buffer(region, 2e6))

# land boundary
ne_land <- ne_download(scale = 10, category = "physical",
                       type = "land",
                       returnclass = "sf") |>
  st_combine() |>
  st_make_valid() |>
  st_intersection(clip_region) |>
  st_as_sf() |>
  mutate(id = "land")
write_sf(ne_land, dsn = f_gpkg, layer = "land")

# country lines
ne_country_lines <- ne_download(scale = 10, category = "cultural",
                                type = "admin_0_boundary_lines_land",
                                returnclass = "sf") |>
  transmute(id = row_number()) |>
  st_combine() |>
  st_make_valid() |>
  st_intersection(clip_region) |>
  st_as_sf() |>
  mutate(id = "country_lines")
write_sf(ne_country_lines, dsn = f_gpkg, layer = "country_lines")

# country
ne_country <- ne_download(scale = 10, category = "cultural",
                          type = "admin_0_countries",
                          returnclass = "sf") |>
  filter(ISO_A2 == "CO") |>
  select(name = NAME)
write_sf(ne_country, dsn = f_gpkg, layer = "countries")

# states
ne_state <- ne_download(scale = 10, category = "cultural",
                        type = "admin_1_states_provinces",
                        returnclass = "sf") |>
  filter(iso_a2 == "CO") |>
  select(code = iso_3166_2, name = name)
write_sf(ne_state, dsn = f_gpkg, layer = "departments")



setwd("~/Desktop/NOC_eBird_workshop/workshop-data")
auk_set_ebd_path("~/Desktop/NOC_eBird_workshop/workshop-data",overwrite=TRUE)

library(readr)
library(auk)

ebd_top <- read_tsv("~/Desktop/NOC_eBird_workshop/workshop-data/ebd_2015-2016_yucatan.txt", n_max = 5)

file.exists("ebd_2015-2016_yucatan.txt")
auk_ebd("ebd_2015-2016_yucatan.txt")

##Definir los filtros de la información

auk_ebd("ebd_2015-2016_yucatan.txt") %>%
  auk_country("Guatemala")

##

auk_ebd("ebd_2015-2016_yucatan.txt") %>%
  auk_species("Resplendent Quetzal") %>%
  auk_country("Guatemala") %>%
  auk_date(c("2015-06-01", "2015-06-30"))

#Aqui hemos definido aun mas filtros, por especie

##############
##Ejercicio###
##############

#Definir los filtros para extraer las observaciones del "Magnolia Warbler", entre las 5am y 10am que usaron 
#los protocolos de "Traveling" y "Stationary"

##SOLUCIONES

#Si quieren definir observaciones sin tener que definir el año, pueden hacerlo

auk_ebd("ebd_2015-2016_yucatan.txt") %>%
  auk_species("Resplendent Quetzal") %>%
  auk_country("Guatemala") %>%
  auk_date(c("*-06-01", "*-06-30"))

##Con el filtro auk_complete() podemos selecionar los listados de eBird que pueden inferir absencias
##por que se anotan solo las especies que se observaron


#Ejercicio: Definir los filtros para extraer las observaciones del Horned Guan y el Highland Guan 
#de listas completas en Chiapas, Mexico. Usen el filtro de auk_state() 
#Consultar los codigos en: https://ebird.org/region/MX-CHP?

##SOLUCIONES


##Ahora vamos a ejecutar los filtros que definimos
##Vamos a filtar las observaciones de "yellow-rumped warbler" para listas de "Traveling" y "Stationary"

ebd_filtered <- auk_ebd("ebd_2015-2016_yucatan.txt") %>%
  auk_species("Yellow-rumped Warbler") %>%
  auk_country("GT") %>%
  auk_protocol(c("Traveling", "Stationary")) %>%
  auk_complete() %>%
  auk_filter(file = "~/Desktop/NOC_eBird_workshop/workshop-data/ebd_yerwar.txt")

##Preguntas??

library(auk)
library(dplyr)

ebd <- read_ebd("~/Desktop/NOC_eBird_workshop/workshop-data/ebd_yerwar.txt", unique = FALSE, rollup = FALSE)
glimpse(ebd)

##Usen glimpse() y View() para explorar 

###SOLUTIONS


#Como lidear con listas compartidas: muchas listas son compartidas, y tenemos que identiificarlas 
##para poder filtrarlas y no tener informacion duplicada

ebd %>%
  filter(!is.na(group_identifier)) %>%
  select(sampling_event_identifier, group_identifier) %>%
  head()

#cuando varias listas tienen el mismo group identifier, significa que son compartidas
#https://ebird.org/view/checklist/S26064931

#Pero no toda la informacion es duplicada, ya que puede variar aunque la gente andaba junta
#La funcion de auk_unique() retiene las primeras observaciones 

keep_one <- auk_unique(ebd)

nrow(ebd)
nrow(keep_one)

#Podemos observar la modificacion

head(keep_one)

#ahora hay una columna nueva: checklist_id, que tiene ahora un group_identifier y 
#sampling_event_identifier


keep_one %>%
  filter(!is.na(group_identifier)) %>%
  select(checklist_id, sampling_event_identifier,
         group_identifier, observer_id) %>%
  head()

#Ahora podemos ver la lista specifica, con un resumen de los observadores specificos
#y los eventos de muestreo , y un identificador del grupo de listas

##Cuando uno importa estos datos, la funcion de read_ebd hace esto automaticamente

ebd <- read_ebd("~/Desktop/NOC_eBird_workshop/workshop-data/ebd_yerwar.txt", rollup = FALSE)


###Taxonomia 

glimpse(ebird_taxonomy)

#hay muchas formas, sp. solo genero, sp. expeficica, etc.

filter(ebird_taxonomy, common_name == "bird sp.")

##Por ejemplo, el "Myrtle Warbler" se convierte en el "Yellow Warbler"

# myrtle warbler
filter(ebird_taxonomy, common_name == "Yellow-rumped Warbler (Myrtle)") %>%
  select(common_name, category, report_as)

##Se puede reportar solo al nivel mas amplio
filter(ebird_taxonomy, species_code == "yerwar") %>%
  select(common_name, category, report_as)

##Tambien uno puede ver cuantas subespecies hay
count(ebd, common_name, subspecies_common_name)

##Tambien se pueden tener varias subespecies en una misma lista

filter(ebd, checklist_id == "S22725024") %>%
  select(checklist_id, common_name, subspecies_common_name, observation_count)

##para casi todos los usos de eBird, solo vamos a querer analizar los datos a nivel de especie
##la funcion auk_rollup() se encarga de eso automaticamente

no_subsp <- auk_rollup(ebd)
filter(no_subsp, checklist_id == "S22725024") %>%
  select(checklist_id, common_name, observation_count)

#de nuevo, esto se hace automaticamente

ebd <- read_ebd("~/Desktop/NOC_eBird_workshop/workshop-data/ebd_yerwar.txt")












