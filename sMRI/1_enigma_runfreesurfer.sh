#!/bin/bash
#####
# 10/23/15
# Wrapper written by Eric Kan (ekan@chla.usc.edu)
#						
# Script assumes the following structure
#			Project_parent_directory/
#						-> inputs/
#							-> subj01 (contains nii input named subj01.nii(.gz))
#							-> subj02
#							...
#						-> outputs/
#							-> subj01(freesurfer outputs)
#							-> subj02
#							...
#						-> enigma_wrapscripts/ (copied from elsewhere)
#
#
######

subject=$1
enigmadir=$2


if [ -z ${subject} ]; then
	echo "Subject number must be specified"
	echo "Usage is: ./1_enigma_runfreesurfer.sh <subject number> <parent directory of project>"
	exit
fi

if [ -z ${enigmadir} ]; then
	echo "Parent directory of 'inputs' folder must be specified"
	echo "Usage is: ./1_enigma_runfreesurfer.sh <subject number> <parent directory of project>"
	exit
fi

if [ $# -gt 2 ] ; then
	echo "Too many arguments specified"
	echo "Usage is: ./1_enigma_runfreesurfer.sh <subject number> <parent directory of project>"
	exit
fi

if [ ! -e ${enigmadir} ] || [ ! -e ${enigmadir}/inputs/${subject}/${subject}.nii.gz ]; then
	echo "Input directory or subject does not exist! Please check"
	exit
fi

################
# recon-all loop

${enigmadir}/enigma_wrapscripts/bash/recon-all.sh -i ${enigmadir}/inputs/${subject}/${subject}.nii.gz -subjid ${subject} -sd ${enigmadir}/outputs -all
	






