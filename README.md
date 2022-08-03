# Massospora cicadina MCPNR19
Genome assembly and annotation of M. cicadina MCPNR19

# Methods
* Assembly steps are part of a separate github
  * https://github.com/zygolife/Massospora_cicadina_ONT_asm
* Bacteria cleanup
  * To remove bacteria contigs a combination of [Blobtools2](https://blobtoolkit.genomehubs.org/blobtools2/), taxonomic screening with [MMseqs2](https://github.com/soedinglab/MMseqs2) easy-taxonomy pipeline, and analysis of repetitive content was performed. As the Mcic genome is highly repetitive, potential false positive Bacteria contigs were rescued as fungal if they contained TEs. Lack of TEs and skewed GC content, were good indicators for scoring likely contamination [TE vs GC Figure](/bacteria_cleaning/blobs_2/TEcontent_vs_gc.pdf). ![TE vs GC Figure](/bacteria_cleaning/blobs_2/TEcontent_vs_gc.png)

* [Annotation](/Annotation)
  * Methods and primary files contained in this folder
  * Repeat library construction and RM running, archived [repeat libraries](Annotation/repeat_library)
  * [Funannotate](https://github.com/nextgenusfs/funannotate/) 1.8 [pipeline steps](Annotation/pipeline)

# Citation
Stajich JE, Lovett BR, Ettinger CL, Carter-House DA, Kurbessoian T, Kasson MT. An Improved 1.5 Gigabase Draft Assembly of _Massospora cicadina_ (Zoopagomycota), Obligate Fungal Parasite of 13- and 17-Year Cicadas. Microbial Resource Announcements.
