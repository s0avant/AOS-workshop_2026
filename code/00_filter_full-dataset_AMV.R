#------------------------------------------------------------------------------#
#                     auk Filtering Workflow: Full Dataset                     #
#                      Aimee M. Van Tatenhove 06/11/2026                       #
#            ---------------------------------------------------------         #
#           This code has already been run, and produces the data that         #
#                we will be using in the 2026 AOS auk workshop                 #
#------------------------------------------------------------------------------#
rm(list = ls())
library(auk)

#------------------------------------------------------------------------------#
# Read in data ----
#------------------------------------------------------------------------------#
# Define filepath for EBD file
## Example only; modify filepath to access YOUR folder containing EBD data
path <- "/Volumes/Eco Data/eBird_EBD_2026.05.05/ebd_US_smp_relMar-2026/" # Mac
# path <- "D:/eBird_EBD_2026.05.05/ebd_US_smp_relMar-2026/" # Windows

# IF ON WINDOWS, MUST INSTALL CYGWIN TO GET AWK (AKA GAWK)
# https://www.cygwin.com/install.html

# Set paths for EBD & effort data in
in_ebd <- paste0(path, "ebd_US_relMar-2026.txt")
in_eff <- paste0(path, "ebd_US_relMar-2026_sampling.txt")

# Set paths for EBD & effort data out to local directory
out_ebd <- "data/ebd_filtered_us_AOS_2026.txt"
out_eff <- "data/effort_filtered_us_AOS_2026.txt"
out_ebd_backup <- "data/ebd_filtered_us_AOS_2026_backup.txt"
out_eff_backup <- "data/effort_filtered_us_AOS_2026_backup.txt"

#------------------------------------------------------------------------------#
# Set and execute filters ----
#------------------------------------------------------------------------------#
# Define species of interest
# species <- c("amewoo", "bkcchi", "prawar", "yerwar")
species <- c("amewoo", "bkcchi", "prawar")
(species_names <- ebird_species(species, type = "common"))

# Define regions of interest
states <- c("US-CT", "US-MA", "US-ME", "US-NH", "US-RI", "US-VT")

# Define years of interest
years <- 2012:2025

# Set data filters
## For checklist data only (presence-only data)
filters_presence <- 
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = states) |>
  # Set study period of interest
  auk_year(year = years)

## For checklist AND effort data (presence-absence data)
filters_zerofill <-
  # Set EBD & effort file paths
  auk_ebd(in_ebd, file_sampling = in_eff) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = states) |>
  # Set study period of interest
  auk_year(year = years) |>
  # Keep only complete checklists
  auk_complete()

## For checklist AND effort data (presence-absence data) - tiny backup dataset
filters_zerofill_backup <-
  # Set EBD & effort file paths
  auk_ebd(in_ebd, file_sampling = in_eff) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = "US-MA") |>
  # Set study period of interest
  auk_year(year = 2025) |>
  # Keep only complete checklists
  auk_complete()

# # Call AWK to filter presence-only data
# a1 <- Sys.time() # Start timer; may take multiple hours
# 
# # Execute filters
# presence_out <- auk_filter(filters_presence,
#                            file = out_ebd,
#                            overwrite = TRUE)
# 
# (runtime1 <- Sys.time() - a1) # End timer and save duration

# Call AWK to filter presence-absence data
a2 <- Sys.time() # Start timer; may take multiple hours

# Execute filters
presabs_out <- auk_filter(filters_zerofill,
                          file = out_ebd,
                          file_sampling = out_eff,
                          overwrite = TRUE)

(runtime2 <- Sys.time() - a2) # End timer and save duration

# Call AWK to filter presence-absence data
a3 <- Sys.time() # Start timer; may take multiple hours

# Execute filters
presabs_backup_out <- auk_filter(filters_zerofill_backup,
                          file = out_ebd_backup,
                          file_sampling = out_eff_backup,
                          overwrite = TRUE)

(runtime3 <- Sys.time() - a3) # End timer and save duration
