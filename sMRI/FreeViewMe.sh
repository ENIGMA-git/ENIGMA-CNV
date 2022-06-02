###############
DIR=$1 # Directory for outputfiles 
SUBJECT=$2 # name of subject 

cd ${DIR}
freeview -v \
    $SUBJECT/mri/orig.mgz \
    $SUBJECT/mri/aparc+aseg.mgz:opacity=0.6 \
    -f \
    $SUBJECT/surf/lh.white:edgecolor=yellow \
    $SUBJECT/surf/lh.pial:edgecolor=red \
    $SUBJECT/surf/rh.white:edgecolor=yellow \
    $SUBJECT/surf/rh.pial:edgecolor=red \
    $SUBJECT/surf/lh.pial:annot=aparc.annot:name=pial_aparc:visible=1 \
    $SUBJECT/surf/rh.pial:annot=aparc.annot:name=pial_aparc:visible=1 


