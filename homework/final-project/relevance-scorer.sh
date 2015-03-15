#!/bin/sh

#set input and output files
timestamp=$1
input_filename="./tables/$timestamp.csv" #put timestamp into filename var
output_filename="./tables/$timestamp.ranked.csv" #put timestamp into filename var

printf '"Agency","Date","Agenda Section","Item Heading","Item Content","Relevance Score"\n' > $output_filename

while read line; do

	#initialize relevance score
	rel_score=1

	#lower score if part of consent calendar or ceremonial business
	section=$(echo $line | cut -d "|" -f 3 | tr "[[:upper:]]" "[[:lower:]]" | tr -d "." | tr -d "[[:digit:]]" | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+?$//')
	if [[ $section =~ "consent calendar" || $section =~ "ceremonial" || $section =~ "closing" ]]; then
		rel_score=0
	fi

	# loop over search terms
	for term in "${@:2}"; do
		term_metions=$(echo $line | grep -oi "$term" | wc -l)
		rel_score=$[$rel_score+($term_metions*2)]
	done

	#append relevance score to line
	line_up_to_score=$(echo $line | cut -d "|" -f 1-5 | tr "|" ",")
	printf '%s,"%s"\n' "$line_up_to_score" "$rel_score" >> $output_filename

done < <(csvfix echo -osep "|" -ifn $input_filename)

#sort csv by relevance score, swap to input file, delete temp output file
csvfix sort -rh -f 6:DN,3,4 $output_filename > $input_filename
rm $output_filename