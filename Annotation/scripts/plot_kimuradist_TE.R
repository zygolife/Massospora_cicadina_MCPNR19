library(reshape)
library(ggplot2)
library(viridis)
library(hrbrthemes)
library(tidyverse)
library(gridExtra)
library(cowplot)

args <- commandArgs()
cat(args, sep = "\n")
args <- commandArgs(trailingOnly = TRUE)
cat(args, sep = "\n")

divsumtbl <- args[1]
genome_size <- strtoi(args[2])

divsumtbl

outpdf=gsub(pattern = "\\.tbl$", ".kimuraTE_landscape.pdf", divsumtbl)
species = gsub(pattern ="\\.tbl$","",basename(divsumtbl))

KimuraDistance <- read.csv(divsumtbl,sep=" ")

kd_melt = melt(KimuraDistance,id="Div")
kd_melt$norm = kd_melt$value/genome_size * 100

p <- ggplot(kd_melt, aes(fill=variable, y=norm, x=Div)) +
  geom_bar(position="stack", stat="identity",color="black") +
  scale_fill_viridis(discrete = T,option="inferno") +
  theme_cowplot(12) +
  ggtitle(sprintf("TE divergence for %s",species))+
  xlab("Kimura substitution level") +
  ylab("Percent of the genome") +
  labs(fill = "") +
  coord_cartesian(xlim = c(0, 55)) +
  theme(axis.text=element_text(size=11),axis.title =element_text(size=12))

ggsave(outpdf,p,width=12)
