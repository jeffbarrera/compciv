#!/bin/sh

baseDir=./data-hold/santa-clara-county/current-pdfs

# # initialize set of position variables to help with parsing
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
		#echo "Meeting Title: $title"
		#echo "Date: $meeting_date"
		#echo "Section: $active_section"
		echo "Item: $active_item"
		echo "Content: $item_content"
		echo "END ITEM"
		in_item=false
	fi
	
}

# iterate over each pdf
IFS=''
while read line; do

	#echo "$line"

	####### Meeting Information

	# get title from top line
	if [[ $title == "undefined" ]]; then
		clean_line=$(echo $line | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+?$//') #strip whitespace

		echo "Title: $clean_line"
		title=$clean_line
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
		h1_regex="^[[:space:]]{15,}[[:upper:]]" #set heading regex as variable
		if [[ $line =~ $h1_regex ]]; then

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
				echo "====================== $active_section ======================="
			fi

		# check if within actual content
		elif [[ $reached_content = true && $in_section = true ]]; then
			#statement

			# check if line is an item heading
			h2_regex="^[[:space:]]?[[:digit:]]{1,}. [[:upper:]]"
			if [[ $line =~ $h2_regex ]]; then

				#dump completed previous item to screen
				print_item

				#reset for new item
				in_item=true
				item_content=""
				clean_line=$(echo $line | sed -E 's/^[[:space:]]+//') #strip whitespace
				active_item=$clean_line

			# check if line continues an item heading
			h2_continues_regex="^[[:space:]]{5}[[:punct:]]?[[:alnum:]]"
			# h2_continues_regex="^[[:space:]]{5}[^\u2022]"

			# ==================== FIX THIS EDGE CASE - #38, $ at begining of line

			elif [[ $in_item = true && $line =~ $h2_continues_regex ]]; then

				#echo $line

				clean_line=$(echo $line | sed -E 's/^[[:space:]]+//') #strip whitespace
				active_item="$active_item $clean_line"

			# check if open item, if so add as content
			elif [[ $in_item = true ]]; then
				clean_line=$(echo $line | tr -cd "[:print:]" | sed -E 's/^[[:space:]]+//') #strip whitespace
				item_content="$item_content $clean_line"
			fi
		fi
	fi

# 	# FRONT PAGE
# 	if [[ $page -eq 0 ]]; then #if on the front page

# 		#check if end of first page
# 		if [[ $line =~ '</page>' ]]; then
# 			page=2

# 		elif [[ $line =~ '<P ' ]]; then #paragraphs

# 			#check if title has been set yet
# 			if [[ $title == "undefined" ]]; then
# 				title=$(echo $line | pup 'p text{}') # set title

# 			# check if date has been set yet
# 			elif [[ $meeting_date == "undefined" ]]; then
# 				meeting_date=$(echo $line | pup 'p text{}') # set title
# 			fi
# 		fi
# 	fi

# 	# If page is > 0, make sure it's a regular agenda
# 	if [[ $page -gt 0 && $title =~ "CITY COUNCIL AGENDA" ]]; then

# 		# check if line is a section heading
# 		h1_regex="H1 MCID=\"[[:digit:]]{1,}\">[[:digit:]]{1,}." #set heading regex as variable
# 		if [[ $line =~ $h1_regex ]]; then
# 			in_section=true

# 			# extract text from heading
# 			clean_line=$(echo $line | pup 'h1 text{}')

# 			#make sure if continuation of existing section
# 			if [[ $clean_line =~ $active_section ]]; then
# 				echo "__continuing previous section"
# 			else #new section

# 				# # check if there is still an open item from the previous section
# 				if [[ $in_item = true ]]; then
# 					print_item
# 				fi

# 				# reset for new section
# 				active_section=$clean_line
# 				echo " ============================= $active_section =================="
# 			fi

# 		# check if line begins one of the unnecessary sections at the end
# 		elif [[ $line =~ "Open Forum" || $line =~ "Adjournment" || $line =~ "Notice of City Engineers" ]]; then
# 			echo "============================ close section ====================="
# 			in_section=false

# 		# make sure line is in an active section - don't care about extra material at the end
# 		elif [[ $in_section = true ]]; then

# 			# check if line is an item heading
# 			h2_regex="MCID=\"[[:digit:]]{1,}\">[[:digit:]]+.[[:digit:]]{1,}" #set heading regex as variable
# 			if [[ $line =~ $h2_regex ]]; then

# 				# extract text from heading
# 				clean_line=$(echo $line | sed 's:Link:h2:g' | sed 's:<P :<h2 :g' | pup 'h2 text{}')

# 				# extract item numbers
# 				line_num=$(echo $clean_line | grep -oE "^[[:digit:]]{1,}.[[:digit:]]{1,}")
# 				active_item_num=$(echo $active_item | grep -oE "^[[:digit:]]{1,}.[[:digit:]]{1,}")

# 				# check if continuation of existing item
# 				if [[ $line_num == $active_item_num ]]; then
# 					echo "___continuing previous item"
# 				else # new item
					
# 					#dump completed previous item to screen
# 					print_item

# 					#reset for new item
# 					in_item=true

# 					echo "START ITEM"
# 					item_content="" # move this to a test for continuing items
# 					active_item=$clean_line
# 					echo "-------------------------------- $active_item"
# 				fi

# 			# potentially add elif here to exclude certain material and close items

# 			# make sure in an active section
# 			elif [[ $in_item = true ]]; then

# 				#echo "__ $line"

# 				current_content=$(echo $line | tr -d "\*" | pup 'text{}' | sed 's:\n::g' | sed 's/San Jos/San Jose/g')
# 				item_content+=$current_content
# 			fi
# 		fi
# 	fi

done < <(pdftotext -layout -nopgbrk $baseDir/5922.pdf - | grep -v -E "Agenda[[:space:]]+Board of Supervisors, County of Santa Clara" | grep -v -E "Page [[:digit:]]+ of [[:digit:]]+" | grep -v -E "[[:digit:]]{1,2}, [[:digit:]]{4}$" | grep -v -E "^[[:space:]]?$")

# at the end of the loop, print final item (if any)
if [[ $in_item = true ]]; then
	print_item
fi

# # print error message if not a regular Council Agenda
# if [[ ! $title =~ "CITY COUNCIL AGENDA" ]]; then
# 	echo "Not a standard agenda, please review manually"
# fi




#python pdf2txt.py -t tag $baseDir/5922.pdf | tr -cd "[:print:]" | sed -E 's:</[[:alnum:]]+>:&\n:g' | sed -E 's:<page[^>]+>:&\n:g' | grep -v -E '>[[:space:]]+</P>' | grep -v '<Artifact'