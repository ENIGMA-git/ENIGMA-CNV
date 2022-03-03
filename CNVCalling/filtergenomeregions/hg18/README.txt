#### Centromeric, telomeric, segmental duplications regions
-all files were downloaded and manipulated 2015-03-31

## Centromeric regions ##
centro_hg18.txt 
	# Downloaded from the UCSC browser, TableBrowser, choose assembly ÒMar. 2006 (NCBI36/hg18)", group "All Tables", choose Table "gap", click "Filter create", Set the "type" field to centromere*.
	# created penncnv-inputfile and added 100 kb to each end
	awk '{if (NR>2) {printf $2 ":" $3 "-" $4 "\n"}}' Centromericregion_hg18.txt | # pennncnv format conversion
	awk '{if (NR>2) {printf $2 ":" $3-100000 "-" $4+100000 "\n"}}' - >centro_hg18.txt # add 100kb on each side

## Immunoglobulin regions  ##
immuno_hg18.txt
	# copied from the homepage of PennCNV (http://penncnv.openbioinformatics.org/en/latest/misc/faq/)
	
## Segmental duplications regions ##
segmentaldups_hg18.txt

# Downloaded from: http://hgdownload.cse.ucsc.edu/goldenPath/hg18/database/genomicSuperDups.txt.gz
# Converted segmentaldup-file to bed-format, merged and converted to penncnv-inputfile
		awk 'BEGIN {OFS="\t"} {print $2 OFS $3 OFS $4 OFS $5 "\n" $8 OFS $9 OFS $10 OFS $5}' genomicSuperDups.txt | # convert to bed-format
		sort -k1,1 -k2,2n | # sort prior to merging
		./mergeBed -i | # goes from 103618 lines to 8491 (=considerable overlap)
		awk '{printf $1 ":" $2 "-" $3 "\n"}' >segmentaldups_hg18.txt # Convert back to penn-cnv-inputfile


## Telomeric regions ##
telo_hg18.txt 

	# Downloaded end chromosomes from the UCSC browser:
		-TableBrowser, choose assembly "Mar. 2006 (NCBI36/hg18), choose group "All Tables", choose Table "chromInfo"

	# Selected all chr, converted to PennCNV-input-file and treated 500 kb from each end as telomeric region.
	# Modified the file as follows:
	grep -v "random" tmp  | grep -v "hap" | # selected all chromosomes 
	awk '{if (NR>1) {printf $1 ":0-500000" "\n" $1 ":" $2-500000 "-" $2 "\n"}}'  |  # Added +/-500kb 
	grep -v "chrM" >telo.txt # Removed mitochondrial chromosome

