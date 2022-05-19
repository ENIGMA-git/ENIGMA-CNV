Short outline of CNV-calling script:

_0. CNV calling with PennCNV on autosomes and X-chr using PFB (population frequency file) and GC (GC content) model files generated based on the dataset if >300 individuals and standard HMM-file._

_1. First filtering QC_

QC-parameters (all can be easily adjusted, currentlys set at lenient values):
LRR_SD=0.50. = Log R Ratio SD. 
BAF_drift=0.02. B Allelle frequency drift.
WF=0.05. Wave factor. 
NoofSNPs=15. 

_2. Merge CNVs_

PennCNV tends to split CNVs into smaller parts.
MergeFraction set at 0.3 = indicates the distance (in bp or snps) for when merging is done. Often need to be adjusted according to the the number of SNPs and distance between SNPs on the chip in question.

_3. Remove CNVs from specific genomic regions (centromeric, telomeric, segmental duplications and immunoglobulin regions)_

These regions are known to harbor spurious CNV calls that might represent cell-line artifacts.
MinQueryFrac (eg. 0.5) indicates the minimum overlap of the region to the CNV for removal.

_4. QC plots_

NumCNV vs LRR_SD, BAF_drift, WF
Histograms post/preQC of NumCNV, LRR_SD, BAF_drift, WF

_5. Visualization of CNVs of Interest and all CNVs>50kb with iPsychCNV_

Log R Ratio (LRR) and B-allele Frequency (BAF) along the chromosome
CNVs of Interest can be selected by the user but currently consists of:
-93 recurrent CNVs (Kendall et al 2017,  DOI: 10.1016/j.biopsych.2016.08.014) in hg18, hg19 or hg38 through iPsychCNV Stackplot (Stackplot allows you to easily compare LRR-BAG plots with individuals not predicted to carry the CNV in question).
All CNVs >50 kb are visualized with iPsychCNV PlotCNVsFromDataFrame.

Other QC-parameters often used in CNV calling but not applied here:

-Call rate>0.95/0.97 
-No of CNVs/sample.

_Software - enigma-cnv.sif singularity container_

enigma-cnv.sif contains PennCNV and iPsychCNV (and all the necessary prerequisites) and was developed for use in ENIGMA-CNV by Bayram Akdeniz  (https://github.com/comorment/containers/blob/main/singularity/enigma-cnv.sif). 
