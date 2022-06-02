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
echo "Creating segmentation table"

else

echo "Please type '--CreateTable' as the second argument if you want to create a table for the segmentation outputs"
exit
fi

echo 'SubjID,lh_thalamicnuclei_AV,lh_thalamicnuclei_CL,lh_thalamicnuclei_CM, lh_thalamicnuclei_CeM,lh_thalamicnuclei_L-Sg, lh_thalamicnuclei_LD,lh_thalamicnuclei_LGN,lh_thalamicnuclei_LP,lh_thalamicnuclei_MDl,lh_thalamicnuclei_MDm,lh_thalamicnuclei_MGN,lh_thalamicnuclei_MV(Re),lh_thalamicnuclei_Pc,lh_thalamicnuclei_Pf,lh_thalamicnuclei_Pt,lh_thalamicnuclei_PuA,lh_thalamicnuclei_PuI,lh_thalamicnuclei_PuL,lh_thalamicnuclei_PuM,lh_thalamicnuclei_VA,lh_thalamicnuclei_VAmc,lh_thalamicnuclei_VLa, lh_thalamicnuclei_VLp,lh_thalamicnuclei_VM,lh_thalamicnuclei_VPL,lh_thalamicnuclei_WholeThalamus,rh_thalamicnuclei_AV,rh_thalamicnuclei_CL,rh_thalamicnuclei_CM, rh_thalamicnuclei_CeM,rh_thalamicnuclei_L-Sg, rh_thalamicnuclei_LD,rh_thalamicnuclei_LGN,rh_thalamicnuclei_LP,rh_thalamicnuclei_MDl,rh_thalamicnuclei_MDm,rh_thalamicnuclei_MGN,rh_thalamicnuclei_MV(Re),rh_thalamicnuclei_Pc,rh_thalamicnuclei_Pf,rh_thalamicnuclei_Pt,rh_thalamicnuclei_PuA,rh_thalamicnuclei_PuI,rh_thalamicnuclei_PuL,rh_thalamicnuclei_PuM,rh_thalamicnuclei_VA,rh_thalamicnuclei_VAmc,rh_thalamicnuclei_VLa, rh_thalamicnuclei_VLp,rh_thalamicnuclei_VM,rh_thalamicnuclei_VPL,rh_thalamicnuclei_WholeThalamus' > ThalamicNuclei_CorticalMeasuresENIGMA.csv

for SUB in $(ls -d subj*); do

printf "%s,"  "${SUB}" >> ThalamicNuclei_CorticalMeasuresENIGMA.csv

for side in lh rh ; do

for x in AV CL CM CeM L-Sg LD LGN LP MDl MDm MGN "MV(Re)" Pc Pf Pt PuA PuI PuL PuM VA VAmc VLa VLp VM VPL Whole_thalamus; do

if [ $x == "Whole_thalamus" ]  && [ $side == "rh" ]; then
printf "%g" `grep -w ${x} ${SUB}/stats/thalamic-nuclei.${side}.v12.T1.stats | awk '{print $4}'` >> ThalamicNuclei_CorticalMeasuresENIGMA.csv
else

printf "%g," `grep -w ${x} ${SUB}/stats/thalamic-nuclei.${side}.v12.T1.stats | awk '{print $4}'` >> ThalamicNuclei_CorticalMeasuresENIGMA.csv
fi

done
done

echo "" >> ThalamicNuclei_CorticalMeasuresENIGMA.csv

done

### for hippocampal subfields

echo 'SubjID,lh_hippocampalsub_hippocampal_tail,lh_hippocampalsub_subiculum-body,lh_hippocampalsub_CA1-body,lh_hippocampalsub_subiculum-head, lh_hippocampalsub_hippocampal-fissure,lh_hippocampalsub_presubiculum-head, lh_hippocampalsub_CA1-head, lh_hippocampalsub_presubiculum-body,lh_hippocampalsub_parasubiculum,lh_hippocampalsub_molecular_layer_HP-head, lh_hippocampalsub_molecular_layer_HP-body,lh_hippocampalsub_GC-ML-DG-head,lh_hippocampalsub_CA3-body,lh_hippocampalsub_GC-ML-DG-body,lh_hippocampalsub_CA4-head,lh_hippocampalsub_CA4-body,lh_hippocampalsub_fimbria, lh_hippocampalsub_CA3-head,lh_hippocampalsub_HATA,lh_hippocampalsub_whole_hippocampal_body,lh_hippocampalsub_whole_hippocampal_head, lh_hippocampalsub_whole_hippocampus,rh_hippocampalsub_hippocampal_tail,rh_hippocampalsub_subiculum-body,rh_hippocampalsub_CA1-body,rh_hippocampalsub_subiculum-head,rh_hippocampalsub_hippocampal-fissure,rh_hippocampalsub_presubiculum-head, rh_hippocampalsub_CA1-head,rh_hippocampalsub_presubiculum-body,rh_hippocampalsub_parasubiculum,rh_hippocampalsub_molecular_layer_HP-head, rh_hippocampalsub_molecular_layer_HP-body,rh_hippocampalsub_GC-ML-DG-head,rh_hippocampalsub_CA3-body,rh_hippocampalsub_GC-ML-DG-body,rh_hippocampalsub_CA4-head,rh_hippocampalsub_CA4-body,rh_hippocampalsub_fimbria,rh_hippocampalsub_CA3-head,rh_hippocampalsub_HATA,rh_hippocampalsub_whole_hippocampal_body,rh_hippocampalsub_whole_hippocampal_head, rh_hippocampalsub_whole_hippocampus' > HippocampalSubfields_CorticalMeasuresENIGMA.csv

for SUB in $(ls -d subj*); do

printf "%s,"  "${SUB}" >> HippocampalSubfields_CorticalMeasuresENIGMA.csv

for side in lh rh ; do

for x in Hippocampal_tail subiculum-body CA1-body subiculum-head hippocampal-fissure presubiculum-head CA1-head presubiculum-body parasubiculum molecular_layer_HP-head molecular_layer_HP-body GC-ML-DG-head CA3-body GC-ML-DG-body CA4-head CA4-body fimbria CA3-head HATA Whole_hippocampal_body Whole_hippocampal_head Whole_hippocampus; do

if [ $x == "Whole_hippocampus" ]  && [ $side == "rh" ]; then
printf "%g" `grep -w ${x} ${SUB}/stats/hipposubfields.${side}.T1.v21.stats | awk '{print $4}'` >> HippocampalSubfields_CorticalMeasuresENIGMA.csv
else

printf "%g," `grep -w ${x} ${SUB}/stats/hipposubfields.${side}.T1.v21.stats  | awk '{print $4}'` >> HippocampalSubfields_CorticalMeasuresENIGMA.csv
fi

done
done

echo "" >> HippocampalSubfields_CorticalMeasuresENIGMA.csv

done

### for amygdalar nuclei

echo 'SubjID,lh_amygdalarnuclei_lateralnucleus,lh_amygdalarnuclei_basalnucleus,lh_amygdalarnuclei_accessory_basalnucleus,lh_amygdalarnuclei_anterior_amygdaloid_area_AAA,lh_amygdalarnuclei_centralnucleus,lh_amygdalarnuclei_medialnucleus,lh_amygdalarnuclei_corticalnucleus,lh_amygdalarnuclei_corticoamygdaloid_transitio, lh_amygdalarnuclei_paralaminarnucleus,lh_amygdalarnuclei_whole_amygdala,rh_amygdalarnuclei_lateralnucleus,rh_amygdalarnuclei_basalnucleus,rh_amygdalarnuclei_accesory_basalnucleus,rh_amygdalarnuclei_anterior_amygdaloid_area_AAA,rh_amygdalarnuclei_centralnucleus, rh_amygdalarnuclei_medialnucleus,rh_amygdalarnuclei_corticalnucleus,rh_amygdalarnuclei_corticoamygdaloid_transitio,rh_amygdalarnuclei_paralaminarnucleus,rh_amygdalarnuclei_whole_amygdala' > AmygdalarNuclei_CorticalMeasuresENIGMA.csv

for SUB in $(ls -d subj*); do

printf "%s,"  "${SUB}" >> AmygdalarNuclei_CorticalMeasuresENIGMA.csv

for side in lh rh ; do

for x in Lateral-nucleus Basal-nucleus Accessory-Basal-nucleus Anterior-amygdaloid-area-AAA Central-nucleus Medial-nucleus Cortical-nucleus Corticoamygdaloid-transitio Paralaminar-nucleus Whole_amygdala; do

if [ $x == "Whole_amygdala" ]  && [ $side == "rh" ]; then
printf "%g" `grep -w ${x} ${SUB}/stats/amygdalar-nuclei.${side}.T1.v21.stats | awk '{print $4}'` >> AmygdalarNuclei_CorticalMeasuresENIGMA.csv
else

printf "%g," `grep -w ${x} ${SUB}/stats/amygdalar-nuclei.${side}.T1.v21.stats | awk '{print $4}'` | sed -e 's/,.*/,/' >> AmygdalarNuclei_CorticalMeasuresENIGMA.csv
fi

done
done

echo "" >> AmygdalarNuclei_CorticalMeasuresENIGMA.csv

done

### for hypothalamic subunits

echo 'SubjID, lh_hypothalamicsubunit_anteriorinferior,lh_hypothalamicsubunit_anteriorsuperior, lh_hypothalamicsubunit_posterior,lh_hypothalamicsubunit_tubular_inferior,lh_hypothalamicsubunit_tubular_superior,rh_hypothalamicsubunit_anteriorinferior,rh_hypothalamicsubunit_anteriorsuperior, rh_hypothalamicsubunit_posterior,rh_hypothalamicsubunit_tubular_inferior,rh_hypothalamicsubunit_tubular_superior,lh_hypothalamicsubunit_whole_hypothalamus,rh_hypothalamicsubunit_whole_hypothalamus' > HypothalamicSubunits_CorticalMeasuresENIGMA.csv

for SUB in $(ls -d subj*); do

printf "%s,"  "${SUB}" >> HypothalamicSubunits_CorticalMeasuresENIGMA.csv

for x in Left-Anterior-Inferior Left-Anterior-Superior Left-Posterior Left-Tubular-Inferior Left-Tubular-Superior Right-Anterior-Inferior Right-Anterior-Ssuperior Right-Posterior Right-Tubular-Inferior Right-Tubular-Superior Whole-Left Whole-Right; do

if [ $x == "Whole-Right" ]; then
printf "%g" `grep -w ${x} ${SUB}/stats/hypothalamic_subunits_volumes.v1.stats | awk '{print $4}'` >> HypothalamicSubunits_CorticalMeasuresENIGMA.csv
else

printf "%g," `grep -w ${x} ${SUB}/stats/hypothalamic_subunits_volumes.v1.stats  | awk '{print $4}'` >> HypothalamicSubunits_CorticalMeasuresENIGMA.csv
fi

done

echo "" >> HypothalamicSubunits_CorticalMeasuresENIGMA.csv

done

cd ${enigmadir}/outputs
asegstats2table --subjects $(ls -d subj*) --statsfile=brainstem.v12.stats --tablefile BrainStemSeg_CorticalMeasuresENIGMA.csv --sd ${enigmadir}/outputs
