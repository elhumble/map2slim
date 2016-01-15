require(dplyr)
require(plyr)

# script to combine GO SLIM annotations with SNP data

# read in annotations

goSlim <- readLines("joined_transcriptome_SLIM.gaf")[-c(1:5)] # 24029 annotated contigs

# we want GOslim which is in the first GO column

length(strsplit(goSlim[1], split = "\t")[[1]])

goTable <- matrix(ncol = 16,
                  nrow = length(goSlim))

# fill table
for(i in 1:length(goSlim)) goTable[i,1:length(strsplit(goSlim[i], split = "\t")[[1]])] <- strsplit(goSlim[i], split = "\t")[[1]]

goTable <- goTable[,c(3,5)] # retain contig and GO term

# make df
goTable <- data.frame(goTable)
names(goTable) <- c("Contig_Name", "goSlimTerm")

#combine with goSlim names

names <- read.table("goslim/goslim_generic.txt", sep = "\t", col.names = c("goSlimTerm", "name")) %>% # readr?
        right_join(goTable, by = "goSlimTerm")

# merge with SNPs collapse contigs with duplicate GOterms

snps <- read.csv("../../snp_filtering_pipeline/data/processed/global_snps_hq.csv", header = T)[,1:2] %>% # 34,718 snps
        left_join(names, by = "Contig_Name") %>%
        mutate(Contig_Name = paste(Contig_Name, SNP_Position, sep="_")) %>%
        ddply("Contig_Name", summarize, goSlimTerm = paste(goSlimTerm, collapse=" "), name = paste(name, collapse = " "))

# -----------------------------------
# Search for 'immun' in KEYWORDS only 
# -----------------------------------

annotation <- readLines("../joined_transcriptome_ANNOTATED.txt")

immuneTable2 <- matrix(ncol = 18,
                       nrow = length(annotation))

# fill table
for(i in 1:length(annotation))
        immuneTable2[i,1:length(strsplit(annotation[i], split = "\t")[[1]])] <- strsplit(annotation[i], split = "\t")[[1]]


immuneTable2 <- data.frame(immuneTable2)[-1,c(1,14:18)] %>%
        select(Contig_Name = X1, goTerm = X14, CC = X15, BP = X16, MF = X17, keywords = X18) %>%
        filter(grepl('immun', keywords)) # 28205

# merge with snp dataframe to determine number of SNPs

immuneSnps2 <- read.csv("../../snp_filtering_pipeline/data/processed/global_snps_hq.csv", header = T)[,1:2] %>% # 34,718 snps
        inner_join(immuneTable2, by = "Contig_Name") %>%
        write.csv("immuneSNPs_keywords.csv", row.names = F)

# ---------------------------------
# Search for 'immun' in whole file 
# ---------------------------------

annotation <- readLines("../joined_transcriptome_ANNOTATED.txt")

immune <- "immun"
immuneLines <- NULL
for(i in immune) 
        immuneLines <- c(immuneLines, annotation[grep(i, annotation, ignore.case=T)])

length(strsplit(immuneLines[1], split = "\t")[[1]])

immuneTable <- matrix(ncol = 18,
                  nrow = length(immuneLines))

# fill table
for(i in 1:length(immuneLines))
        immuneTable[i,1:length(strsplit(immuneLines[i], split = "\t")[[1]])] <- strsplit(immuneLines[i], split = "\t")[[1]]

immuneTable <- data.frame(immuneTable)[,c(1,14:18)] 
names(immuneTable) <- c("Contig_Name", "goTerm", "CC", "BP", "MF", "keywords") # 1618

# merge with snp dataframe to determine number of SNPs

immuneSnps <- read.csv("../../snp_filtering_pipeline/data/processed/global_snps_hq.csv", header = T)[,1:2] %>% # 34,718 snps
        inner_join(immuneTable, by = "Contig_Name") # %>%
       # write.csv("immuneSNPs.csv", row.names = F)

