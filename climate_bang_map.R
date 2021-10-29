#######################################
####climate data in Bangladesh map#####
#######################################
#package
pacman::p_load(here,tidytuesdayR,tidyverse,usmap,janitor,ggeasy,gganimate,transformr,patchwork )
here()
## import the data
rain <- read.csv(rain)
