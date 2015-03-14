#!/bin/sh

# add parameters, scraper

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

# run script for each agency

echo ""
echo "Parsing agendas from the City of San Jose"
echo "================================================"
bash pdf-parser_san-jose.sh $output_filename

echo ""
echo "Parsing agendas from the County of Santa Clara"
echo "================================================"
bash pdf-parser_santa-clara.sh $output_filename