#!/bin/bash
#####
# 09/20/21
# Written by Rune Bøen for the ENIGMA-CNV 
#	
# Purpose: Segmentation of the brain stem, hippocampal subfields, and hypothalamic subunits 
#
#			
#
# Script assumes the following structure
#			Project_parent_directory/
#						-> outputs/
#							-> subj01 (where the output the recon-all function exists and where the results from the extended analyses will go)
#							-> subj02 
#							...
#
#						-> enigma_wrapscripts/ (from ENIGMA protocols; should be copied from the github, and from the ENIGMA-CNV working group)
##
# Troubleshooting questions can be directed to the ENIGMA-CNV working group 
#
######

enigmadir=$1 # first argument given following the bash script (ie., the parent directory)
AdditionalAnalysis1=$2
AdditionalAnalysis2=$3
AdditionalAnalysis3=$4
AdditionalAnalysis4=$5

if [ -z ${enigmadir} ]; then
	echo "Parent directory of 'outputs' folder must be specified"
	echo "Usage is: ./s0_optional_segmentation.sh <parent directory of project>"
	exit
fi

if [ $# -gt 5 ] ; then
	echo "Too many arguments specified"
	echo "Usage is: ./s0_optional_segmentation.sh <parent directory of project> followed by the region you want to segment, i.e., --BrainStem, AND/OR --Hippocampus AND/OR Hypothalamus"
	exit
fi

if [ ! -e ${enigmadir}/outputs ] ; then
	echo "Output directory from the recon-all function does not exist! Please check"
	exit
fi

################

# run either/or three different types of segmentations (ie., brain stem, hippocampus and hypothalamus. Only valid arguments, else the script will terminate

cd ${enigmadir}/outputs

for x in ${AdditionalAnalysis1} ${AdditionalAnalysis2} ${AdditionalAnalysis3} ${AdditionalAnalysis4}; do
if [ ! ${x} == "--BrainStem" ] && [ ! ${x} == "--HippocampusAmygdala" ] && [ ! ${x} == "--Hypothalamus" ] && [ ! ${x} == "--ThalamicNuclei" ]; then
echo "${x} is not a valid argument, please try '--BrainStem' for brain stem segmentation, '--HippocampusAmygdala' for hippocampal/amygdala segmentation, --ThalamicNuclei for Thalamic nuclei segmentation, and/or '--Hypothalamus' for segmentation of the thalamic nuclei'"
exit
fi
done

if [ "$2" == "--BrainStem" ] || [ "$3" == "--BrainStem" ] || [ "$4" == "--BrainStem" ] || [ "$5" == "--BrainStem" ]; then
echo "Segmenting the brainstem"
for SUB in `ls -d subj*`
do
${enigmadir}/enigma_wrapscripts/bash/recon-all_extended2.sh ${SUB} ${enigmadir}/outputs
done
# Create text file summarizing the brain stem data across participants
quantifyBrainstemStructures.sh BrainStem_Measures_ENIGMA ${enigmadir}/outputs
else
echo "Brainstem will NOT be segmented, if you wish to segment the brainstem, please type '--BrainStem' as one of the arguments" 
fi

if [ "$2" == "--HippocampusAmygdala" ] || [ "$3" == "--HippocampusAmygdala" ] || [ "$4" == "--HippocampusAmygdala" ]|| [ "$5" == "--HippocampusAmygdala" ]; then
echo "Segmenting the hippocampus and the amygdala" 
for SUB in `ls -d subj*`
do
${enigmadir}/enigma_wrapscripts/bash/recon-all_extended3.sh ${SUB} ${enigmadir}/outputs
done
else
echo "Hippocampus/Amygdala will NOT be segmented, if you wish to segment the hippocampus and amygdala, please type '--HippocampusAmygdala' as one of the arguments"
fi

if [ "$2" == "--ThalamicNuclei" ] || [ "$3" == "--ThalamicNuclei" ] || [ "$4" == "--ThalamicNuclei" ] || [ "$5" == "--ThalamicNuclei" ]; then
echo "Segmenting the thalamic nuclei"
for SUB in `ls -d subj*`
do
${enigmadir}/enigma_wrapscripts/bash/recon-all_extended5.sh ${SUB} ${enigmadir}/outputs
done
else
echo "Thalamic Nuclei will NOT be segmented, if you wish to segment the thalamic nuclei, please type '--ThalamicNuclei' as one of the arguments"
fi

if [ "$2" == "--Hypothalamus" ] || [ "$3" == "--Hypothalamus" ] || [ "$4" == "--Hypothalamus" ] || [ "$5" == "--Hypothalamus" ]; then
echo "Segmenting the hypothalamic nuclei" 
${enigmadir}/enigma_wrapscripts/bash/recon-all_extended4.sh --s --sd ${enigmadir}/outputs
else
echo "Hypothalamic nuclei will NOT be segmented, if you wish to segment the hypothalamic nuclei, please type '--Hypothalamus' as one of the arguments" 
fi






