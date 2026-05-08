#------------------------------------------------------------------------------#
#                     auk Filtering Workflow: Full Dataset                     #
#                      Aimee M. Van Tatenhove 05/05/2026                       #
#            ---------------------------------------------------------         #
#           This code has already been run, and produces the data that         #
#                we will be using in the 2025 AOS auk workshop                 #
#------------------------------------------------------------------------------#
rm(list = ls())
library(tidyverse)
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

# Set paths for EBD & effort data out
out_ebd <- paste0(path, "ebd_filtered_AOS_2026.txt")
out_eff <- paste0(path, "eff_filtered_AOS_2026.txt")

#------------------------------------------------------------------------------#
# Set and execute filters ----
#------------------------------------------------------------------------------#
# Define species of interest
species <- c("amewoo", "bkcchi", "prawar")
species_names <- ebird_species(species, type = "common")

# Define regions of interest
states <- c("US-CT", "US-MA", "US-ME", "US-NH", "US-RI", "US-VT")

# Set data filters
## For checklist data only (presence-only data)
filters_presence_1st <- 
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = states)

## For checklist AND sampling data (presence-absence data)
filters_zerofill_1st <-
  # Set EBD & sampling file paths
  auk_ebd(in_ebd, file_sampling = in_eff) |>
  # Set species of interest
  auk_species(species = species_names) |>
  # Set spatial region of interest
  auk_state(state = states)

# Call AWK to filter presence-only data
a1 <- Sys.time() # Start timer; may take multiple hours

presence_out <-
  # Set EBD file path
  auk_ebd(in_ebd) |>
  # Execute filters
  auk_filter()

(runtime1 <- Sys.time() - a1) # End timer and save duration

# Call AWK to filter presence-absence data
a2 <- Sys.time() # Start timer; may take multiple hours

presabs_out <- 
  # Set EBD & sampling file paths
  auk_ebd(in_ebd, file_sampling = in_eff) |>
  # Execute filters
  auk_filter()

(runtime2 <- Sys.time() - a2) # End timer and save duration

#------------------------------------------------------------------------------#
#                Next script: 01_filter_workshop-dataset_AMV.R                 #
#------------------------------------------------------------------------------#