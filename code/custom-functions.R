#------------------------------------------------------------------------------#
#                  Custom Functions for AOS 2026 auk Workshop                  #
#                      Aimee M. Van Tatenhove 06/10/2026                       #
#------------------------------------------------------------------------------#
# Custom ggplot theme ----
custom.theme <- function(){
  theme_bw() +
    theme(axis.text = element_text(size = 12),
          axis.title = element_text(size = 14),
          plot.title = element_text(size = 20),
          plot.subtitle = element_text(size = 16),
          legend.text = element_text(size = 14),
          legend.title = element_text(size = 16),
          update_geom_defaults("bar", list(alpha = 0.6,
                                           color = viridisLite::plasma(1),
                                           fill = viridisLite::plasma(1))),
          palette.color.discrete = scales::pal_viridis(option = "plasma"),
          palette.fill.discrete = scales::pal_viridis(option = "plasma"))
}#function

# Custom color palettes ----
cb_palette <-
  colorRampPalette(c("#5B8EFD", "#DD007A", "#CF1000", "#FF5F00", "#FFB00D"))

blue_palette <-
  colorRampPalette(c("#262655", "#365695", "#4582C0", "#4C96D4", "#54ADEB", "#91C2E8", "#EEEEFF"))

landcover_palette <-
  data.frame(class_names = c("Evergreen/Deciduous Needleleaf Trees",
                             "Evergreen Broadleaf Trees",
                             "Deciduous Broadleaf Trees",
                             "Mixed/Other Trees",
                             "Shrubs",
                             "Herbaceous Vegetation",
                             "Cultivated and Managed Vegetation",
                             "Regularly Flooded Vegetation",
                             "Urban/Built-up",
                             "Snow/Ice",
                             "Barren",
                             "Open Water"),
             breaks = 1:12,
             colors = c("#1C6330",
                        "#99C147",
                        "#68AA63",
                        "#B5C98E",
                        "#A58C30",
                        "#CCBA7C",
                        "#E6E6C1",
                        "#77AD93",
                        "#AA0000",
                        "#D1DDF9",
                        "#B2ADA3",
                        "#476BA0"))

# Function to get file size of external files ----
get.filesize <- function(x){
  tmp <- file.size(x)
  
  if(tmp >= 1073741824){
    tmp1 <- round(tmp / 1073741824, digits = 2)
    out <- paste0(tmp1, " GB")
  }#if
  
  if(tmp >= 1048576 & tmp < 1073741824){
    tmp1 <- round(tmp / 1048576, digits = 2)
    out <- paste0(tmp1, " MB")    
  }
  
  if(tmp < 1048576){
    tmp1 <- round(tmp / 1024, digits = 2)
    out <- paste0(tmp1, " KB")
  }
  
  return(out)
}#function