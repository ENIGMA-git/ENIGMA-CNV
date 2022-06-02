#!/bin/bash
#####
# Written by Rune Bøen (boenrune@gmail.com) for the ENIGMA-CNV working group 24/05/22
#
# Script assumes the following structure
#            Project_parent_directory/
#                        -> outputs/
#                            -> subj01(Freesurfer outputs from any version)
#                            -> subj02
#                            ...
#
######

# This will also run the 2_extractsubcortical_volumes.sh and 3_extractcortical_volumes.sh from the https://enigma.ini.usc.edu/protocols/imaging-protocols/ page, this will also include the QC outputs. 

############### set directories ########
# first argumeent: where the license.txt file from freesurfer is located. This could be retrieved from https://surfer.nmr.mgh.harvard.edu/fswiki/License. This is needed to run freesurfer and the dockerized Freesurfer version does not include a license by default. the text file will be binded to the docker container.
# second argument: the parent folder where the wrapper scripts are located. This is binded to the docker container.

dirlicense=$1
dataforbind=$2

if [ -z ${dirlicense} ] || [ $# -gt 2 ] ; then

    echo "Two directories must be specified"
    echo "Usage is: RunFreeSurferDocker.sh <directory of the freesurfer license.txt file> <parent directory of project>"
    exit
fi

if [ ! -e ${dataforbind} ]; then
    echo "Parent directory does not exist"
    exit
fi


docker run -it -d --name enigma-cnv-freesurfer \
-v ${dirlicense}/license.txt:/usr/local/freesurfer/license.txt \
-v ${dataforbind}:/usr/local/freesurfer/myfiles \
-e FS_LICENSE=/usr/local/freesurfer/license.txt \
freesurfer/freesurfer:7.2.0

docker exec -it -w /usr/local/freesurfer/myfiles enigma-cnv-freesurfer sh 1a_enigma_runfreesurfer_loop.sh /usr/local/freesurfer/myfiles

docker exec -it -w /usr/local/freesurfer/myfiles enigma-cnv-freesurfer sh 2_extractmeasures_mri.sh /usr/local/freesurfer/myfiles

