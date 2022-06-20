# ENIGMA-CNV containers

Two container softwares are available:
	1. Docker – for all systems on computer with internet access
	2. Singularity – for unix only and for systems without internet-access

The software in the enigma-cnv container is:
*PennCNV v1.0.5, used for CNV calling
*R 3.3.1 + relevant R packages including iPsychCNV for visualization


## 1. Docker container
After download of docker software, please download the enigma-cnv:latest container  by writing in the terminal:

docker pull bayramalex/enigma-cnv

## 2. Singularity container
_Download with singularity already installed_

singularity build enigma-cnv.sif docker://bayramalex/enigma-cnv:latest

_Download without singularity_

From this repository _enigma-cnv.sif_

