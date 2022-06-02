#!/bin/bash
#####
# 12/05/15
# Written by Sook-Lei Liew (sliew@usc.edu)
#	
# Purpose: Reorganizes anatomical data into inputs folder of structure below
#
# Usage: ./0_organize_data.sh <subject data header> <directory of current data> <directory for enigma project>
# Ex: ./0_organize_data.sh SE /Users/sliew/data/mycurrdata /Users/sliew/data/enigma_parent_dir
#				
# NOTE1: assumes you have already downloaded the enigma folder structure and wrap scripts into enigma_parent_dir
# but you must delete anything in the "inputs" folder so it is empty 
#
# NOTE2: uses a numerical ordering (e.g., subj01, subj05, subj2198)
#
# NOTE3: assumes your anatomicals are all directly within /mycurrdata - if not, minor edits will be needed
# If edits needed, contact troubleshooting below
#
# Script assumes the following structure within your enigma project parent directory
#			Project_parent_directory/
#						-> inputs/
#							*this directory should be empty to run this script	
#							*this script will populate this section for you
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

subjecthead=$1
currdir=$2
enigmadir=$3

echo "Subject header: " $subjecthead
echo "Current data directory: " $currdir
echo "Desired project directory: " $enigmadir

if [ -z ${subjecthead} ]; then
	echo "Subject header must be specified"
	echo "Usage is: ./0_organize_data.sh <subject header> <current directory of data> <parent directory of project>"
	echo "Usage is: ./0_organize_data.sh SUBJ /Users/current/data/is/here /Users/data/to/go/here"
	exit
fi

if [ -z ${currdir} ]; then
	echo "Current directory where data is stored must be specified"
	echo "Usage is: ./0_organize_data.sh <subject header> <current directory of data> <parent directory of project>"
	echo "Usage is: ./0_organize_data.sh SUBJ /Users/current/data/is/here /Users/data/to/go/here"
	exit
fi

if [ -z ${enigmadir} ]; then
	echo "Desired parent directory of ENIGMA project folder must be specified"
	echo "Usage is: ./0_organize_data.sh <subject header> <current directory of data> <parent directory of project>"
	echo "Usage is: ./0_organize_data.sh SUBJ /Users/current/data/is/here /Users/data/to/go/here"
	exit
fi

if [ $# -gt 3 ] ; then
	echo "Too many arguments specified"
	echo "Usage is: ./0_organize_data.sh <subject header> <current directory of data> <parent directory of project>"
	echo "Usage is: ./0_organize_data.sh SUBJ /Users/current/data/is/here /Users/data/to/go/here"
	exit
fi

if [ ! -e ${currdir} ] || [ ! -e ${currdir}/${subject}*.nii.gz ]; then
	echo "Data directory or subject header within data directory does not exist! Please check"
	exit
fi

if [ ! -e ${enigmadir} ]; then
	echo "Enigma directory does not exist! Please check"
	exit
fi

#############
# copy data into new data structure
cd $currdir
pwd
var=1


for SUBJ in ${subjecthead}*.nii.gz
do
	echo Now copying $SUBJ
	mkdir $enigmadir/inputs/subj${var}
	cp $SUBJ $enigmadir/inputs/subj${var}/subj${var}.nii.gz
	var=$((var+1))
done
