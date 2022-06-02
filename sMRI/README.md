The following scripts includes original scripts and modified scripts from the ENIGMA imaging protocols (https://enigma.ini.usc.edu/protocols/imaging-protocols/).

## Brief overview of the shell scripts and their purposes

_0_organize_data.sh_

* Creates and labels folders containing the imaging files (the folder names will be important for the other scripts).

_1_enigma_runfreesurfer.sh_

* Runs the recon-all function on one subject.

_1a_enigma_runfreesurfer_loop.sh_

* Runs the recon-all function on all subjects.

_2_extractmeasures_mri.sh_

* Creates a CSV file that includes measures of area thickness, thickness standard deviation, volume, mean curvature Gaussian curvature, fold index curvature index, subcortical volumes, and Euler number for all subjects.

_s0_optional_segmentation.sh_

* Segments the brainstem/hypothalamus/thalamic nuclei/amygdala/hippocampus and creates a .csv file for each region containing measures of volume of the segmented areas/subunits/subfields for all participants (Requires MATLAB runtime or MATLAB).

_s0a_optional_seg_table.sh_

* Creates a .csv file for each region containing measures of volume of the segmented areas/subunits/subfields for all participants

_s1_optional_LGI.sh_

* Creates measures of a local gyrification index for all participants (Requires MATLAB).

_s1a_optional_LGI_table.sh_

* Extracts measures of local gyrification for each region of interest-based on the Desikan-Killiany atlas (Requires MATLAB).

_3_merge_MR_data.sh_

* Merges all of the files that are created above to one CSV file (requires R).

_FreeViewMe.sh_

* Automatically loads the volumes orig.mgz and aparc+aseg.mgz files and the surface files for white and pial surface for manual inspection of the reconstruction for a specified subject.  

_RunFreeSurferDocker.sh_

* Calls the dockerized FreeSurfer v7.2.0 package. Will run the optional segmentation analyses as these may not be available in older FreeSurfer versions (e.g., < v6) or does not work due to mac version (problems reported with macOS Big Sur).   
