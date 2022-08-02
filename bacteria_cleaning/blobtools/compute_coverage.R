library(ggplot2)
library(readr)
library(fs)
library(purrr)
library(tidyverse)
covfiles = fs::dir_ls(".",regexp = "\\.coverage$")
covdata <- covfiles %>% map_dfr(read_tsv,comment="#",col_names = c("rname","startpos","endpos",
                                                      "numreads", "covbases","coverage",
                                                      "meandepth","meanbaseq","meanmapq"),)
depths <- covdata %>% select(rname,meandepth) %>% group_by(rname) %>% summarize(sumdpth = sum(meandepth))
head(depths)
mean(depths$sumdpth)
min(depths$sumdpth)
max(depths$sumdpth)
