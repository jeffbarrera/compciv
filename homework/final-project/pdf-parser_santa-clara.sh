#!/bin/sh

# make sure output filename was passed in
if [[ -n $1 ]]; then
	output_filename=$1

	# set base directory
	baseDir=./data-hold/santa-clara-county/current-pdfs

	# make sure there are pdfs to parse
	if [[ "$(ls -A $baseDir)" ]]; then

		# loop through all pdfs in base directory
		for pdf in $baseDir/*.pdf; do

			#echo status message
			echo "Parsing $pdf"

			# initialize set of position variables to help with parsing
			reached_content=false
			title="undefined"
			meeting_date="undefined"
			valid_agenda=false
			in_section=false
			active_section="none"
			in_item=false
			active_item="none"
			item_content=""

			# define function to print entire item to screen
			function print_item {
				if [[ $in_item = true ]]; then

					# delete quotes to avoid csv issues
					active_item=$(echo $active_item | tr -d "\"" | tr -d "\'")
					item_content=$(echo $item_content | tr -d "\"" | tr -d "\'")

					# printout for debugging
					#echo "Meeting Title: $title"
					#echo "Date: $meeting_date"
					#echo "Section: $active_section"
					#echo "Item: $active_item"
					#echo "Content: $item_content"
					#echo "END ITEM"
					
					# write complete line to csv
					printf '"Santa Clara County","%s","%s","%s","%s",""\n' "$meeting_date" "$active_section" "$active_item" "$item_content" >> $output_filename
					
					#reset loop
					in_item=false
				fi
			}

			# iterate over each line in the pdf
			IFS=''
			while read line; do

				####### Meeting Information

				# get title from top line
				if [[ $title == "undefined" ]]; then
					clean_line=$(echo $line | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+?$//') #strip whitespace
					title=$clean_line

					#echo "Title: $clean_line"
				fi

				#get date
				if [[ $meeting_date == "undefined" ]]; then
					date=$(echo $line | grep -oE "^[[:space:]]+[[:alpha:]]+ [[:digit:]]{1,2}, [[:digit:]]{4}")
					if [[ $date != "" ]]; then
						clean_date=$(echo $date | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+?$//') #strip whitespace
						meeting_date=$clean_date
					fi
				fi

				if [[ $valid_agenda = false ]]; then
					meeting_type=$(echo $line | grep -o "Regular Meeting")
					if [[ $title == "BOARD OF SUPERVISORS" && $meeting_type == "Regular Meeting" ]]; then
						valid_agenda=true
					fi
				fi

				####### Agenda Items

				#make sure current agenda is valid
				if [[ $valid_agenda = true ]]; then

					# check if line is a section heading
					h1_regex="^[[:space:]]{20,}[[:upper:]]" #set heading regex as variable
					if [[ $line =~ $h1_regex || $line =~ "Housing, Land Use, Environment, and Transportation Committee" ]]; then #edge case with long heading

						# ignore everything before Ceremonial Presentations
						if [[ $line =~ "Ceremonial Presentations" ]]; then
							reached_content=true
						fi

						#ignore "Time Certain" lines - they mess with the parsing format
						if [[ ! $line =~ "Time Certain -" && $reached_content = true ]]; then
							in_section=true
							clean_line=$(echo $line | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+?$//') #strip whitespace

							# check if there is still an open item from the previous section
							if [[ $in_item = true ]]; then
								print_item
							fi

							# reset for new section
							active_section=$clean_line
							#echo "====================== $active_section ======================="
						fi

					# check if within actual content
					elif [[ $reached_content = true && $in_section = true ]]; then
						#statement

						# check if line is an item heading
						h2_regex="^[[:space:]]+?[[:digit:]]{1,}. [[:upper:]]"
						if [[ $line =~ $h2_regex ]]; then

							#dump completed previous item to csv
							print_item

							#reset for new item
							in_item=true
							item_content=""
							clean_line=$(echo $line | sed -E 's/^[[:space:]]+//') #strip whitespace
							active_item=$clean_line

						# check if line continues an item heading
						h2_continues_regex="^[[:space:]]{5}[[:punct:]]?[[:alnum:]]"

						elif [[ $in_item = true && $line =~ $h2_continues_regex ]]; then

							clean_line=$(echo $line | sed -E 's/^[[:space:]]+//') #strip whitespace
							active_item="$active_item $clean_line"

						# check if open item, if so add as content
						elif [[ $in_item = true ]]; then
							clean_line=$(echo $line | tr -cd "[:print:]" | sed -E 's/^[[:space:]]+//') #strip whitespace
							item_content="$item_content $clean_line"
						fi
					fi
				fi

			done < <(pdftotext -layout -nopgbrk $pdf - | grep -v -E "Agenda[[:space:]]+Board of Supervisors, County of Santa Clara" | grep -v -E "Page [[:digit:]]+ of [[:digit:]]+" | grep -v -E "[[:digit:]]{1,2}, [[:digit:]]{4}$" | grep -v -E "^[[:space:]]?$")

			# at the end of the loop, print final item (if any)
			if [[ $in_item = true ]]; then
				print_item
			fi

			# print error message if not a regular agenda
			if [[ $valid_agenda = true ]]; then
				echo "...successful"
			else
				echo "$pdf is not a standard agenda, please review manually"
			fi
		done
	else
		echo "No new PDFs to parse"
	fi
else
	echo "ERROR: Please pass in a filename to output"
fi