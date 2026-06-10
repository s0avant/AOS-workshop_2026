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
                                           color = viridisLite::viridis(1),
                                           fill = viridisLite::viridis(1))),
          palette.color.discrete = scales::pal_viridis(),
          palette.fill.discrete = scales::pal_viridis())
}#function

# Custom color palettes ----
cb_palette <-
  colorRampPalette(c("#5B8EFD", "#DD007A", "#CF1000", "#FF5F00", "#FFB00D"))

blue_palette <-
  colorRampPalette(c("#262655", "#365695", "#4582C0", "#4C96D4", "#54ADEB", "#91C2E8", "#EEEEFF"))

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