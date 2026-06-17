#------------------------------------------------------------------------------#
#                             AOS 2026 Workshop                                #
#                   Checking that 'auk' runs and other prep                    #
#                     Source: eBird Best Practices Workshop                    #
#                   (https://strimas.com/ebp-workshop/intro.html)              #
#------------------------------------------------------------------------------#

# 1. Mac Users move on to step 2, Windows users read the handout and download Cygwin

# 2. Install the packages needed for the workshop
install.packages(c("tidyverse","auk", "cowplot", "sf", "lubridate"))

# 3. Run this script: If you see a species name the auk has been installed and runs its functions adequately. We will get to what these are shortly.
library(auk)
library(tidyverse)

tf <- tempfile()
system.file("extdata/ebd-sample.txt", package = "auk") |> 
  auk_ebd() |>
  auk_species(species = c("Canada Jay", "Blue Jay")) |>
  auk_country(country = c("US", "Canada")) |>
  auk_bbox(bbox = c(-100, 37, -80, 52)) |>
  auk_date(date = c("2012-01-01", "2012-12-31")) |>
  auk_time(start_time = c("06:00", "09:00")) |>
  auk_duration(duration = c(0, 60)) |>
  auk_complete() |> 
  auk_filter(tf) |> 
  read_ebd() |> 
  pull(common_name) |>
  message()
unlink(tf)

# END OF SETUP