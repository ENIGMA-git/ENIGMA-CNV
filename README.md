# Description, ENIGMA-CNV
This repository contains protocols for CNV calling and sMRI processing for the ENIGMA-CNV working group.

# Joining ENIGMA-CNV

A. Administrative – sign up for ENIGMA-CNV to the working group chairs.

Analysis and data submission:

B. Structural imaging data processing

- minimal protocol
- extended protocol

C. CNVs

- call and visualize

D. Covariates

E. Send data or request a secure transfer-link


Please follow the overall instructions in: _Instructions_ENIGMA-CNV-WG_v2.2.pdf_.

It may be beneficial to clone this entire repository using ``git clone.``
```
git clone https://github.com/ENIGMA-git/ENIGMA-CNV/
```

# CNV calling
This folder includes easy-to-use scripts for calling and filtering CNVs with PennCNV (Wang et al 2007, DOI: 10.1101/gr.6861907) and visualizion of CNVs of interest with iPsychCNV (https://github.com/mbertalan/iPsychCNV/).

The software (PennCNV and iPsych CNV with dependencies) is packaged in docker and singularity containers, respectively, to run independently of operating system.

Helper-files for the purpose includes a list of 93 CNVs of Interest (based on Kendall et al 2017,  DOI: 10.1016/j.biopsych.2016.08.014) in genome version hg18, hg19 and hg38.

# sMRI processing
This folder includes easy-to-use scripts and software for extracting structural brain measures as derived from FreeSurfer. This also includes processing and extracting data from the brainstem, hypothalamus, hippocampus, amygdala and thalamic nuclei.

The structural brain measures include cortical thickness, surface area, cortical volume, subcortical volume, mean curvature, gaussian curvature, fold index, curvature index, local gyrification index.

It also extracts Euler number as an index of image quality. Assessment of image and reconstruction quality should be evaluated using the ENIGMA QC protocol (https://enigma.ini.usc.edu/protocols/imaging-protocols/).  

It is strongly recommended to use FreeSurfer v7.2.0 for extracting structural brain measures. If you cannot update your FreeSurfer version, it is possible to run the script using the FreeSurfer docker image (https://hub.docker.com/r/freesurfer/freesurfer).
