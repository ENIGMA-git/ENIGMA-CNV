#!/bin/bash
#####
# 11/18/15
# Written by Sook-Lei Liew (sliew@usc.edu)
#	
# Purpose: Runs freesurfer recon-all on all subjects in inputs directory
#
# Usage: ./1a_enigma_runfreesurfer_loop.sh <parent directory of project>
# Ex: ./1_enigma_runfreesurfer.sh /Users/sliew/data/enigma_project_parent_directory	
#				
# NOTE: all subjects in input dir should start with "sub" (e.g., sub01, sub02..)
#
# Script assumes the following structure
#			Project_parent_directory/
#						-> inputs/
#							-> subj01/ (contains nii input named subj01.nii.gz))
#							-> subj02/ (contains nii input named subj02.nii.gz))
#							...
#						-> outputs/
#							-> subj01 (where freesurfer outputs will go)
#							-> subj02 (where freesurfer outputs will go)
#							-> cortical/subcortical output folders will also be directed here
#							...
#
#						-> enigma_wrapscripts/ (from ENIGMA protocols; should be copied from the github)
##
# Troubleshooting questions can be directed to npnl@usc.edu and sliew@usc.edu
#
######

enigmadir=$1

if [ -z ${enigmadir} ]; then
	echo "Parent directory of 'inputs' folder must be specified"
	echo "Usage is: ./1a_enigma_runfreesurfer_loop.sh <parent directory of project>"
	exit
fi

if [ $# -gt 1 ] ; then
	echo "Too many arguments specified"
	echo "Usage is: ./1a_enigma_runfreesurfer_loop.sh <parent directory of project>"
	exit
fi

if [ ! -e ${enigmadir} ] ; then
	echo "Input directory does not exist! Please check"
	exit
fi

################

cd ${enigmadir}
pwd

cd ${enigmadir}/inputs
ls sub*

for SUB in sub*
do
	echo Now running freesurfer on $SUB
	${enigmadir}/1_enigma_runfreesurfer.sh $SUB ${enigmadir}
done


