#!/bin/bash

set -xv #print commands
exec > >(tee -i ENIGMA-CNV_logfile.txt) # write output to logfile
exec 2>&1 # ensures that all std/stderr are also written to log-file

# enabling singularity
#module purge
module load singularity/3.8.5 # USER-INPUT - modify according to your version of singularity... (check your version by: singularity --version)

# date and start the clock
date=$(date +%y%m%d)
START=$(date +%s)

#: Document: ENIGMA-CNV_CNVProtocol_v2.sh
#: Title: ENIGMA CNV Working group – standardized protocol for calling and filtering CNVs
#: Purpose: 
	# Call raw CNVs on Illumina samples and Affymetrix samples [the latter needs preprocessing first] 
		# For Affymetrix, please refer to the script: "ENIGMA-CNV_AffyPrep_Protocol_v2.sh" 
	# Filtering of raw CNVs
	# Visualization of selected CNVs of Interest and CNVs>50kb
# Date, v1: 2015-07-06
# Date, v2: 2022-02
# Authors, v1: Ida Elken Sønderby, Omar Gustafsson. Input and tested by Allan McRae and Nicola Armstrong
# Versions: v1.1. Minor bugs # v1.2: Changed the protocol so that it can be run as a bash-script. Implemented Rscripts for downstream filtering of spurious CNVs # v1.3: Changed incorporation of keep and remove-file
# Authors, v2: Ida Elken Sønderby. Input and test by ????
# v2.0: Altered to use software containers, included visualization in script

################################
#### INFO prior to starting ####
################################

# OBS – only data from a single chip can be run - if data is available from more than one type of chip, please run the protocol separately for each different chip set

# 1. Please read and follow the instructions in the word-document "Instructions, ENIGMA-CNV working group, v2.0" before commencing analysis, which includes:
# - identifying appropriate files for CNV calling
# - downloading and installing required software and scripts
# - adjust the names and directory-instructions in the script itself as directed in 0a below [labeled USER-INPUT needed].

# 2. Run the script:
    # a. Prior to this, you may need to change file permission in terminal: chmod +u+x ${Dataset}_ENIGMA_CNV_CNVProtocol_v2.sh
    # b. Run script in terminal: bash ./${Dataset}_ENIGMA_CNV_CNVProtocol_v2.sh

# 3. After the run, the printed log will be present in the Analysis-folder: ENIGMA-CNV_logfile.txt (in case something goes wrong, you can hopefully retrack it from here, please check for error-messages)

# 4. After, the run, please check the checklist found in ${Dataset}_checklist.txt to see if things make sense.

# 5. Please, send the compressed files in the ${Dataset}_visualize.tar.gz-folder to: enigmacnvhelpdesk@gmail.com

# Please address any questions to: enigmacnvhelpdesk@gmail.com

##################################################
## 0a. USER-files and input - USER input needed ##
##################################################

# General info
declare Dataset="TOPMD" # Replace TOPMD with the name of your dataset
declare ResponsiblePI="OleAndreassen" # Replace OleAndreassen with the name of the PI [no spaces, please]
declare Email_PI="o.a.andreassen@medisin.uio.no" # Replace o.a.andreassen@medisin.uio.no with the e-mail of your PI to enable us to contact the PI directly in case of questions.
declare Analyst="IdaSoenderby" # Replace IdaSoenderby with the name of the analyst [no spaces, please]
declare Email_Analyst="i.e.sonderby@medisin.uio.no" # Replace e-mail with the e-mail of the analyst to enable us to contact the analyst directly in case of questions.
declare ANALYSISDIR="/cluster/projects/p697/users/idaeson/CNVCalling/enigmacnv/ENIGMA-CNV_Analysis/" # replace with the full path for the Analysis-folder on your computer/server
declare deidentify="NA" # only change to YES if deidentification is really important to you, otherwise keep NA

# a. Genetic information files - input specific to your genotyping chip
declare Chip="Illumina_DeCodeGenetics_V1_v2" # genotyping chip: Note - if your dataset is Affymetrix, make sure to put in "Affy6" - otherwise the script will not run appropriately
declare Chipversion="_" # version of chip (if applicable) [set as NA if non-applicable]
declare ILLUMINAREPORTDIR="${ANALYSISDIR}"  # absolute path to your Illumina-Final Report-file. Can be replaced with ${ANALYSISDIR} if you placed it there
declare IlluminaReport="339syni_DeCodeGenetics_V1_v2_FinalReport.txt" # name of your Illumina-Final Report-file
declare SNPPosFile="339syni_DeCodeGenetics_V1_v2_SNP_Map.txt" 
	# The snp-position-file is a tab-delimited file with the positions of the SNPs on your chip, containing at least the columns below (with the exact (!) headers). These columns are for instance present in the SNP-map-file [.map] generated together with your IlluminaReport or the Illumina manifest file [.bpm]:
	# Name	Chromosome	Position
	# rs1000000	12	126890980
	# rs1000002	3	183635768
	# rs10000023	4	95733906
declare genomeversion="hg19" # Genome-version of SNPpositionfile. It is important that this is correct - otherwise CNV calls and visualization become wrong.
# IF BAF-LRR-files already present for your dataset (for instance Affy-users)
declare BAFLRRpresent="no" # USER-INPUT - only put "yes" if you have BAF-LRR-files ready available - otherwise, leave the "no"
if [ $BAFLRRpresent = "yes" ]
    then
    declare LRRBAFDIR="/cluster/projects/p697/users/idaeson/CNVCalling/TOPMD/IlluminaFinalReport/" # USER-INPUT -  directory with PennCNV-inputfiles
# NOTE - if the lrr-baf-folder has several subfolders with lrrbaf-files, the script may run into issues... If so, please contact the helpdesk
    else
    mkdir ${ANALYSISDIR}/LRRBAF_Files/
declare LRRBAFDIR="${ANALYSISDIR}/LRRBAF_Files/" # Note - this will place the PennCNV input files in a subfolder of  your ENIGMA-CNV analysis folder. These take up quite a lot of space - if you wish them to be placed elsewhere, write the full path of the wanted folder (USER-INPUT)
fi
# Post/prefixes in LRR-BAF-files
declare postscript="" # e.g ".penn" # IF converting from IlluminaFinalReport to LRRBAF-files with this script, this should be left empty. LRR-BAF files from previous convertions may have a postfix (e.g. ".penn", "_lrrbaf"), please input this here (USER-INPUT).
declare Affyprescript="" # e.g. "gw." # Affymetrix files names often get this prescript, which needs to be removed to couple samples. Replace with different prescript if relevant (USER-INPUT).

# b. Cohort-generated files
declare SexFile="${ANALYSISDIR}/SexFile.txt" # USER-INPUT - absolute path to your sex-file
# If sex for a sample is not provided in sexfile, or if --sexfile is not specified, PennCNV will try to predict the gender of the sample. It is highly recommended to provide a sexfile [saves time].
declare gendermissing="0" # USER-INPUT, number of individuals with gender missing in sexfile
declare RelativeFile="${ANALYSISDIR}/DupsRelatives.txt" # USER-INPUT - absolute path to your relative-file
declare KeepFile="${ANALYSISDIR}/KeepFile.txt" # USER-INPUT # absolute path to your KeepFile.txt - leave empty if you do not have a KeepFile
declare RemoveFile="${ANALYSISDIR}/RemoveFile.txt" # USER-INPUT # absolute path to your RemoveFile.txt - leave empty if you do not have a RemoveFile

### c. Genotyping-chip dependent information - 
declare HMMname="/opt/PennCNV-1.0.5/lib/hhall.hmm" # USER-INPUT - Please replace with the correct HMM-file. examples:  /opt/PennCNV-1.0.5/lib/hhall.hmm; for /opt/PennCNV-1.0.5/libhh550.hmm /opt/PennCNV-1.0.5/affy/libgw6/affygw6.hmm

# IF your dataset has more than 300 individuals, you can generate your own PFB-file based on the frequency in your dataset
declare NoofIndividuals="" # e.g "1000" # No of individuals (e.g. "300") to be used for generating PFB-file and GCC-file (must be at least 300 individuals of good quality). Leave empty if you want to use all your individuals. The more individuals you use, the more precise the estimate becomes but the longer it will take to generate the PFB-model. For the NORMENT dataset, generating a PFB- and GCMODEL-file for the OmniExpress12v1.0 containing 730,525 markers using 1000 individuals took ~90 min on a Mac laptop with a 2.53 GHz Intel Core i5 processor and 4 GB of working memory

# IF your dataset contains less than 300 individuals, you need to use a generic version of the PFB-file. Please confer with the ENIGMA-CNV working group and put in the correct names of the files. # NOTE - IF more than 300 individuals, these files will be generated later and named "${Dataset}_${genomeversion}.pfb" (likewise for GCName)
declare PFB="DeCodeGenetics_V1_20012591_A1_${genomeversion}" # ONLY USER-INPUT for those with <300 individuals -  replace with the correct PFB & GCMODEL (note without extensions) 
declare PFBname="${PFB}.pfb"  # no input 
declare GCname="${PFB}.gcmodel" # no input

#####################################################################
## 0b. State cut-offs and predefined files/folders - NO user input ##
#####################################################################

# a. List of input and output-files from ENIGMA CNV calling protocol
declare List_preQC="${Dataset}_ListofInputFiles_preQC.txt"
declare List_postQC="${Dataset}_ListofInputFiles_postQC.txt"
declare SOFTWAREDIR="${ANALYSISDIR}" # USER-INPUT (enigmacnv.sif-placement) OBS - for the majority of cohorts this will be the ${ANALYSISDIR}. Can be replaced with absolut path, e.g. /cluster/projects/p697/users/idaeson/CNVCalling/software/"

# b. Cut-offs, autosomal chromosomes filtering
declare LRR_SD=0.40 
declare BAF_drift=0.02 
declare WF=0.05
declare NoofSNPs=15
declare MergeFraction=0.30 # depending on chip, this may need adjustment - this was appropriate for Illumina OmniExpress where 0.2 was too low. 
declare MinQueryFrac=0.5 # define the overlap with the regions necessary to be excluded

# c. Cut-offs, X chromosome filtering
# For the X-chromoxome, only small CNVs are removed and CNVs merged whereas BAF-drift and WF, LRR_SD are skipped (by setting them abnormally high) to not filter based on X-chromosome only.
declare NoofSNPs_X=15
declare MergeFraction_X=0.30
declare LRR_SD_X=0.99 
declare BAF_drift_X=0.99 
declare WF_X=0.99 

### d. Parameters needed for visualization
declare VISUALIZEDIR=${ANALYSISDIR}/${Dataset}_visualize/
mkdir ${VISUALIZEDIR}
declare CNVofInterestFile="CNVsofInterest_ENIGMA-CNV_${genomeversion}.csv" # appropriate CNVsofInterest-file for visualization (changes according to genome version)
Overlapref=0.3 # How large a proportion of the CNV is overlapping with the CNVofInterest? 
OverlapMin=0.35 # Minimum overlap
OverlapMax=5 # Maximum overlap

### e. Output directories (to not clutter Analysis-dir)
declare OUTDIR=${ANALYSISDIR}/${Dataset}_output/
mkdir ${OUTDIR}

##################
#### ANALYSIS ####
##################

###########################
## The protocol in short ##
###########################

#### A. Generate input-files for PennCNV
	## Step 1: Generate inputfiles from Illumina FinalReport files
	## Step 2: Make a list of sample inputfiles for PennCNV

#### B. Select helper files
	## Step 1. Select helper-files

#### C: Do CNV Calling
	## Step 1: Call CNVs on autosomal chromosomes with GC-adjustment
	## Step 2: Call CNVs on X-chromosome with GC-adjustment

#### D: First round of QC
	## Step 1: QC on CNVs, 1st round. Obtain summary statistics
	## Step 2. Merge CNVs
	## Step 3. Remove spurious CNV calls in specific genomic regions
	## Step 4. Obtain summary statistics for the QCed dataset
	## Step 5. Removing QC'ed individuals from sumout-lists

#### E: Deidentification

#### F: CNV visualization

#### G: Data transfer
	## Step 1: Make folder for file-transfer

#########################################
## A. Generate input-files for PennCNV ##
#########################################

###############################################################
# Step 1: Generate inputfiles from Illumina FinalReport files #
###############################################################

# These steps convert the Illumina Report files into separate files for each individual with intensity data for each individual sample
if [ $BAFLRRpresent != "yes" ]
then
# a. Split IlluminaReport into one file for each individual sample
singularity exec --no-home -B ${ILLUMINAREPORTDIR}:/illuminadir -B ${LRRBAFDIR}:/lrrbafdir  ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5//split_illumina_report.pl --prefix /lrrbafdir/ /illuminadir/${IlluminaReport}
fi
	#  "-prefix"	used to specify the prefix of the file name (in this case, save the file to the ${ANALYSISDIR}/LRRBAF_Files/-directory).
	#  "-comma"	can be added to the command in case the genotyping center provide the report file in comma-delimited format rather than tab-delimited format

	# Output of this file is a file for each individual named after the “Sample ID” field (e.g. NORMENT1) in the original IlluminaReport file with the following (tab-delimited) format:
		# Name	NORMENT1.Log R Ratio	NORMENT1.B Allele Freq
		# SNP1	-0.0038	0.0161
		# SNP2	0.0073	0.9943
		# rs10000023	-0.0307	0.0026
		# 	etc…

##########################################################
## Step 2: Make a list of sample inputfiles for PennCNV ##
##########################################################

# a. Generate a list-file with one individual on each line with the full path for its inputfile (i.e. the output from step1)
find ${LRRBAFDIR} -type f -name '*' > ${OUTDIR}/${List_preQC}

# b. Keep individuals based on your KeepFile.txt
if [ -f "${KeepFile}" ] # If Keepfile exist
   then # keep only those samples
		awk '{print $1,$1}' ${OUTDIR}/${List_preQC} | awk -v postscript=${postscript} -v prescript=${prescript} '{gsub(/.+\//,"\/",$1); gsub(/\//,"",$1); gsub(postscript,"",$1); gsub(prescript,"",$1); print}' | awk 'FNR==NR {k[$1];next} {if ($1 in k) {print $2} else {}}' ${KeepFile} -  >${OUTDIR}/${List_postQC}
   else # keep everyone
   cp ${OUTDIR}/${List_preQC} ${OUTDIR}/${List_postQC}
fi

# c. -and remove individuals based on your removefile
if [ -f "$RemoveFile" ] # if Removefile exist
   then # Remove samples
        	awk '{print $1,$1}' ${OUTDIR}/${List_postQC} | awk -v postscript=${postscript} -v prescript=${prescript} '{gsub(/.+\//,"\/",$1); gsub(/\//,"",$1); gsub(postscript,"",$1); gsub(prescript,"",$1); print}' | awk 'FNR==NR {k[$1];next} {if ($1 in k) {} else {print $2}}' ${RemoveFile} - >tmp
	mv tmp ${OUTDIR}/${List_postQC}
fi

## Change input-file list so it is compatible with containers

# Adjust to make input for container
cp ${OUTDIR}/${List_postQC} ${OUTDIR}/${List_postQC}_adj
sed -i -e 's/.*\//\/lrrbafdir\//' ${OUTDIR}/${List_postQC}_adj
# NOTE - if files come from several folders for lrr-baf-files, this command may run into issues... Please contact the helpdesk

#######################################
# Step 3: Generate PFB & GCMODEL-file #
#######################################

	# Description: The PFB-file (population frequency of B-allele file) supplies the PFB information for each marker, and gives the chromosome coordinates information to PennCNV for CNV calling. It is a tab-delimited text file with four columns, representing marker name, chromosome, position and PFB values.
	# The script compile_pfb_new.pl compiles a PFB file from multiple signal intensity files containing BAF values
	# The script cal_gc_snp.pl calculates GC content surrounding each marker within specified sliding window, using the UCSC GC annotation file.

declare length_fileinput=`wc -l ${OUTDIR}/${List_postQC} | awk '{print $1}'` # number of individuals in

if [ ${length_fileinput} -gt 299 ] # OBS - may need to exchange -gt with > (depending on your system)
	then
  echo "more than 299 individuals, a PFB-file for your dataset will be created"
	declare PFBname="${Dataset}_${genomeversion}.pfb" # PFB-file
	declare GCname="${Dataset}_${genomeversion}.gcmodel" # GC-model-file
	declare List_Helperfiles="${Dataset}_ListofInputFiles_PFB.txt" # files used for input for PFB

	if [ -n "${NoofIndividuals}" ] ## variable exists and is not empty
	then
		echo "number of individuals used for generating PFB-file: ${NoofIndividuals}"
	else
		declare NoofIndividuals=${length_fileinput}
		echo "number of individuals used for generating PFB-file: ${NoofIndividuals}"
	fi
		# a. Generate a list of x individuals randomly selected from your file
		export NoofIndividuals; awk 'BEGIN {p=ENVIRON["NoofIndividuals"]; srand();} {a[NR]=$0} END{for(i=1; i<=p; i++){x=int(rand()*NR) + 1; print a[x]}}' ${OUTDIR}//${List_postQC} >${OUTDIR}/${List_Helperfiles}
		# b. Generation of PFB-file
		perl compile_pfb_new.pl --listfile ${OUTDIR}/${List_Helperfiles} -snpposfile ${ANALYSISDIR}/${SNPPosFile} --output ${ANALYSISDIR}/${PFBname}

			# --output <file>             specify output file (default: STDOUT)
			# --snpposfile <file>         a file that contains Chr and Position for SNPs
			# --listfile <file>           a listfile that contains signal file names

		# c. Generation of GC-model file
		singularity exec --no-home -B ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif cp /opt/PennCNV-1.0.5/gc_file/${genomeversion}.gc5Base.txt.gz /analysisdir/ # copy gcbase-file over from penncnv-dir to be able to unzip
		gunzip ${ANALYSISDIR}/${genomeversion}.gc5Base.txt.gz
		singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/cal_gc_snp.pl /analysisdir/${genomeversion}.gc5Base.txt /analysisdir/${PFBname} -output /analysisdir/${GCname}
		rm ${ANALYSISDIR}/${genomeversion}.gc5Base.txt
else
	echo "less than 300 individuals, please choose a generic PFB-file after conferring with the ENIGMA-CNV working group"
fi

#######################
## C: Do CNV Calling ##
#######################

# Autosomal and X-chromosome CNVs are called separately

## Step 1: Call CNVs on autosomal chromosomes with GC-adjustment
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir -B ${LRRBAFDIR}:/lrrbafdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/detect_cnv.pl -test -hmm ${HMMname} -pfb /analysisdir/${PFBname} -gcmodel /analysisdir/${GCname} -list outdir/${List_postQC}_adj --confidence -out outdir/${Dataset}.auto.raw  -log outdir/${Dataset}.auto.raw.log

	# --test		tells the program to generate CNV calls
	# --confidence	calculate confidence for each CNV
	# --hmmfile and –pfbfile	provides the files for hmm- & pfb-files
	# --gcmodel	implements a wave adjustment procedure for genomic waves which reduce false positive calls. It is recommended when if a large fraction of your samples have waviness factor (WF value) less than -0.04 or higher than 0.04
	# -list		provides the file with the list of samples you want called
	# –log		tells the program to write log information
	# --out		raw cnvcalls for all input individuals

# Note: This took ~48 hours to run for the MAS sample which comprises 925 individuals and 1,8 mio marker on the Affymetrix genomewide array 6.0-platform.


## Step 2: Call CNVs on X-chromosome with GC-adjustment

# a. Make sex-file for your inputfile
awk '{print $1,$1}' ${OUTDIR}${List_postQC}_adj | awk -v postscript=${postscript} -v prescript=${prescript} '{sub(/.+\//,"\/",$1); sub(/\//,"",$1); gsub(postscript,"",$1); gsub(prescript,"",$1); print}' | awk 'FNR==NR {k[$1]=$2;next} {if ($1 in k) {print k[$1] "\t" $2}}' - ${SexFile} >${OUTDIR}/${Dataset}_SexFile.txt

    # If sex for a sample is not provided in sexfile, or if --sexfile is not specified, PennCNV will try to predict the gender of the sample. It is highly recommended to provide a sexfile [saves time].
    # This command couples the full path of each individual input-file to sex with the following end-format:
    # 	/Volumes/CNV_Calling/Analysis/PennCNV_InputFiles/TOP1	female
    # 	/Volumes/CNV_Calling/Analysis/PennCNV_InputFiles/TOP2	male
    # 	etc

# b. Call CNVs on X-chromosome
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir -B ${LRRBAFDIR}:/lrrbafdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/detect_cnv.pl -test -hmm ${HMMname} -pfb /analysisdir/${PFBname} -gcmodel /analysisdir/${GCname} -list outdir/${List_postQC}_adj --confidence -out outdir/${Dataset}.X.raw  -log outdir/${Dataset}.X.raw.log --chrx --sexfile outdir/${Dataset}_SexFile.txt
	# --chrx		specifies that x-chromosome should be called
	# --sexfile	provides the sexfile data for the calling

# Note: This took ~48 hours to run for the MAS sample which comprises 925 individuals and 1,8 mio marker on the Affymetrix genomewide array 6.0-platform on a ??? specify computer etc...

######################
## D. Downstream QC ##
######################

###########
# OUTLINE #
###########

# The raw CNV calls need to have calls from low quality samples eliminated and low quality calls need to be removed.

# AUTOSOMAL CNVs:
# Step 1: QC on CNVs, 1st round. Obtain summary statistics
# Step 2. Merge CNVs
# Step 3. Removing spurious CNV calls in specific genomic regions
# Step 4. Obtain summary statistics for the QCed dataset

# X-chromosomal CNVs:
# Step 1: QC on CNVs, 1st round. Obtain summary statistics
# Step 2. Merge CNVs
# Step 3. Remove spurious CNV calls in specific genomic regions
# Step 4. Obtain summary statistics for the QCed dataset

# Common:
# Step 5. Removing QC'ed individuals from sumout-lists
# Step 6: Putting together checklist-file


####################
## AUTOSOMAL CNVs ##
####################

############################################################
# Step 1: QC on CNVs, 1st round. Obtain summary statistics #
############################################################

# The filter_cnv.pl program identifies low-quality samples from a genotyping experiment and eliminates them from future analysis. This analysis requires the output LOG file from CNV calling in addition to the raw cnv-file.

# a. obtain summary statistics for dataset
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir   ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/filter_cnv.pl outdir/${Dataset}.auto.raw --qclrrsd ${LRR_SD} --qcbafdrift ${BAF_drift} --qcwf ${WF} --numsnp ${NoofSNPs} --qclogfile outdir/${Dataset}.auto.raw.log --qcpassout outdir/${Dataset}.auto.passout --qcsumout outdir/${Dataset}.auto.sumout --out outdir/${Dataset}.auto.flr

echo "Finished first filtering of autosomal CNVs"

######################
# Step 2: Merge CNVs #
######################


# i. 1st time
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir  ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/clean_cnv.pl combineseg --fraction ${MergeFraction} --bp --signalfile /analysisdir/${PFBname} outdir/${Dataset}.auto.flr --output outdir/${Dataset}.autosomal.flr_mrg1

# ii. This command ensures that CNVs are getting merged until there are no more CNVs to merge within the defined distance
{
i=1
while [ ${i} -lt 50 ]; do
declare j=$(($i+1));
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5//clean_cnv.pl combineseg --fraction ${MergeFraction} --bp --signalfile /analysisdir/${PFBname} outdir/${Dataset}.autosomal.flr_mrg${i} --output outdir/${Dataset}.autosomal.flr_mrg${j}

declare length1=`awk 'END {print NR}' ${OUTDIR}/${Dataset}.autosomal.flr_mrg${i}`
declare length2=`awk 'END {print NR}' ${OUTDIR}/${Dataset}.autosomal.flr_mrg${j}`
if [ ${length1} -eq ${length2} ]
then
cp ${OUTDIR}/${Dataset}.autosomal.flr_mrg${j} ${OUTDIR}/${Dataset}.auto.flr_mrg_final
break;
fi
i=${j};
done
}
echo "Finished merging of autosomal CNVs"

# remove the resulting merging files
if test -f "${OUTDIR}/${Dataset}.autosomal.flr_mrg[0-9]"; then
	rm ${OUTDIR}/${Dataset}.auto.flr_mrg[0-9]
fi
if test -f "${OUTDIR}/${Dataset}.autosomal.flr_mrg[0-9][0-9]"; then
	rm ${OUTDIR}/${Dataset}.auto.flr_mrg[0-9][0-9]
fi

#################################################################
# Step 3. Remove spurious CNV calls in specific genomic regions #
#################################################################
# Several genomic regions are known to harbor spurious CNV calls that might represent cell-line artifacts. Therefore, we remove CNVs in certain genomic regions:

# a. Identify overlapping CNVs

# i. Identify CNVs with overlap to centromeric, telomeric, segmentalduplication and immunoglobulin regions
for i in centro telo segmentaldups immuno;
do
	singularity exec --no-home -B ${OUTDIR}:/outdir -B  ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/scan_region.pl outdir/${Dataset}.auto.flr_mrg_final outdir/${i}_${genomeversion}.txt -minqueryfrac ${MinQueryFrac} >${outDIR}/${Dataset}.auto.${i};
echo "${i} is done";
done

b. Remove CNVs with overlap to spurious regions

# i. Make list
for i in centro telo segmentaldups immuno;
do
	cat ${OUTDIR}/${Dataset}.auto.${i};
done >${OUTDIR}/${Dataset}_SpuriousCNVs_exclude

# ii. Remove CNVs in spurious  regions
grep -Fv -f ${OUTDIR}/${Dataset}_SpuriousCNVs_exclude ${OUTDIR}/${Dataset}.auto.flr_mrg_final >${OUTDIR}/${Dataset}.auto.flr_mrg_spur
echo "Finished removal of spurious regions for autosomal CNVs"

##########################################################
# Step 4. Obtain summary statistics for the QCed dataset #
##########################################################

# a. obtain summary statistics for dataset
singularity exec --no-home -B ${OUTDIR}:/outdir -B  ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/filter_cnv.pl outdir/${Dataset}.auto.flr_mrg_spur -qclrrsd ${LRR_SD} --qcbafdrift ${BAF_drift} --qcwf ${WF} -numsnp ${NoofSNPs} --qclogfile outdir/${Dataset}.auto.raw.log --qcpassout outdir/${Dataset}.auto.passout_QC --qcsumout outdir/${Dataset}.auto.sumout_QC --out outdir/${Dataset}.auto.flr_QC

#######################
# X-chromosomal CNVs ##
#######################

###########################################################
# Step 1: QC on CNVs, 1st round. Obtain summary statistics #
###########################################################

# a. obtain summary statistics for dataset
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir   ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/filter_cnv.pl outdir/${Dataset}.X.raw --qclrrsd ${LRR_SD_X} --qcbafdrift ${BAF_drift_X} --qcwf ${WF_X} --numsnp ${NoofSNPs_X} --qclogfile outdir/${Dataset}.X.raw.log --qcpassout outdir/${Dataset}.X.passout --qcsumout outdir/${Dataset}.X.sumout --out outdir/${Dataset}.X.flr --chrx

echo "Finished first filtering of X-chromosomal CNVs"

######################
# Step 2. Merge CNVs #
######################

# i. 1st time
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir  ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/clean_cnv.pl combineseg --fraction ${MergeFraction_X} --bp --signalfile /analysisdir/${PFBname} outdir/${Dataset}.X.flr --output outdir/${Dataset}.X.flr_mrg1

# ii. This command ensures that CNVs are getting merged until there are no more CNVs to merge within the defined distance
{
i=1
while [ ${i} -lt 50 ]; do
declare j=$(($i+1));
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5//clean_cnv.pl combineseg --fraction ${MergeFraction_X} --bp --signalfile /analysisdir/${PFBname} outdir/${Dataset}.X.flr_mrg${i} --output outdir/${Dataset}.X.flr_mrg${j}

declare length1=`awk 'END {print NR}' ${OUTDIR}/${Dataset}.X.flr_mrg${i}`
declare length2=`awk 'END {print NR}' ${OUTDIR}/${Dataset}.X.flr_mrg${j}`
if [ ${length1} -eq ${length2} ]
then
cp ${OUTDIR}/${Dataset}.X.flr_mrg${j} ${OUTDIR}/${Dataset}.X.flr_mrg_final
break;
fi
i=${j};
done
}
echo "Finished merging of X-chromosomal CNVs"

# remove the resulting merging files
if test -f "${OUTDIR}/${Dataset}.X.flr_mrg[0-9]"; then
	rm ${OUTDIR}/${Dataset}.X.flr_mrg[0-9]
fi
if test -f "${OUTDIR}/${Dataset}.X.flr_mrg[0-9][0-9]"; then
	rm ${OUTDIR}/${Dataset}.X.flr_mrg[0-9][0-9]
fi

###################################################################
# Step 3. Removing spurious CNV calls in specific genomic regions #
###################################################################

# Several genomic regions are known to harbor spurious CNV calls that might represent cell-line artifacts. Therefore, we remove CNVs in certain genomic regions:

#  a. Identify overlapping CNVs

# i. Identify CNVs with overlap to centromeric, telomeric and  segmentalduplication regions
for i in centro telo segmentaldups immuno;
do
singularity exec --no-home -B ${OUTDIR}:/outdir -B  ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/scan_region.pl outdir/${Dataset}.X.flr_mrg_final /analysisdir/${i}_${genomeversion}.txt -minqueryfrac ${MinQueryFrac} >${OUTDIR}/${Dataset}.X.${i};
echo "${i} is done";
done

# b. Remove CNVs with overlap to spurious regions

# i. Make list
for i in centro telo segmentaldups immuno;
do cat ${OUTDIR}/${Dataset}.X.${i};
done >${OUTDIR}/${Dataset}.X_SpuriousCNVs_exclude

# ii. Remove CNVs in spurious regions
grep -Fv -f ${OUTDIR}/${Dataset}.X_SpuriousCNVs_exclude ${OUTDIR}/${Dataset}.X.flr_mrg_final >${OUTDIR}/${Dataset}.X.flr_mrg_spur
echo "Finished removal of spurious regions for autosomal CNVs"

##########################################################
# Step 4. Obtain summary statistics for the QCed dataset #
##########################################################

# a. Removing CNVs from the X-chr based on autosomal individual QC
# Some individuals were removed in the autosomal QC -  the CNVs related to these should be removed from the X-chromosomal dataset before getting the final summary statistics.
awk 'FNR==NR {a[$1]; next} {if ($5 in a) {print}}' ${OUTDIR}/${Dataset}.auto.passout_QC ${OUTDIR}/${Dataset}.X.flr_mrg_spur >${OUTDIR}/${Dataset}.X.flr_mrg_spur_onlypass

# b. obtain summary statistics for dataset
singularity exec --no-home -B ${OUTDIR}:/outdir -B  ${ANALYSISDIR}:/analysisdir ${SOFTWAREDIR}/enigma-cnv.sif /opt/PennCNV-1.0.5/filter_cnv.pl outdir/${Dataset}.X.flr_mrg_spur_onlypass -qclrrsd ${LRR_SD_X} --qcbafdrift ${BAF_drift_X} --qcwf ${WF_X} -numsnp ${NoofSNPs_X} -qclogfile outdir/${Dataset}.X.raw.log -qcpassout outdir/${Dataset}.X.passout_QC -qcsumout outdir/${Dataset}.X.sumout_QC -out outdir/${Dataset}.X.flr_QC --chrx

##########################
## BOTH AUTOSOMAL AND X ##
##########################

########################################################
# Step 5. Removing QC'ed individuals from sumout-lists #
########################################################

# The sum-out list includes all individuals in the log-file. We wish to make a sum-out list only with individuals passing QC

# a. Removing individuals
for i in ${Dataset}.auto ${Dataset}.X;
do
	awk 'BEGIN {FS=OFS="\t"} FNR==NR {a[$1]; next} {if ($1=="File") {print}; if ($1 in a) {print}}' ${OUTDIR}/${Dataset}.auto.passout_QC  ${OUTDIR}/${i}.sumout_QC >${OUTDIR}/${i}.sumout_QC_onlypass
done;


###########################
### E. Deidentification ###
###########################

# For those cohorts that prefer that we do not receive the original ID, we introduce a deidentification step.

############################
# Step 1: Deidentification #
############################

# a. Make a deidentification key
declare Deidentify="${OUTDIR}/${Dataset}_deidentifykey.txt"
awk -v "name=$Dataset" 'BEGIN {OFS="\t"; i=0; print "ID_deidentified" OFS "File"} {i++; print name "_" i OFS $1}' ${OUTDIR}/${List_postQC}_adj >${Deidentify}

# b. Duplicates and relative-lists
awk -v postscript=${postscript} -v prescript=${prescript} 'BEGIN {OFS="\t"} {gsub(/.+\//,"\/",$2); gsub(/\//,"",$2); gsub(postscript,"",$2); gsub(prescript,"",$2); print}' ${Deidentify} | awk 'BEGIN {OFS="\t"} FNR==NR {a[$2]=$1; next} {if ($1 in a) {$1=a[$1]}; if ($2 in a) {$2=a[$2]}; print $0}' - ${RelativeFile}
 >${OUTDIR}/${Dataset}_DupsRelatives_key.txt

# c. Sexfile
awk -v postscript=${postscript} -v prescript=${prescript} 'BEGIN {OFS="\t"} {gsub(/.+\//,"\/",$2); gsub(/\//,"",$2); gsub(postscript,"",$2); gsub(prescript,"",$2); print}' ${Deidentify} | awk 'BEGIN {OFS="\t"} FNR==NR {a[$2]=$1; next} {if ($1 in a) {$1=a[$1]}; print $0}' - ${SexFile} >${OUTDIR}/${Dataset}_SexFile_key.txt

if [ $deidentify = "YES" ]
then
# Copy deidentified files to visualization-folder
	cp ${OUTDIR}/${Dataset}_SexFile_key.txt ${VISUALIZEDIR}/${Dataset}_SexFile.txt
	cp ${OUTDIR}/${Dataset}_DupsRelatives_key.txt ${VISUALIZEDIR}/${Dataset}_DupsRelatives.txt
else
	cp ${OUTDIR}/${Dataset}_SexFile.txt ${VISUALIZEDIR}/
	cp ${ANALYSISDIR}/DupsRelatives.txt ${VISUALIZEDIR}/${Dataset}_DupsRelatives.txt
fi
# Remaining deidentification will be done in the R-script

#############################################################
### F. Visualization of CNVs & prepare files for transfer ###
#############################################################

# Running visualization-script
singularity exec --no-home -B ${OUTDIR}:/outdir -B ${ANALYSISDIR}:/analysisdir  -B ${VISUALIZEDIR}:/visualize -B ${ANALYSISDIR}:/pfb -B ${LRRBAFDIR}:/lrrbafdir ${SOFTWAREDIR}/enigma-cnv.sif Rscript /analysisdir/ENIGMA-CNV_visualize_v1.R ${Dataset} ${PFBname} ${CNVofInterestFile} ${Overlapref} ${OverlapMin} ${OverlapMax} ${Chip} ${deidentify}


########################
### G. Data transfer ###
########################

########################################################################
## Step 1: Putting together checklist-file including on visualization ##
########################################################################

# stop the clock
END=$(date +%s)
declare TIME=`echo $((END-START)) | awk '{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}'`

# Calculate numbers for dataset
declare IDsVisualized=`awk 'NR==1 {for (i=1; i<=NF;i++) {f[$i] = i}} { print $(f["ID_deidentified"]) }' ${ANALYSISDIR}/${Dataset}_visualize/Moba_R875_20180120_CNVsofInterest.txt | sort | uniq -c | wc -l`

# a. Initiate file
rm -f ${ANALYSISDIR}/${Dataset}_visualize/${Dataset}_checklist.txt # remove file if already created
touch ${ANALYSISDIR}/${Dataset}_visualize/${Dataset}_checklist.txt
declare checklist="${ANALYSISDIR}/${Dataset}_visualize/${Dataset}_checklist.txt"

# b. Values into file

{
# Put in values for dataset etc...
echo -e "Date\t${date}
Name_of_Dataset\t${Dataset}
ResponsiblePI\t${ResponsiblePI}
Email,PI\t${Email_PI}
AnalystName\t${Analyst}
Email_Analyst\t${Email_Analyst}
TimeforAnalysis\t${TIME}
Deidentification\t${deidentify}"

#  Info for calling
awk 'END {print "Individuals_preQC\t" NR}' ${OUTDIR}/${List_preQC}
awk 'END {print "Individuals_postQC\t" NR}' ${OUTDIR}/${List_postQC}

# Generel info
echo -e "Chip_name\t$Chip
Version_if_applicable\t$Chipversion
HMM-file_used\t${HMMname}
PFB-file_used\t${PFBname}
Gcmodel-file_used\t${GCname}
No_of_individuals_with_gender_missing_in_sexfile\t$gendermissing"
echo ""

### Autosomal
awk 'END {print "Raw_dataset_Individuals_auto\t" NR-1}' ${OUTDIR}/${Dataset}.auto.sumout # individuals in the raw dataset
awk 'END {print "Filtered_dataset_Individuals_auto\t" NR}' ${OUTDIR}/${Dataset}.auto.passout # individuals in the filtered dataset
awk 'END {print "QCed_dataset_Individuals_auto\t" NR}' ${OUTDIR}/${Dataset}.auto.passout_QC # individuals in the QCed dataset
awk 'END {print "Raw_dataset_CNVs_auto\t" NR}' ${OUTDIR}/${Dataset}.auto.raw # CNVs in the raw dataset
awk 'END {print "Filtered_dataset_CNVs_auto\t" NR}' ${OUTDIR}/${Dataset}.auto.flr # CNVs in the filtered dataset
awk 'END {print "Filtered_and_merged_dataset_CNVs_auto\t" NR}' ${OUTDIR}/${Dataset}.auto.flr_mrg_final  # CNVs in the filtered AND merged dataset
awk 'END {print "Filtered_merged_and_removed_spurious_CNVs_dataset_CNVs_auto\t" NR}'  ${OUTDIR}/${Dataset}.auto.flr_mrg_spur  # CNVs in the filtered and merged and removal of spurious CNVs dataset
awk 'END {print "QCed_dataset_CNVs_auto\t" NR}' ${OUTDIR}/${Dataset}.auto.flr_QC  # CNVs in qc’ed dataset
echo ""

### X

awk 'END {print "Raw_dataset_Individuals_X\t" NR-1}' ${OUTDIR}/${Dataset}.X.sumout # Individuals in raw dataset
awk 'END {print "Filtered_dataset_Individuals_X\t" NR}' ${OUTDIR}/${Dataset}.X.passout # Individuals in the filtered dataset
awk 'END {print "Removing_individuals_based_on_autosomal_QC_Individuals_X\t" NR-1}' ${OUTDIR}/${Dataset}.X.sumout_QC_onlypass # Individuals in X after removing individuals removed in autosomal QC
awk 'END {print "Raw_dataset_CNVs_X\t" NR}' ${OUTDIR}/${Dataset}.X.raw # CNVs in the raw dataset
awk 'END {print "Filtered_dataset_CNVs_X\t" NR}' ${OUTDIR}/${Dataset}.X.flr  # CNVs in the filtered dataset
awk 'END {print "Filtered_and_merged_dataset_CNVs_X\t" NR}' ${OUTDIR}/${Dataset}.X.flr_mrg_final # CNVs in the filtered and merged dataset
awk 'END {print "Filtered_merged_and_removed_spurious_CNVs_dataset_CNVs_X\t" NR}' ${OUTDIR}/${Dataset}.X.flr_mrg_spur # CNVs in the filtered and merged and removal of spurious CNVs dataset
awk 'END {print "Removing_individuals_based_on_autosomal_QC_CNVs_X\t" NR}' ${OUTDIR}/${Dataset}.X.flr_mrg_spur_onlypass # CNVs in X after removing individuals removed in autosomal QC
awk 'END {print "QCed_dataset_CNVs_X\t" NR}' ${OUTDIR}/${Dataset}.X.flr_QC # CNVs in qc’ed dataset
echo "Please check that the above information/numbers make sense [e.g. the numbers of CNVs and/or individuals do not increase during QC]"
#### CHECKPOINTS

# Removal of nonpassed autosomal individuals
awk 'END {print "Individuals_sumoutlists_nonpassedindividualsremoved_X\t" NR-1}' ${OUTDIR}/${Dataset}.X.sumout_QC_onlypass
echo "The output should correspond to the number of individuals in the filtered autosomal dataset"

## Visualization-info

echo -e "CNVofInterestFile\t${CNVofInterestFile}
OverlapRef\t${Overlapref}
OverlapMin\t${OverlapMin}
OverlapMax\t${OverlapMax}
IDsVisualized\t${IDsVisualized}"

} >${checklist}

############################################
# Step 2: Tar the folder for file-transfer #
############################################

# All folders in the visualization folder will be transferred. 

# This includes:

## Files:
   # ${Dataset}_autoX.flr_QC [Filtered CNV-dataset]
   # ${Dataset}_QC.txt [summary statistics for your raw and filtered CNV-files]
   # ${Dataset}_checklist.txt [checklist for submission]
   # ${Dataset}_CNVcarriers_precuration_0.3.txt [all CNVsofInterests that were visualized]
   # ${Dataset}_OverlapRef_0.3_TotalCNVsofInterest_precuration.txt [count of all CNVsofInterests - for overview]
   # ${Dataset}_DupsRelatives.txt [List of dups and relatives]
   # ${Dataset}_SexFile.txt [List of individuals including sex-information]
## The folders with visualization-plots:
   # singleplots_50kb
   # singleplots_cnvofinterest
   # stackplots

# Zip the visualization-folder for transfer
rm ${ANALYSISDIR}/${Dataset}_visualize.tar.gz # remove previously zipped folder
tar -zcvf ${ANALYSISDIR}/${Dataset}_visualize.tar.gz ${VISUALIZEDIR}





