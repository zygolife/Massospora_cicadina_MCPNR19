library(dplyr)
library(readr)


prot2tax <- read_tsv("Masso_5FC.swissprot.taxo_tophit_report.taxids",col_names=c("SID","TAXID"),col_types="ci")
ctg2hit <- read_tsv("Masso_5FC.swissprot.taxo_tophit_aln.simple.tsv",col_names=c("QID","SID","SCORE"))

combo <- ctg2hit %>% left_join(prot2tax) %>% select (QID,TAXID,SCORE,SID)
write_tsv(combo,"Masso_5FC.swissprot.taxify.tsv",col_names=FALSE)
