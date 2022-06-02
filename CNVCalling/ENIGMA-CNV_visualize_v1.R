#*******************************************************#
# Name: ENIGMA-CNV_visualize_v1.R			#
# Author: Ida                                   	#
# Date: 2022-01-07                              	#
# Aim: Visualizing CNVs and preparing for transfer	#
# Changes: Adapted scripts				#
# Run the script: Rscript ENIGMA-CNV_visualize_1.R	#
#                                               	#
#*******************************************************#

### Output: 
## Folders with visualized CNVs of interest, named {NameofDataset}_visualize/ with:
   # singleplots_50kb
   # singleplots_cnvofinterest
   # stackplots
## Files for transfer to ENIGMA-CNV:
   # ${Dataset}_autoX.flr_QC [Filtered CNV-dataset]
   # ${Dataset}_QC.txt [summary statistics for your raw and filtered CNV-files]
   # ${Dataset}_checklist.txt [checklist for submission]
   # ${Dataset}_CNVcarriers_precuration_0.3.txt [all CNVsofInterests that were visualized]
   # ${Dataset}_OverlapRef_0.3_TotalCNVsofInterest_precuration.txt [count of all CNVsofInterests - for overview]
   # ${Dataset}_DupsRelatives.txt [List of dups and relatives]
   # ${Dataset}_SexFile.txt [List of individuals including sex-information]

# Prerequisites: 
  # 1. CNVs called on your data with the ENIGMA-CNV protocol ("ENIGMA-CNV_CNVProtocol_v2.sh")
  # 2. A number of helper files (provided by ENIGMA-CNV) including:
      # a. This script ("ENIGMA-CNV_visualize_v1.R")
      # b. List of CNVs of interest (e.g. "CNVsofInterest_ukb_hg38.csv")
  # 3. Container enigma-cnv.sif installed

#  Start the clock!
ptm <- proc.time()

###################
#### Libraries ####
###################

# load necessary libraries
library(iPsychCNV)
library(plyr) # necessary for rbind.fill
library(tidyverse)
library(dplyr) 
library(optparse)
library(data.table)

# check for version of packages...
sessionInfo()

##########################
#### Define functions ####
##########################

##  Function: RemoveAbsolutePath: 
# Remove path from Filename with absolute path
RemoveAbsolutePath <- function(object)
{
  object <- gsub(".+/","",object)
  object <- gsub("/","",object)
  return(object)
}

## Function RandomlySelectn
# Randomly select n Individuals (if n<no of Individuals, return individuals)
RandomlySelectn <- function(Individuals, n)
{
  if (length(Individuals) <=n)
  {
    return(Individuals)
  }
  else
  {
    return(sample(Individuals,n))
  }
}

#############################
#### Retrieve arguments  ####
#############################

# Name of dataset
args <- commandArgs(trailingOnly=TRUE)
dataset <- args[1]
pfb <- args[2]
CNVofInterestFile <- args[3]
Overlapref <- as.numeric(args[4]) # default= 0.3 # How large a proportion of the CNV is overlapping with the CNVofInterest?
OverlapMin <- as.numeric(args[5]) # Minimum overlap, default = 0
OverlapMax <- as.numeric(args[6]) # Maximum overlap, default=5
chip <- as.character(args[7])
key_code <- as.character(args[8])
if(key_code == "NA") {
	key_code <- as.logical(key_code)
} else {
	key_code <- as.character(key_code)
}

# directories
visualizedir <- "/visualize/"
lrrbafdir <- "/lrrbafdir"
pfbdir <- "/pfb/"
analysisdir <- "/analysisdir/"
outdir <- "/outdir/"

# Files
CNVofInterestFile <- paste0(analysisdir, CNVofInterestFile)
cnvfile_auto <- paste0(outdir, dataset, ".auto.flr_QC")
cnvfile_X <- paste0(outdir, dataset, ".X.flr_QC")
QCfile_auto_pre <- paste0(outdir, dataset, ".auto.sumout")
QCfile_X_pre <- paste0(outdir, dataset, ".X.sumout")
QCfile_auto_post <- paste0(outdir, dataset, ".auto.sumout_QC")
QCfile_X_post <- paste0(outdir, dataset, ".X.sumout_QC")
filename_key <- paste0(outdir, dataset,"_deidentifykey.txt")
DupRelFile <- paste0(analysisdir, "DupsRelatives.txt")
DupRelFile_key <- paste0(outdir, dataset, "_DupsRelatives_key.txt")

#################################
#### Make output-directories ####
#################################

print("Making outputDirectories:")

# Make subdirectories for storing imaging files
stackdir <- paste0(visualizedir, "stackplots/")
dir.create(stackdir)

singledir_cnv <- paste0(visualizedir, "singleplots_cnvofinterest/")
dir.create(singledir_cnv)

singledir_50kb <- paste0(visualizedir, "singleplots_50kb/")
dir.create(singledir_50kb)

##########################################
#### Read in Files and add key to CNV ####
##########################################

# Start writing to an output file instead of to Terminal

# make a file list folder
Files <- list.files(path = lrrbafdir, full.names = TRUE, recursive = TRUE)
filename <- paste0(visualizedir, "Files.txt")
write.table(Files, file=filename, col.names=FALSE)

# check PFBfile 
PFBFile <- paste0(pfbdir, pfb) 
if ( ! file.exists(PFBFile)) {
  cat(paste ("\nFile ", PFBFile, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
}

print("Reading in files")

# read in CNVofinterest-file
if ( ! file.exists(CNVofInterestFile)) {
  cat(paste ("\nFile ", CNVofInterestFile, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
} else {
   cnvsofinterest <- fread(CNVofInterestFile)
   cnvsofinterest$ROI <- paste(cnvsofinterest$Chr, "_", cnvsofinterest$Start, "_", cnvsofinterest$Stop, sep="")
} 

## read in deidentified key
if ( ! file.exists(filename_key)) {
  cat(paste ("\nFile ", filename_key, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
} else {
   key <- read.table(filename_key, sep="\t", header=T)
   key$ID <-  RemoveAbsolutePath(key$File)
   key$File <- NULL
}

#############################################
# CNV-files, read in, add key, save to file #
#############################################

# Read in CNV-file, auto
if ( ! file.exists(cnvfile_auto)) {
  cat(paste ("\nFile ", cnvfile_auto, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
} else {
   cnv_noselect_auto <- ConvertPenntoRCNVs(cnvfile_auto) 
}

# Read in CNV-file, X
if ( ! file.exists(cnvfile_X)) {
  cat(paste ("\nFile ", cnvfile_X, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
} else {
   cnv_noselect_X <- ConvertPenntoRCNVs(cnvfile_X) 
}

# Put autosomal & X together
cnv_noselect <- rbind(cnv_noselect_auto, cnv_noselect_X)
cnv_noselect$ID <- RemoveAbsolutePath(cnv_noselect$File)

# merge deidentified key with CNVs
cnv_noselect_key <- merge(cnv_noselect,key,by="ID")

# Save to file
filename <- paste0(visualizedir, dataset, "_autoX.flr_QC")
if ( is.na(key_code)) {
	write.table(cnv_noselect_key, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
} else {
	cnv_noselect_key_noID <- cnv_noselect_key
	cnv_noselect_key_noID$ID <- NULL # Removing ID prior to saving to file
	cnv_noselect_key_noID$File <- NULL # Removing ID prior to saving to file
	write.table(cnv_noselect_key_noID, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
}

##############################################
### QC-files, read in, add key, save to file #
##############################################

# Read in QC-file, auto, pre
if ( ! file.exists(QCfile_auto_pre)) {
   cat(paste ("\nFile ", QCfile_auto_pre, ' does not exist! \n', sep='')) # warning message if wrong path
   stop('', call.=FALSE)
} else {
   QC_auto_pre <- read.table(QCfile_auto_pre, header=TRUE, stringsAsFactors=FALSE, na.strings = c("_")) 
   QC_auto_pre$QCstatus <- rep("preQC", nrow(QC_auto_pre)) # add column with QCstatus
}

# Read in QC-file, X, pre
if ( ! file.exists(QCfile_X_pre)) {
   cat(paste ("\nFile ", QCfile_X_pre, ' does not exist! \n', sep='')) # warning message if wrong path
   stop('', call.=FALSE)
} else {
   QC_X_pre <- read.table(QCfile_X_pre, header=TRUE, stringsAsFactors=FALSE, na.strings = c("_")) 
   QC_X_pre$QCstatus <- rep("preQC", nrow(QC_X_pre)) # add column with QCstatus
   QC_X_pre <- dplyr::rename(QC_X_pre, NumCNV_X = NumCNV) # change NumCNV to NumCNV_X
}

# Read in QC-file, auto, post
if ( ! file.exists(QCfile_auto_post)) {
  cat(paste ("\nFile ", QCfile_auto_post, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
} else {
  QC_auto_post <- read.table(QCfile_auto_post, header=TRUE, stringsAsFactors=FALSE, na.strings = c("_")) 
  QC_auto_post$QCstatus <- rep("postQC", nrow(QC_auto_post)) # add column with QCstatus
}

# Read in QC-file, X, pre
if ( ! file.exists(QCfile_X_post)) {
  cat(paste ("\nFile ", QCfile_X_post, ' does not exist! \n', sep='')) # warning message if wrong path
  stop('', call.=FALSE)
} else {
  QC_X_post <- read.table(QCfile_X_post, header=TRUE, stringsAsFactors=FALSE, na.strings = c("_"))
  QC_X_post$QCstatus <- rep("postQC", nrow(QC_X_post)) # add column with QCstatus
  QC_X_post <- dplyr::rename(QC_X_post, NumCNV_X = NumCNV) # change NumCNV to NumCNV_X
}

# Put together
QC_auto <- rbind(QC_auto_pre, QC_auto_post)
QC_X <- rbind(QC_X_pre, QC_X_post)
QC <- dplyr::left_join(QC_auto, QC_X) 

# Add chip, dataset & make ID without path
QC$Chip <- rep(chip, nrow(QC))
QC$Dataset <- rep(dataset, nrow(QC)) 
QC$ID <- RemoveAbsolutePath(QC$File)

# Separate on pre and postQC
preQC <- QC %>% 
	dplyr::filter(QCstatus == "preQC")
postQC <- QC %>% 
	dplyr::filter(QCstatus == "postQC")

# Merge deidentified key with QC
QC_key <- dplyr::left_join(QC,key)

# AllQC - Save to file
filename <- paste0(visualizedir, dataset, "_QC.txt")
if(is.na(key_code)) {
   write.table(QC, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
} else {
   QC_key_noID <- QC_key
   QC_key_noID$ID <- NULL # Removing ID prior to saving to file
   QC_key_noID$File <- NULL # Removing File prior to saving to file
   write.table(QC_key_noID, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
}

######################################
# Put CNVs together with QC - postQC #
######################################

# QC files
CNVs_QC <- cnv_noselect_key %>% 
  dplyr::filter(ID %in% postQC$ID) %>%
  dplyr::left_join(., postQC)
#print(head(CNVs_QC))


############
# QC Plots #
############

# Make a head-directory and subdirectories for storing imaging files
QCdir <- paste0(visualizedir, "QCplots/")
dir.create(QCdir)

# LRR_SD vs NumCNV 
plot <- QC_auto %>%
  ggplot(., mapping =aes(x=LRR_SD, y=NumCNV)) +
  geom_point() + 
  facet_wrap(~ QCstatus) +
  ggtitle("LRR_SD vs NumCNV") +
  geom_vline(xintercept=0.35, linetype="dotted", color="blue") +
  geom_vline(xintercept=0.5, linetype="dotted", color="red")

filename <- paste0(QCdir, dataset, "_LRR_SD_vs_NumCNV.png") #_", status, ".png")
ggsave(plot, file = filename)


# WF vs NumCNV 
plot <- QC_auto %>%
  ggplot(., mapping =aes(x=WF, y=NumCNV)) +
  geom_point() +
  facet_wrap(~ QCstatus) +
  ggtitle("WF vs NumCNV") +
  geom_vline(xintercept=0.05, linetype="dotted", color="blue") +
  geom_vline(xintercept=-0.05, linetype="dotted", color="blue")

filename <- paste0(QCdir, dataset, "_WF_vs_NumCNV.png") 
ggsave(plot, file = filename)


# BAF_drift vs NumCNV 
plot <- QC_auto %>%
  ggplot(., mapping =aes(x=BAF_drift, y=NumCNV)) +
  geom_point() +
  facet_wrap(~ QCstatus) +
  ggtitle("BAF_drift vs NumCNV") +
  geom_vline(xintercept=0.02, linetype="dotted", color="blue")

filename <- paste0(QCdir, dataset, "_BAFdrift_vs_NumCNV.png")
ggsave(plot, file = filename)

####################
# Histograms plots #
####################

# Histogram of NumCNV, pre/postQC
plot <- QC_auto %>%
  ggplot(., mapping=aes(x=NumCNV)) + 
  geom_histogram() +
  facet_wrap(~ QCstatus) +
  ggtitle("NumCNV, pre- & postQC") #+ 
#        ylim(0, 500)
filename <- paste0(QCdir, dataset, "_NumCNV_prepostQC_hist.png")
ggsave(plot, file=filename)

# Histogram of WF, pre/postQC     
plot <- QC_auto %>%
  ggplot(., mapping=aes(x=WF)) +
  geom_histogram() +
  facet_wrap(~ QCstatus) +
  ggtitle("WF, pre- & postQC")
filename <- paste0(QCdir, dataset, "_WF_prepostQC_hist.png")
ggsave(plot, file=filename)

# Histogram of LRR_SD
plot <- QC_auto %>%
  ggplot(., mapping=aes(x=LRR_SD)) +
  geom_histogram() +
  facet_wrap(~ QCstatus) +
  ggtitle("LRR_SD, pre- & postQC") +
  ylim(0,500)
filename <- paste0(QCdir, dataset, "_LRR_SD_prepostQC_hist.png")
ggsave(plot, file=filename)

# Histogram of BAF_drift
plot <- QC_auto %>%
  ggplot(., mapping=aes(x=BAF_drift)) +
  geom_histogram() +
  facet_wrap(~ QCstatus) +
  ggtitle("BAF_drift, pre- & postQC") +
  ylim(0,500)
filename <- paste0(QCdir, dataset, "_BAF_drift_prepostQC_hist.png")
ggsave(plot, file=filename)

##################################
#### Select CNVs of interest ####
#################################

# Select Samples from roi
print("Start Selection of Samples from ROI")
result_total <- SelectSamplesFromROI(CNVs_QC, roi = cnvsofinterest, Overlap=OverlapMin, OverlapMax=OverlapMax)
print(head(result_total))
cnvsofinterest_roi <- dplyr::select(cnvsofinterest, ROI, Syndrome, CNVofInterest) # short info on CNVofinterest
result_total <- dplyr::left_join(result_total, cnvsofinterest_roi, by="ROI")  # merge two dataframes
result_total <- subset(result_total, OverlapRef >Overlapref) # OverlapCNV > Overlapcnv & ) # only select those within Overlapref
print("CNVs of Interest found in total:")
print(result_total)

if (dim(result_total)[1] == 0)  {
  print("No CNVs of Interest for visualization in this dataset")
} else {

#### Do counts
knitr::kable(
  result_total %>% 
  dcast(CNVofInterest + Syndrome ~ CN),
  caption = paste0("CNVs of Interest in ", dataset, "  overlapref = ", Overlapref),
  format = 'pandoc'
)

knitr::kable(
  result_total %>% 
  dplyr::filter(LRR_SD<=0.35) %>%
  dcast(CNVofInterest + Syndrome ~ CN),
  caption = paste0("CNVs of Interest in ", dataset, "  overlap_ratio = ", Overlapref, ", LRR_SD<0.35"),
  format = 'pandoc'
)

tmp <- result_total %>% 
        dcast(CNVofInterest + Syndrome ~ CN)

# save to file
filename <- paste(visualizedir, dataset, "_OverlapRef_", Overlapref, "_TotalCNVsofInterest_precuration.txt", sep="")
write.table(tmp, file=filename, sep="\t", row.names = FALSE, quote = FALSE)


##########################################
#### Making lists for curation of CNVs ###
##########################################

## Overall carriers
CNVs_carriers <- result_total %>% 
  dplyr::filter(CN !=2) %>% 
  arrange(., CNVofInterest, dplyr::desc(Length), CN) %>% # sort CNVs with largest first and then by CN
  dplyr::select(one_of(c("NumCNV", "LRR_SD", "OverlapRef", "CNVofInterest", "ID")), everything())

# write to file
filename <- paste0(visualizedir, dataset, "_CNVcarriers_precuration_", Overlapref, ".txt")

if(is.na(key_code)) {
  write.table(CNVs_carriers, file  = filename, row.names=FALSE, quote=FALSE, sep="\t")
} else {
  CNVs_carriers_noID <- CNVs_carriers
  CNVs_carriers_noID$ID <- NULL # Removing ID prior to saving to file
  CNVs_carriers_noID$File <- NULL # Removing File prior to saving to file
  write.table(CNVs_carriers_noID, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
}

#######################################
# Plot CNVsofInterest in single plots #
#######################################

result_total_single <- result_total
result_total_single$ID <- RemoveAbsolutePath(result_total_single$ID)
print("Here are the single CNVs:")
print(result_total_single)

PlotCNVsFromDataFrame(DF=result_total_single,
                 PathRawData=NA,
                 Cores=1, Skip=0, PlotPosition=10, Pattern="",recursive=TRUE, dpi=300, # 1 is too little, 10 is a bit too much, trying with 6
                 Files=Files,
                 SNPList = PFBFile,
                 key=key_code, 
                 OutFolder=singledir_cnv) 

####################################
# Plot CNVsofInterest in stackplot #
####################################

x <- 1 # start with CNV 1

# Loop over each cnv of interest
while(x <= length(row.names(cnvsofinterest)))
{
  print(x)
  #### Specific CNV targeted
  cnv <- data.frame(cnvsofinterest[x,])
  # read in data of CNV
  locus <- cnv$CNVofInterest
  start <- cnv$Start
  stop <- cnv$Stop
  Pos_start <- cnv$Pos_start
  Pos_stop <- cnv$Pos_stop
  Chromosome <- cnv$Chr
 
 	#### Select specific CNV from results
	result <- result_total %>% 
	  dplyr::filter(CNVofInterest == locus)

    	if(nrow(result) == 0) {} else { # only plot if hits
	  result <- arrange(result, dplyr::desc(Length), CN) # sort CNVs with largest first and then by CN
	  result$locus <- rep(locus, nrow(result)) # making locus the name of my CNVofInterest (to get plot name based on this)
	  print(result) 
    	}
    	if( length(row.names(result)) != 0 ) { #
		print("Now plotting")
		print(locus)
   
		#### Stackplot
		## 1. Add 3 random individuals in list to plot

		# a. List of individuals that are not carriers
		AllIDs <-  unique(cnv_noselect$ID) # all IDs with CNVs
		non_carriers <- setdiff(AllIDs, unique(result$ID)) # individuals that are not carriers of specific CNV
		
		# b. randomly select 3 individuals & deidentify them 
		randomIDs <- RandomlySelectn(non_carriers, 3)
		randomIDs_deidentified <- unique(cnv_noselect_key[cnv_noselect_key$ID %in% randomIDs, c("ID","ID_deidentified")]) # get ID with deidentified ID
             	print(paste0("These are the RandomIDs:", randomIDs))

 		# c Add randomIDs for individuals to plot
                result_all <- rbind.fill(result,randomIDs_deidentified) # Add individuals to CNV result-list
		print("Overlap CNVofInterest and dataset & the additional controls plotted:")
		print(result_all)

		# d. List of all individuals to plot
		# List, all individuals to plot
                IndividualstoPlot <- unique(result_all$ID)
		IndividualstoPlot <- RemoveAbsolutePath(IndividualstoPlot)
		print("Individuals to plot:")
		print(IndividualstoPlot)

              	## 2. Define position for Stackplot for this specific CNV
		Pos <- paste("chr", Chromosome, ":",  Pos_start, "-", Pos_stop, sep="")
		print(paste("Position of plot", Pos, sep=":"))
            
		# Define position of CNV of interest
		Highlight <-  paste("chr", Chromosome, ":", start, "-", stop, sep="")
		print(paste("Highlight", Highlight, sep=":"))

		## 3. Decrease number of CNVs read in (or Stackplot may crash)
		cnv_noselect_fewer <- cnv_noselect %>%
		  dplyr::filter(Chr == Chromosome)

		## 4. Making sure plot gets the right name
		ID_roi <- result_all %>% 
		  dplyr::select(ID, locus, ID_deidentified) %>% 
		  unique()
		print(ID_roi)
		cnv_noselect_fewer <- cnv_noselect_fewer %>%
		  dplyr::filter(ID %in% result_all$ID) %>%
		  left_join(ID_roi,.)
		print(cnv_noselect_fewer)
		
		## 5. Stackplot	
		StackPlot(Pos=Pos, 
			IDs=IndividualstoPlot,
			PathRawData=NA,
			CNVs= cnv_noselect_fewer, 
			Highlight = Highlight,
			SNPList = PFBFile,
			Files = Files,
			key=key_code,
			Pattern="", 
			OutFolder = stackdir)
  
      } else { 
        # skip plotting if nothing in result and don't want to stackplot noncarriers
        x <- x + 1 ## increment to continue to next CNV
        next; # continue to next CNV of interest
    }
    x <- x + 1 ## increment to continue to next CNV
}

} # end of stuff do with CNVsofInterest


######################################
#### Plot all CNVs larger than ...####
######################################

#### Make Plots for:
# Stackplot
# (Stackplot for all individuals in dataset for specific CNVs)
# Single plots with defined axis
# Plots for all other large CNVs

# Only select CNVs that are larger than 50 kb
cnv_noselect_50kb <- cnv_noselect_key %>%
  dplyr::filter(Length>50000)

print("Examples of the CNVs>50kb to be plotted:")
print(head(cnv_noselect_50kb))

cnv_noselect_50kb$ID <- RemoveAbsolutePath(cnv_noselect_50kb$ID)

# Save all CNVs >50kb to file (for curation)
filename <- paste0(visualizedir, dataset, "_CNVcarriers50kb_precuration_", Overlapref, ".txt")
if(is.na(key_code)) {
  write.table(cnv_noselect_50kb, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
} else {
  cnv_noselect_50kb_noID <- cnv_noselect_50kb
  cnv_noselect_50kb_noID$ID <- NULL # Removing ID prior to saving to file
  cnv_noselect_50kb_noID$File <- NULL # Removing File prior to saving to file
  write.table(cnv_noselect_50kb_noID, file  = filename, sep="\t", quote=FALSE, row.names = FALSE)
}

#### Plot single CNVs larger than 50 kb
PlotCNVsFromDataFrame(DF=cnv_noselect_50kb,
                      PathRawData=NA,
                      Cores=1, Skip=0, PlotPosition=8, Pattern="",recursive=TRUE, dpi=300, # 1 is too little, 10 is a bit too much, trying with 8
                      Files=Files,
                      SNPList = PFBFile,
                      key=key_code,
                      OutFolder=singledir_50kb)


