## Merge MRI freesurfer outputs ##

# Author: Rune Bøen for the ENIGMA-CNV 
# Year: 2021 

# Get the current directory 
directory <- getwd()

# find folders with the freesurfer outputs
CorticalDirectory <- paste(directory, "/outputs/", sep="")

#### Read in datafiles

outputfiles <- c("lh_area_CorticalMeasuresENIGMA.csv", "rh_area_CorticalMeasuresENIGMA.csv","lh_thickness_CorticalMeasuresENIGMA.csv",
                 "rh_thickness_CorticalMeasuresENIGMA.csv", "lh_thicknessstd_CorticalMeasuresENIGMA.csv", "rh_thicknessstd_CorticalMeasuresENIGMA.csv", "lh_volume_CorticalMeasuresENIGMA.csv", 
                 "rh_volume_CorticalMeasuresENIGMA.csv", "lh_gauscurv_CorticalMeasuresENIGMA.csv", "rh_gauscurv_CorticalMeasuresENIGMA.csv", "lh_curvind_CorticalMeasuresENIGMA.csv", "rh_curvind_CorticalMeasuresENIGMA.csv", 
                 "lh_meancurv_CorticalMeasuresENIGMA.csv","rh_meancurv_CorticalMeasuresENIGMA.csv","lh_foldind_CorticalMeasuresENIGMA.csv", "rh_foldind_CorticalMeasuresENIGMA.csv", "subcortical_CorticalMeasuresENIGMA.csv",
                 "EulerNumbers.csv", "LGI_CorticalMeasuresENIGMA.csv","ThalamicNuclei_CorticalMeasuresENIGMA.csv", "HippocampalSubfields_CorticalMeasuresENIGMA.csv", 
                "AmygdalarNuclei_CorticalMeasuresENIGMA.csv", "HypothalamicSubunits_CorticalMeasuresENIGMA.csv")
j = 0
for (i in 1:length(outputfiles)) {
  if (file.exists(paste(CorticalDirectory , outputfiles[i], sep = ""))) {
    if (i < 18) {
    data <- read.table(paste(CorticalDirectory, outputfiles[i], sep = ""), header=T, sep="", fill = T) 
    }
    if (i >=18 ) { 
    data <- read.table(paste(CorticalDirectory, outputfiles[i], sep = ""), header=T, sep=",", fill = T) # separated with comma for the euler and optional analyses 
  }
    colnames(data)[1] <- "ID" # change first column name to ID
    j = j + 1
  
    
  if (j == 1) {
      alldata <- data  
      }
   
  
   if (j > 1) {
      # avoid duplicated columns 
        nondup <- setdiff(colnames(data),colnames(alldata))

       alldata <- merge(alldata, data[c("ID", nondup)], by="ID")
  
          }
  }}
cat(j,"file(s) merged")

# write summary imaging file to output folder 
write.table(alldata, file=paste(directory, "/ENIGMA_CNV_ImagingFile.csv", sep=""), sep=",",  quote = FALSE, row.names=FALSE)


