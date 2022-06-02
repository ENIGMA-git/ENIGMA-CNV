# Outline of CNV-calling scripts

Please follow the overall instructions in: _Instructions_ENIGMA-CNV-WG_v2.2.pdf_.

Needed scripts:
* _ENIGMA-CNV_CNVProtocol_v2_docker.sh_ or _ENIGMA-CNV_CNVProtocol_v2_singularity.sh_ (choose dependent on software container)
* _ENIGMA-CNV_visualize_v1.R_ (for visualization)
* _compile_pfb_new.pl_ (for compiling PFB)

## Folders and files

_containers_

enigma-cnv.sif (singularity) and enigma-cnv:latest (docker) are software containers containing PennCNV and iPsychCNV (and all the necessary prerequisites) and were developed for use in ENIGMA-CNV by Bayram Akdeniz  (https://github.com/comorment/containers/blob/main/singularity/enigma-cnv.sif).

_CNVsofInterests_

Includes files with 93 recurrent CNVs (Kendall et al 2017,  DOI: 10.1016/j.biopsych.2016.08.014) in genome version hg18, hg19 or hg38 to be used in visualization.

_PFBGCMODELHMM_

Includes the hidden markov files used in CNV-calling

_examplefiles_

Includes examples of the formats of files used in CNV calling.

_filtergenomeregions_

Includes files with centromeric, telomeric, segmental duplications regions to be used in filtering of CNVs.

## General outline of procedure/scripts

_0. CNV calling on autosomal and X-chromosomes_

Software: PennCNV

PFB (population frequency file) and GC (GC content) model files are generated based on the input dataset if >300 individuals

_1. Filtering QC_

QC-parameters (all can be easily adjusted, currently set at lenient values for ENIGMA-CNV):
* LRR_SD=0.40 (Log R Ratio standard deviation).
* BAF_drift=0.02 (B Allelle frequency drift).
* WF=0.05 (Wave factor).
* NoofSNPs=15 (no of SNPs).

Note: Other QC-parameters often used in CNV calling but not applied here:
* Call rate>0.95/0.97.
* No of CNVs/sample.

_2. Merge CNVs_

PennCNV tends to split CNVs into smaller parts.

MergeFraction = 0.3. This indicates the distance (in this case in bp) for when merging is done. This often needs to be adjusted according to the the number of SNPs and distance between SNPs on the chip in question.

_3. Remove CNVs from specific genomic regions (centromeric, telomeric, segmental duplications and immunoglobulin regions)_

These regions are known to harbor spurious CNV calls that might represent cell-line artifacts.

MinQueryFrac =eg. 0.5. This indicates the minimum overlap of the region to the CNV for removal.

_4. QC plots_

* LRR_SD vs NumCNV
* WF vs NumCNV
* BAF_drift vs NumCNV
* Histograms pre/postQC of NumCNV, LRR_SD, BAF_drift, WF.

_5. Visualization of CNVs of Interest and all CNVs>50kb_

Your CNVs of Interests are visualized in Log R Ratio (LRR) and B-allele Frequency (BAF) plots applying iPsychCNV Stackplot (Stackplot allows you to easily compare LRR-BAF plots with individuals not predicted to carry the CNV in question).

All CNVs >50 kb are visualized with iPsychCNV PlotCNVsFromDataFrame.
