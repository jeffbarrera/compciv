#!/bin/sh

###################################
# SETUP
###################################

# make sure PDFminer is installed
pip -q install PDFminer

# add scraper
bash scraper.sh

###################################
# PARSE DOWNLOADED PDFs
###################################

# if it doesn't exist, create tables directory
if [[ ! -d ./tables ]]; then
	mkdir ./tables
fi

# initialize csv
timestamp=$(date '+%Y-%m-%d') # check date
output_filename="./tables/$timestamp.csv" #put date into filename var
printf '"Agency","Date","Agenda Section","Item Heading","Item Content","Relevance Score"\n' > $output_filename

function printParserHeadings () {
	echo ""
	echo "Parsing agendas from the $1"
	echo "================================================"
}

# run script for each agency
printParserHeadings "City of San Jose"
bash pdf-parser_san-jose.sh $output_filename

printParserHeadings "County of Santa Clara"
bash pdf-parser_santa-clara.sh $output_filename

###################################
# CALCULATE RELEVANCE SCORES
###################################

echo "" #blank line to make output easier to read

# check if there are agenda items to search
num_lines=$(csvfix echo $output_filename | wc -l)
if [[ $num_lines -gt 1 ]]; then
	
	# check if a list of terms was passed in
	if [[ -n $1 ]]; then
		echo "Searching for terms: $@"
		bash relevance-scorer.sh $timestamp "$@"
	else
		echo "No terms provided, not calculating relevance scores"
	fi

	# print out completion status
	echo ""
	echo "================================================"
	echo "AGENDA CHECK COMPLETED!"
	echo "Output file: $output_filename"
else
	#no new agenda items, print completion message and delete empty file
	#rm $output_filename
	echo "Check completed, no new agenda items were found."
fi


