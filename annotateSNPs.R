require(dplyr)
require(plyr)
# -----------------------------------------
# Combine GO SLIM annotations with SNP data
# -----------------------------------------

# read in annotations

goSlim <- readLines("output/joined_transcriptome_SLIM.gaf")[-c(1:5)] # 24029 annotated contigs

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

# prepare sumamry file

ordered_names <- read.table("../../joe_michael/summary_contig_order.txt", header = T)
        
sorted_names <- names %>%
        mutate(goSlim = do.call(paste, c(names[c(1,2)], sep = "_"))) %>%
        .[-c(1,2)] %>%
        aggregate(goSlim~Contig_Name, ., paste, collapse=",") %>%
        right_join(ordered_names, by = "Contig_Name") %>%
        write.csv("output/joined_transcriptome_GOslim.csv", row.names = F)

# merge with SNPs collapse contigs with duplicate GOterms

snps <- read.csv("../../joe_michael/summary_files/global_SNPs_34718.csv", header = T)[,1:2] %>% # 34,718 snps
        left_join(names, by = "Contig_Name") %>%
        mutate(Contig_Name = paste(Contig_Name, SNP_Position, sep="_")) %>%
        ddply("Contig_Name", summarize, goSlimTerm = paste(goSlimTerm, collapse=" "), name = paste(name, collapse = " "))


# -------------------------------------------------------
# Searching for candidate SNPs using full annotation file
# -------------------------------------------------------

# Search for IMMUNE in KEYWORDS only 

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

immuneSnps2 <- read.csv("../../joe_michael/summary_files/global_SNPs_34718.csv", header = T)[,1:2] %>% # 34,718 snps
        inner_join(immuneTable2, by = "Contig_Name") %>%
        write.csv("immuneSNPs_keywords.csv", row.names = F)

# -----------------------------------------------------------------------------
# Search for IMMUNE in whole file 

annotation <- readLines("../joined_transcriptome_ANNOTATED.txt")

#geneIDs <- c("DAF", "CTL1", "SHC")
immune <- c("immun","antigen", "chemokine", "T cell", "MHC", "Antibody",
                "histocompatibility", "Interleukin", "Leucocyte", "Lymphocyte")

immuneLines <- NULL
for(i in immune) 
        immuneLines <- c(immuneLines, annotation[grep(i, annotation, ignore.case=T)])

length(strsplit(immuneLines[1], split = "\t")[[1]])

immuneTable <- matrix(ncol = 18,
                      nrow = length(immuneLines))

# fill table
for(i in 1:length(immuneLines))
        immuneTable[i,1:length(strsplit(immuneLines[i], split = "\t")[[1]])] <- strsplit(immuneLines[i], split = "\t")[[1]]

immuneTable <- data.frame(immuneTable)[,c(1,10,14:18)] 
names(immuneTable) <- c("Contig_Name", "geneID", "goTerm", "CC", "BP", "MF", "keywords") # 1618

# merge with snp dataframe to determine number of SNPs

immuneSnps <- read.csv("../../joe_michael/summary_files/global_SNPs_34718.csv", header = T)[,1:2] %>% # 34,718 snps
        inner_join(immuneTable, by = "Contig_Name")  %>%
        write.csv("~/Desktop/immuneSNPs.csv", row.names = F)


