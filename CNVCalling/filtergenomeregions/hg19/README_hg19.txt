#### Centromeric, telomeric, segmental duplications regions
-all files were downloaded and converted 2017-10-23

#########################
## Centromeric regions ##
#########################
centro_hg19.txt
	# Downloaded from the UCSC browser, TableBrowser, choose assembly "'Feb. 2009 (GRCh37/hg19), group "All Tables", choose Table "gap", click "Filter create", Set the "type" field to centromere*.
	# created penncnv-inputfile 
	awk '{if (NR>2) {printf $2 ":" $3 "-" $4 "\n"}}' tmp | sort | uniq >centro_hg19.txt 

#############################
## Immunoglobulin regions  ##
#############################
immuno_hg19.txt 
	# copied from the homepage of PennCNV ((http://penncnv.openbioinformatics.org/en/latest/misc/faq/)
	# converted via UCSC liftover (2017-10-23) on immuno_hg18.txt (based on hg18)

####################################
## Segmental duplications regions ##
####################################
segmentaldups_hg19.txt 

	# Downloaded from:
		http://hgdownload.cse.ucsc.edu/goldenPath/hg19/database/genomicSuperDups.txt.gz

	# Convert segmentaldup-file to bed-format, merged and converted to penncnv-inputfile
	awk 'BEGIN {OFS="\t"} {print $2 OFS $3 OFS $4 OFS $5 "\n" $8 OFS $9 OFS $10 OFS $5}' genomicSuperDups.txt | # convert to bed
	sort -k1,1 -k2,2n | mergeBed -i | # sort and merge
	awk '{printf $1 ":" $2 "-" $3 "\n"}' >segmentaldups_hg19.txt # convert to penncnv-inputfile

			
#######################
## Telomeric regions ##
#######################
telo_hg19.txt 

	# How to: Go to UCSC browser, TableBrowser, choose assembly "Mar. 2006 (GRCh37/hg19)",  choose group "All Tables", choose Table "chromInfo".

	# Convertion to PennCNV Inputfiles
	grep -v "random" tmp  | grep -v "hap" | grep -v "fix" | grep -v "alt" | grep -v "Un" | awk '{if (NR>1) {printf $1 ":0-500000" "\n" $1 ":" $2-500000 "-" $2 "\n"}}' | grep -v "chrM" >telo_hg19.txt
