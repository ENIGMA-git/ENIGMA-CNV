#!/bin/bash
#####
# 09/20/21
# Written by Rune Bøen for the ENIGMA-CNV 
#	
# Purpose: Create table for local gyrification index, assumes that the localgyrificationindex_1.sh has been successfully completed. 
#
#			
#
# Script assumes the following structure
#			Project_parent_directory/
#						-> outputs/
#							-> subj01 (where the output the s1_optional_LGI shell script exists and where the results from the extended analyses will go)
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
	echo "Parent directory of 'inputs' folder must be specified"
	echo "Usage is: ./s1a_optional_LGItable.sh <parent directory of project>"
	exit
fi

if [ $# -gt 2 ] ; then
	echo "Too many arguments specified"
	echo "Usage is: ./s1a_optional_LGItable.sh <parent directory of project> followed by --CreateTable"
	exit
fi

if [ ! -e ${enigmadir}/outputs ] ; then
	echo "Output directory from the recon-all function does not exist! Please check"
	exit
fi

################

cd ${enigmadir}/outputs

if [ "$2" == "--CreateTable" ]; then
echo "Creating a table for the local gyrification index"

for SUB in `ls -d subj*`; do

for side in lh rh; do

mri_segstats --annot ${SUB} ${side} aparc --i ${enigmadir}/outputs/${SUB}/surf/${side}.pial_lgi --sum ${enigmadir}/outputs/${SUB}/stats/${side}.aparc.pial_lgi.stats --sd ${enigmadir}/outputs
done
done

else

echo "Please type '--CreateTable' as the second argument if you want to create a table with local gyrification index values for each participants across ROIs"
exit
fi

echo 'SubjID,lh_bankssts_LGIarea,lh_caudalanteriorcingulate_LGIarea, lh_caudalmiddlefrontal_LGIarea,lh_cuneus_LGIarea,lh_entorhinal_LGIarea, lh_fusiform_LGIarea,lh_inferiorparietal_LGIarea,lh_inferiortemporal_LGIarea, lh_isthmuscingulate_LGIarea,lh_lateraloccipital_LGIarea, lh_lateralorbitofrontal_LGIarea,lh_lingual_LGIarea, lh_medialorbitofrontal_LGIarea,lh_middletemporal_LGIarea, lh_parahippocampal_LGIarea,lh_paracentral_LGIarea,lh_parsopercularis_LGIarea, lh_parsorbitalis_LGIarea,lh_parstriangularis_LGIarea,lh_pericalcarine_LGIarea, lh_postcentral_LGIarea,lh_posteriorcingulate_LGIarea,lh_precentral_LGIarea, lh_precuneus_LGIarea,lh_rostralanteriorcingulate_LGIarea, lh_rostralmiddlefrontal_LGIarea,lh_superiorfrontal_LGIarea,lh_superiorparietal_LGIarea,lh_superiortemporal_LGIarea, lh_supramarginal_LGIarea,lh_frontalpole_LGIarea,lh_temporalpole_LGIarea, lh_transversetemporal_LGIarea,lh_insula_LGIarea,rh_bankssts_LGIarea, rh_caudalanteriorcingulate_LGIarea,rh_caudalmiddlefrontal_LGIarea, rh_cuneus_LGIarea,rh_entorhinal_LGIarea,rh_fusiform_LGIarea, rh_inferiorparietal_LGIarea,rh_inferiortemporal_LGIarea, rh_isthmuscingulate_LGIarea,rh_lateraloccipital_LGIarea, rh_lateralorbitofrontal_LGIarea,rh_lingual_LGIarea, rh_medialorbitofrontal_LGIarea,rh_middletemporal_LGIarea, rh_parahippocampal_LGIarea,rh_paracentral_LGIarea,rh_parsopercularis_LGIarea, rh_parsorbitalis_LGIarea,rh_parstriangularis_LGIarea,rh_pericalcarine_LGIarea,rh_postcentral_LGIarea,rh_posteriorcingulate_LGIarea,rh_precentral_LGIarea, rh_precuneus_LGIarea,rh_rostralanteriorcingulate_LGIarea, rh_rostralmiddlefrontal_LGIarea,rh_superiorfrontal_LGIarea, rh_superiorparietal_LGIarea,rh_superiortemporal_LGIarea, rh_supramarginal_LGIarea,rh_frontalpole_LGIarea,rh_temporalpole_LGIarea, rh_transversetemporal_LGIarea,rh_insula_LGIarea' > LGI_CorticalMeasuresENIGMA.csv

for SUB in $(ls -d subj*); do

printf "%s,"  "${SUB}" >> LGI_CorticalMeasuresENIGMA.csv

for side in lh rh ; do

for x in bankssts caudalanteriorcingulate caudalmiddlefrontal cuneus entorhinal fusiform inferiorparietal inferiortemporal isthmuscingulate lateraloccipital lateralorbitofrontal lingual medialorbitofrontal middletemporal parahippocampal paracentral parsopercularis parsorbitalis parstriangularis pericalcarine postcentral posteriorcingulate precentral precuneus rostralanteriorcingulate rostralmiddlefrontal superiorfrontal superiorparietal superiortemporal supramarginal frontalpole temporalpole transversetemporal insula; do

if [ $x == "insula" ]  && [ $side == "rh" ]; then
printf "%g" `grep -w ${x} ${SUB}/stats/${side}.aparc.pial_lgi.stats | awk '{print $6}'` >> LGI_CorticalMeasuresENIGMA.csv
else

printf "%g," `grep -w ${x} ${SUB}/stats/${side}.aparc.pial_lgi.stats | awk '{print $6}'` >> LGI_CorticalMeasuresENIGMA.csv
fi

done
done

echo "" >> LGI_CorticalMeasuresENIGMA.csv

done
