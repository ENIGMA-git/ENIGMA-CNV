#### Centromeric, telomeric, segmental duplications regions
-most files were downloaded and converted 2022-03-03

#########################
## Centromeric regions ##
#########################
centro_hg38.txt

	# Downloaded from the UCSC browser, TableBrowser, choose assembly “’Dec. 2013 (GRCh38/hg38), group “Mapping and Sequencing group”, track “Chromosome Band (Ideogram)", filter create, and enter "acen" in the gieStain field, "choose output format “BED”. Description here: https://www.biostars.org/p/435003/

# Merge p & q-arm, convert to penncnv-input-file
mergeBed -i tmp | awk '{printf $1 ":" $2-100000 "-" $3+100000 "\n"}' >centro_hg38.txt 

#############################
## Immunoglobulin regions  ##
#############################
immuno_hg38.txt

	# copied from the homepage of PennCNV
	# converted via liftover (2021-03-18) to hg38 based on immuno_hg18.txt
	
####################################
## Segmental duplications regions ##
####################################
segmentaldups_hg38.txt

	# Downloaded from:
		http://hgdownload.cse.ucsc.edu/goldenPath/hg38/database/genomicSuperDups.txt.gz

	# Convert segmentaldup-file to bed-format, merged and converted to penncnv-inputfile
		awk 'BEGIN {OFS="\t"} {print $2 OFS $3 OFS $4 OFS $5 "\n" $8 OFS $9 OFS $10 OFS $5}' genomicSuperDups.txt |  # convert to bed-format
			sort -k1,1 -k2,2n | # sort (for merging)
			mergeBed -i  | # merge
			awk '{printf $1 ":" $2 "-" $3 "\n"}' >segmentaldups_hg38.txt

#######################
## Telomeric regions ##
#######################
telo_hg38.txt 

	# How to: Go to UCSC browser, TableBrowser, choose assembly “’Dec. 2013 (GRCh38/hg38), choose group "All Tables", choose Table "chromInfo".

# Convertion to PennCNV Inputfiles
	grep -v "random" tmp  | grep -v "hap" | grep -v "fix" | grep -v "alt" | grep -v "Un" | awk '{if (NR>1) {printf $1 ":0-500000" "\n" $1 ":" $2-500000 "-" $2 "\n"}}' | grep -v "chrM" >telo_hg38.txt




