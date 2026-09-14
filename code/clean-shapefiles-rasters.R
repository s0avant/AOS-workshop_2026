#------------------------------------------------------------------------------#
#                 Clean Shapefiles & Rasters: AOS 2026 Workshop                #
#                      Aimee M. Van Tatenhove 06/26/2026                       #
#------------------------------------------------------------------------------#
rm(list = ls())
library(tidyverse)
library(sf)
library(terra)

#------------------------------------------------------------------------------#
# Read in data ----
#------------------------------------------------------------------------------#
usa_sf <- read_sf("../cb_2018_us_state_500k/cb_2018_us_state_500k.shp")
bel_sf <- read_sf("../geoBoundaries-BLZ-ADM0-all/geoBoundaries-BLZ-ADM0.shp")
cri_sf <- read_sf("../geoBoundaries-CRI-ADM0-all/geoBoundaries-CRI-ADM0.shp")
slv_sf <- read_sf("../geoBoundaries-SLV-ADM0-all/geoBoundaries-SLV-ADM0.shp")
gtm_sf <- read_sf("../geoBoundaries-GTM-ADM0-all/geoBoundaries-GTM-ADM0.shp")
hnd_sf <- read_sf("../geoBoundaries-HND-ADM0-all/geoBoundaries-HND-ADM0.shp")
nic_sf <- read_sf("../geoBoundaries-NIC-ADM0-all/geoBoundaries-NIC-ADM0.shp")
pan_sf <- read_sf("../geoBoundaries-PAN-ADM0-all/geoBoundaries-PAN-ADM0.shp")

EarthEnv <-
  rast(c("../EarthEnv_1kmConsensusLandCover/consensus_full_class_1.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_2.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_3.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_4.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_5.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_6.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_7.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_8.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_9.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_10.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_11.tif",
         "../EarthEnv_1kmConsensusLandCover/consensus_full_class_12.tif"))

#------------------------------------------------------------------------------#
# Merge shapefiles & crop raster stack ----
#------------------------------------------------------------------------------#
ne_sf <- usa_sf %>% 
  filter(STUSPS %in% c("CT", "MA", "ME", "NH", "RI", "VT")) %>% 
  st_transform(crs = 4326)

cam_sf <- rbind(bel_sf, cri_sf, slv_sf, gtm_sf, hnd_sf, nic_sf, pan_sf)

ne_r <- crop(EarthEnv, ne_sf)
cam_r <- crop(EarthEnv, cam_sf)

#------------------------------------------------------------------------------#
# Flatten raster stack & convert to data frame ----
#------------------------------------------------------------------------------#
ne_flat <- which.max(ne_r)
cam_flat <- which.max(cam_r)

ne_df <-
  as.data.frame(ne_flat, xy = TRUE) %>% 
  rename(breaks = which.max)

cam_df <-
  as.data.frame(cam_flat, xy = TRUE) %>% 
  rename(breaks = which.max)

#------------------------------------------------------------------------------#
# Save files ----
#------------------------------------------------------------------------------#
write_sf(ne_sf, "data/gis/usa-northeast-states.shp")
write_sf(cam_sf, "data/gis/cam-countries.shp")
write.csv(ne_df, "data/gis/EarthEnv-landcover-northeast.csv")
write.csv(cam_df, "data/gis/EarthEnv-landcover-cam.csv")
