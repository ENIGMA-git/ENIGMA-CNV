#!/bin/bash
#####
# 09/20/21
# Written by Rune Bøen for the ENIGMA-CNV 
#	
# Purpose: Provides estimates of local gyrification 
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


if [ -z ${enigmadir} ]; then
	echo "Parent directory of 'outputs' folder must be specified"
	echo "Usage is: ./s1_optinal_LGI.sh <parent directory of project>"
	exit
fi

if [ $# -gt 2 ] ; then
	echo "Too many arguments specified"
	echo "Usage is: ./s1_optinal_LGI.sh <parent directory of project> followed by --LocalGyrificationIndex"
	exit
fi

if [ ! -e ${enigmadir}/outputs ] ; then
	echo "Output directory from the recon-all function does not exist! Please check"
	exit
fi

################

cd ${enigmadir}/outputs

if [ "$2" == "--LocalGyrificationIndex" ]; then
echo "Estimating the local gyrification index"
for SUB in `ls -d subj*`
do
${enigmadir}/enigma_wrapscripts/bash/recon-all.sh -s ${SUB} -sd ${enigmadir}/outputs -localGI
done
else
echo "Did not find the local gyrification index argument will, if you wish to run the local gyrification index processing, please type '--LocalGyrificationIndex' as the second argument" 
fi




