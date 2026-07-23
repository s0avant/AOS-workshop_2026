#------------------------------------------------------------------------------#
#                             AOS 2026 Workshop                                #
#                       01. Import and explore auk data                        #
#                   Aimee Van Tatenhove & Fabiola Rodríguez                    #
#------------------------------------------------------------------------------#

# Set section 1 R environment

library(tidyverse)
library(auk)
source("custom-functions.R")

set_theme(custom.theme())

# 1.1 Set auk paths----

## Set path for EBD or eBird basic dataset:
in_ebd_small <- "data/ebd_filtered_cam_AOS_2026.txt"

## Set path for effort data:
in_effort_small <- 

# 1.2 Explore file sizes----
  
## Smallish files, so we can load into R memory directly
get.filesize(in_ebd_small)
get.filesize(in_effort_small)

# Explore auk function read_ebd
?read_ebd()

# 1.3 Apply read_ebd----

## Apply the read_ebd() function to the ebd file:
ebd <- read_ebd() 

## Apply the read_sampling function to read the sampling file:
effort <- read_sampling() 

# Overview of files
glimpse(ebd)
glimpse(effort)

# 1.4 Exploration----

# Explore variable levels
unique(ebd)

# Explore variable ranges
range(ebd$)

# Explore variable counts
table(ebd$)

# Exercise for participants. Determine which countries are in this dataset:

# Exploring by plotting

## Explore visually by using ggplot's geom_bar which counts occurrences for a category

## Call ggplot:

## Select geometry:

## Add title:

## Add x and y labs:

## Plotting observations by country and species
ggplot() +
  geom_bar(aes(x = , color = , fill = ),
           position = position_dodge()) +
  ggtitle("Observations by Country and Species") +
  coord_flip() +
  xlab("Country") + ylab("Count") +
  labs(color = "Species",
       fill = "Species") 

## Plotting observation dates
ggplot(ebd) +
  geom_bar(aes(x = observation_date, color = common_name, fill = common_name)) +
  ggtitle("Observation Date by Species") +
  xlab("Checklist date") + ylab("Count") +
  labs(color = "Species",
       fill = "Species")

## Plotting effort types
ggplot(effort) + # Note the dataset used is not ebd
  geom_bar(aes(x = observation_type)) +
  ggtitle("Observation Type") +
  coord_flip() +
  xlab("Type") + ylab("Count")

## Plotting effort duration
ggplot(effort) + # You can safely ignore the plotting error here
  geom_bar(aes(x = duration_minutes)) +
  ggtitle("Checklist Duration") +
  xlab("Duration in minutes") + ylab("Count")

# 1.5 Pipes as auk's building block----

## Example without pipes (i.e. stepwise)
tmp1 <- subset(effort, !is.na(duration_minutes))
tmp1 <- transform(tmp1, duration_hours = duration_minutes / 60)
duration_hours <- tmp1$duration_hours
duration_max_no_pipe <- max(duration_hours)

duration_max_no_pipe

## Example with base R pipe, starting with the data to process
duration_max_pipe <- effort |>
  ## Subset to remove NAs from the duration in minutes variable
  
  ## Transform variable to duration in hours
  
  ## Summarize to identify the max value of duration in hours
  
  duration_max_pipe