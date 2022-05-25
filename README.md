# Description, ENIGMA-CNV
This repository contains protocols for the ENIGMA-CNV working group.

# CNV calling
This folder includes easy-to-use scripts and software for calling and filtering CNVs with PennCNV (Wang et al 2007, DOI: 10.1101/gr.6861907) and visualizing CNVs of interest with iPsychCNV. It also contains selected helper-files for the purpose including 93 CNVs of Interest (based on Kendall et al 2017,  DOI: 10.1016/j.biopsych.2016.08.014) in hg18, hg19 and hg38. 

# sMRI instructions
This folder includes easy-to-use scripts and software for extracting structural brain measures as derived from FreeSurfer. This also includes processing and extracting data from the brainstem, hypothalamus, hippocampus, amygdala and thalamic nuclei. 

The structural brain measures include cortical thickness, surface area, cortical volume, subcortical volume, mean curvature, gaussian curvature, fold index, curvature index, local gyrification index. It also extracts out Euler number as an index of image quality. Assessment of image and reconstruction quality should be evaluated using the ENIGMA QC protocol (https://enigma.ini.usc.edu/protocols/imaging-protocols/).  

It is strongly recommended to use FreeSurfer v7.2.0 for extracting structural brain measures. If you cannot update your FreeSurfer version, it is possible to run the script using the FreeSurfer docker image (https://hub.docker.com/r/freesurfer/freesurfer). 
