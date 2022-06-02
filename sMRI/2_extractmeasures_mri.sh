#!/bin/bash
#####
# Wrapper written by Rune Bøen (boenrune@gmail.com) for the ENIGMA-CNV working group 09/10/21  
#	
# Script assumes the following structure
#			Project_parent_directory/
#						-> outputs/
#							-> subj01(Freesurfer outputs from any version)
#							-> subj02
#							...
#
######


###############
# Setup directory where volumes are
enigmadir=$1

if [ -z ${enigmadir} ] || [ $# -gt 1 ] ; then

	echo "One input directory must be specified"
	echo "Usage is: 2_extractmeasures_mri.sh <parent directory of project>"
	exit
fi

if [ ! -e ${enigmadir} ]; then
	echo "Input directory does not exist"
	exit
fi

###############

cd ${enigmadir}/outputs
export SUBJECTS_DIR=${enigmadir}/outputs


for side in lh rh ; do

for measure in area thickness thicknessstd volume meancurv gauscurv foldind curvind; do 

aparcstats2table --subjects $(ls -d subj*) --hemi ${side} --meas ${measure} --tablefile "${side}_${measure}_CorticalMeasuresENIGMA.csv" 

done
done


asegstats2table --subjects $(ls -d subj*) --meas volume --tablefile subcortical_CorticalMeasuresENIGMA.csv --sd ${enigmadir}/outputs


# Create list with Euler number 


for SUB in $(ls -d subj*); do
mris_euler_number ${enigmadir}/outputs/${SUB}/surf/lh.orig.nofix >& ${enigmadir}/outputs/${SUB}/surf/lh.euler
mris_euler_number ${enigmadir}/outputs/${SUB}/surf/rh.orig.nofix >& ${enigmadir}/outputs/${SUB}/surf/rh.euler
done

echo 'SubjID,lh_euler,rh_euler' > EulerNumbers.csv


for SUB in $(ls -d subj*); do

printf "%s,"  "${SUB}" >> EulerNumbers.csv
printf "%g," `cat ${enigmadir}/outputs/${SUB}/surf/lh.euler | grep euler | sed -n -e 's/^.*=//p' | awk '{printf $1}'` >> EulerNumbers.csv
printf "%g" `cat ${enigmadir}/outputs/${SUB}/surf/rh.euler | grep euler | sed -n -e 's/^.*=//p' | awk '{printf $1}'` >> EulerNumbers.csv
echo "" >> EulerNumbers.csv
done

