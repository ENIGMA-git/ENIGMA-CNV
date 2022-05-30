The following scripts includes original scripts and modified from the ENIGMA imaging protocols (https://enigma.ini.usc.edu/protocols/imaging-protocols/). 
To run the  

A brief overview of the shell scripts and their purposes are presented below: 

0_organize_data.sh 
= creates and labels folders containing the imaging files (the folder names will be important for the other scripts). 

1_enigma_runfreesurfer.sh 
= runs the recon-all function on one subject.

1a_enigma_runfreesurfer_loop.sh 
= runs the recon-all function on all subjects.
 
2_extractmeasures_mri.sh 
= creates a CSV file that includes measures of area thickness, thickness standard deviation, volume, mean curvature Gaussian curvature, fold index curvature index, subcortical volumes, and Euler number for all subjects. 

s0_optional_segmentation.sh 
= segments the brainstem/hypothalamus/thalamic nuclei/amygdala/hippocampus and creates a .csv file for each region containing measures of volume of the segmented areas/subunits/subfields for all participants (Requires MATLAB runtime or MATLAB). 

s1_optional_LGI.sh = creates measures of a local gyrification index for all participants (Requires MATLAB).

s1a_optional_LHItable.sh = extracts measures of local gyrification for each region of interest-based on the Desikan-Killiany atlas (Requires MATLAB). 

3_merge_MR_data.sh = merges all of the files that are created above to one CSV file (requires R).

FreeViewMe.sh = automatically loads the volumes orig.mgz and aparc+aseg.mgz files and the surface files for white and pial surface for manual inspection of the reconstruction for a specified subject.  

RunFreeSurferDocker.sh = Calls the dockerized FreeSurfer v7.2.0 package. Will run the optional segmentation analyses as these may not be available in older FreeSurfer versions (e.g., < v6) or does not work due to mac version (problems reported with macOS Big Sur).   
