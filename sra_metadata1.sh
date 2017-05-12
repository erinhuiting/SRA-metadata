#!/bin/bash

# sra_metatdata - a script to obtain SRA metadata
 
#Interactive reading of SRA study accession ids
#Must enter only one id at a time
echo "Enter a SRA study accession id without comma"
read SRA
echo The ids given were: $SRA

#Obtain metadata from an SRA study
#Create table with SRA study, experiment, and run accession IDs
for currentid in $SRA
do
	#echo "$currentid"
mkdir -p sra_metadata/"$currentid"
	chmod 755 sra_metadata/"$currentid"
	url="http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&db=sra&rettype=runinfo&term=$currentid"
	#echo "$url"
	file="$currentid.study"
	#echo "$file"
	wget -O $file $url
	output_table="$currentid.table"
	#echo "$outputfile_table"
	awk -v a="$currentid" -F',' '{print a "\t" $11 "\t" $1}' $file | tail -n +2 | head -n -1 > $output_table
	#cat $output_table
	sed -i '1i Study\t\tExperiment\tRun' $output_table 
	#cat $output_table		
done


#Obtaining metadata from the experiments within the study
#Extact SRA experiment ids from newly created SRA study file
for currentfile in *.study
do
	#echo "$currentfile"
	output_table2="$currentid.table2_expids"
	#echo "$output_table2"
	awk -F',' '{print $11}' $currentfile | tail -n +2 | head -n -1 > $output_table2
	#cat $output_table2 
	output_table3="$currentid.table3_expids"
	sort -u $output_table2 | tail -n +2 > $output_table3
	#cat $output_table3

	while read currentexpid; do 
		#echo "$currentexpid"
		url2="http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&db=sra&rettype=runinfo&term=$currentexpid"
		#echo "$url2"
		file2="$currentid.$currentexpid.exp"
		echo "$file2"
		wget -O $file2 $url2
	done < $output_table3
	rm *.table2_expids
	rm *.table3_expids
done


#Obtaining metadata from the runs within experiments
#Extact SRA run ids from newly created SRA experiment files
for currentfile in "$file"
do 
	#echo "$currentfile"
	output_table4="$currentid.table4_runids"
	#echo "$output_table4"
	awk -F',' '{print $1}' $currentfile | tail -n +2 | head -n -1 > $output_table4
	#cat $output_table4
	
	while read currentrunid; do
		#echo "$currentrunid"
		url3="http://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&db=sra&rettype=runinfo&term=$currentrunid"
		#echo "$url3"
		file3="$currentid.$currentrunid.run"
		#echo "$file3"
		wget -O $file3 $url3
	done < $output_table4
	rm *.table4_runids
done


#Combining all SRA experiment metadata files into new file 
#Moving SRA experiment files into the sra_metadata folder and then the SRA current ID subfolder
for experiments in *.exp
do
	#echo "$experiments"
	file4="$currentid.combined.exp"
	#echo "$currentid.combined.exp"
	cat $experiments >> $file4
done


#Combining all SRA run metadata files into a new file
#Moving SRA run files into the sra_metadata folder and then the SRA current ID subfolder
for runs in *.run
do 
	#echo "$runs"
	file5="$currentid.combined.run"
	cat $runs >> $file5
done


#Moving SRA study files into the sra_metadata folder and then the SRA current ID subfolder
mv $currentid* sra_metadata/$currentid/.
