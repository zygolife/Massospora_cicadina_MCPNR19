library(ggplot2)
library(readr)
library(fs)
library(purrr)
library(tidyverse)
library(janitor)
library(cowplot)
data_dir = "."
csv_files <- fs::dir_ls(data_dir, regexp = "\\.wmasked\\.csv$")
#csv_files
all <- csv_files %>% map_dfr(read_csv)
write_tsv(all,"combined.wmasked.tsv")

contamdir = "contam_check"
lca_csv_files <- fs::dir_ls(contamdir, regexp = "mask\\.uniref50_lca\\.tsv$")
lca_csv_files
lcaall <- lca_csv_files %>% map_dfr(read_tsv,col_names=c("id","taxon_id","rank","lca","kingdom_phylum","taxon_string"))
lcaall
all <- csv_files %>% map_dfr(read_csv)
write_tsv(all,"combined.wmasked.tsv")

p <- ggplot(all,aes(x=gc,y=masked_pct,color=bestsumorder_phylum)) + 
  geom_point() + theme_cowplot(12) + labs(title="TE masked% vs GC%")
p
ggsave("TEcontent_vs_gc.pdf",p,width=6,height=6)
ggsave("TEcontent_vs_gc.png",p,width=6,height=6)



filtCtg <- all %>% filter(masked_pct < 25) %>% left_join(lcaall)
filtCtg
write_tsv(filtCtg,"filtered_ctgs_by_TE.tsv")

