library(ggpubr)
library(here)
library(tidyverse)
library(png)

# img <- readPNG(here('data/slide.png'))

location_lookup = tribble(
	~x, ~y, ~location,~type,
	0,0,"pos_099",NA,
	1,1,"pos_098",NA,
	0.9,0.75,"pos_001","Inflamed",
	0.57,0.64,"pos_002",NA,
	0.612,0.697,"pos_003",NA,
	0.77,0.765,"pos_004",NA,
	0.817,0.7,"pos_005","Inflamed",
	0.875,0.65,"pos_006","Inflamed",
	0.717,0.65,"pos_007","Inflamed",
	0.665,0.565,"pos_008","Inflamed",
	0.727,0.57,"pos_009","Inflamed",
	0.935,0.69,"pos_010","Inflamed",
	0.98,0.775,"pos_011","Inflamed",
	0.78,0.625,"pos_012","Inflamed",
	0.965,0.6,"pos_013","Inflamed",
	0.575,0.565,"pos_014","Inflamed",
	0.675,0.74,"pos_015","Inflamed",
	0.41,0.91,"pos_016","Control",
	0.57,0.98,"pos_017","Control",
	0.07,0.485,"pos_018","Control",
	0.155,0.65,"pos_019","Control",
	0.48,0.37,"pos_020","Control",
	0.415,0.3,"pos_021","Control",
	0.226,0.13,"pos_022",NA,
	0.218,0.2,"pos_023",NA,
	0.45,0.03,"pos_024","Control"
) %>% 
	# filter(location == "anchor" | location == "pos_016") %>%
	identity() %>%
	write_rds(here('data/location_lookup.rds'))

# ggplot(location_lookup, aes(x = x,y = y, color=location, size = size)) +
# 	background_image(img) +
# 	geom_point() +
# 	theme_void()

# exp_data = read_excel(here('data/All Data CTA.xlsx'), sheet = 5) %>%
# 	select(-ScanLabel,-SegmentLabel) %>%
# 	add_row(ROILabel = 099) %>%
# 	add_row(ROILabel = 098) %>%
# 	pivot_longer(-ROILabel,names_to = "gene", values_to = "exp") %>%
# 	mutate(location = sprintf("pos_%03d",ROILabel)) %>%
# 	left_join(location_lookup)
# 
# exp_data_summary = exp_data %>% group_by(gene) %>% 
# 	summarise(range = max(exp, na.rm=T) - min(exp, na.rm=T)) %>%
# 	arrange(desc(range))
# 
# test_subset = exp_data %>%
# 	filter(gene == exp_data_summary$gene[1]) %>%
# 	mutate(exp = ifelse(is.na(exp), min(exp), exp))
# 
# ggplot(test_subset, aes(x = x, y = y, color = exp, size=exp)) +
# 	background_image(img) +
# 	geom_point() +
# 	scale_color_viridis_c() +
# 	theme(axis.title.x=element_blank(),
# 				axis.text.x=element_blank(),
# 				axis.ticks.x=element_blank(),
# 				axis.title.y=element_blank(),
# 				axis.text.y=element_blank(),
# 				axis.ticks.y=element_blank())
# 	# theme_void()
# ggsave(here(sprintf('sample_%s.png',exp_data_summary$gene[1])), height = 10, width = 10*(1254/1076))
