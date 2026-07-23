#------------------------------------------------------------------------------#
#                             AOS 2026 Workshop                                #
#                       02. Using auk filters                                  #
#                   Aimee Van Tatenhove & Fabiola Rodríguez                    #
#------------------------------------------------------------------------------#

# 2.1 Set section 2 R environment----
library(tidyverse)
library(auk)
source("custom-functions.R")

# 2.2 Setting the path to auk data----
in_ebd <- 
  
# 2.3 Understanding auk functions----
  ?auk_ebd() 

## Try others such as ?auk_species, ?auk_date to see what they do:

# 2.4 Introducing filters in auk----
filters1 <-
  ## Set EBD file path or object with the path with auk_ebd:
  
  ## Set species to include, common and scientific names can be included:
  
  filters1

# Define filters outside of pipeline; useful for complicated filters
species <- c("Crested Guan", "Northern Emerald-Toucanet")
species_names <- ebird_species(species, type = "common")
species_names

filters2 <-
  ## Set EBD file path or object with the path with auk_ebd:
  
  ## Determine species:
  
  filters2

# Exploring tailored filters: Thinking about sampling design and reducing variation
filters3 <- auk_ebd(in_ebd) |>
  auk_species(species = species_names) |>
  ## Filter to a region of interest (e.g. country):
  
  ## Filter to a date range (use standard ISO date format `"YYYY-MM-DD"`):
  
  filters3

# Exercise to practice setting up filters
filters4 <-

# 2.5 Set output path and filter data----
## Determine the path and name of your output file
  out_ebd <-
  
## Apply the auk filter to the filters description object:
  presence_out <- auk_filter() |>
  ## Read filtered data into R environment:
  
# 2.6 Explore new dataset----

## Are the species of interest the only ones:
unique(presence_out$common_name)

## Are the countries of interest the only ones:
unique(presence_out$country)

## Compare file sizes before and after filtering
get.filesize(in_ebd) 
get.filesize(out_ebd)