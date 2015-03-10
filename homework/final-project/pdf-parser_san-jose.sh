#!/bin/sh

baseDir=./data-hold/san-jose/current-pdfs


# done < <(pdftotext -layout $baseDir/40106.pdf -)

# initialize set of position variables to help with parsing
page=-1
title="undefined"
meeting_date="undefined"
in_section=false
active_section="none"
in_item=false
active_item="none"
item_content=""
#line_num=0

# define function to print entire item to screen
function print_item {
	if [[ $in_item = true ]]; then
		#echo "Meeting Title: $title"
		#echo "Date: $meeting_date"
		#echo "Section: $active_section"
		#echo "Item: $active_item"
		item_content=$(echo $item_content | sed -E 's/^\. //') #strip out extra . at beginning of line
		echo "Content: $item_content"
		echo "END ITEM"
		in_item=false
	fi
	
}

# iterate over each pdf (converted to XML-like text and loosely cleaned)
while read line; do
	# line_num=$(expr $line_num + 1)
	# echo "line_num: $line_num"

	#echo "      $line"

	if [[ $line =~ '<page id="' ]]; then
		page=$(echo $line | sed 's/page/p/' | pup 'p attr{id}') #hacky way to get page number
	fi

	# FRONT PAGE
	if [[ $page -eq 0 ]]; then #if on the front page

		#check if end of first page
		if [[ $line =~ '</page>' ]]; then
			page=2

		elif [[ $line =~ '<P ' ]]; then #paragraphs

			#check if title has been set yet
			if [[ $title == "undefined" ]]; then
				title=$(echo $line | pup 'p text{}') # set title

			# check if date has been set yet
			elif [[ $meeting_date == "undefined" ]]; then
				meeting_date=$(echo $line | pup 'p text{}') # set title
			fi
		fi
	fi

	# If page is > 0, make sure it's a regular agenda
	if [[ $page -gt 0 && $title =~ "CITY COUNCIL AGENDA" ]]; then

		# check if line is a section heading
		h1_regex="H1 MCID=\"[[:digit:]]{1,}\">[[:digit:]]{1,}." #set heading regex as variable
		if [[ $line =~ $h1_regex ]]; then
			in_section=true

			# extract text from heading
			clean_line=$(echo $line | pup 'h1 text{}')

			#make sure if continuation of existing section
			if [[ $clean_line =~ $active_section ]]; then
				echo "__continuing previous section"
			else #new section

				# # check if there is still an open item from the previous section
				if [[ $in_item = true ]]; then
					print_item
				fi

				# reset for new section
				active_section=$clean_line
				echo " ============================= $active_section =================="
			fi

		# check if line begins one of the unnecessary sections at the end
		elif [[ $line =~ "Open Forum" || $line =~ "Adjournment" || $line =~ "Notice of City Engineers" ]]; then
			echo "============================ close section ====================="
			in_section=false

		# make sure line is in an active section - don't care about extra material at the end
		elif [[ $in_section = true ]]; then

			# check if line is an item heading
			h2_regex="MCID=\"[[:digit:]]{1,}\">[[:digit:]]+.[[:digit:]]{1,}" #set heading regex as variable
			if [[ $line =~ $h2_regex ]]; then

				# extract text from heading
				clean_line=$(echo $line | sed 's:Link:h2:g' | sed 's:<P :<h2 :g' | pup 'h2 text{}')

				# extract item numbers
				line_num=$(echo $clean_line | grep -oE "^[[:digit:]]{1,}.[[:digit:]]{1,}")
				active_item_num=$(echo $active_item | grep -oE "^[[:digit:]]{1,}.[[:digit:]]{1,}")

				# check if continuation of existing item
				if [[ $line_num == $active_item_num ]]; then
					echo "___continuing previous item"
				else # new item
					
					#dump completed previous item to screen
					print_item

					#reset for new item
					in_item=true

					echo "START ITEM"
					item_content="" # move this to a test for continuing items
					active_item=$clean_line
					echo "-------------------------------- $active_item"
				fi

			# potentially add elif here to exclude certain material and close items

			# make sure in an active section
			elif [[ $in_item = true ]]; then

				#echo "__ $line"

				current_content=$(echo $line | tr -d "\*" | pup 'text{}' | sed 's:\n::g' | sed 's/San Jos/San Jose/g')
				item_content+=$current_content
			fi
		fi
	fi

done < <(python pdf2txt.py -t tag $baseDir/40594.pdf | tr -cd "[:print:]" | sed -E 's:</[[:alnum:]]+>:&\n:g' | sed -E 's:<page[^>]+>:&\n:g' | grep -v -E '>[[:space:]]+</P>' | grep -v '<Artifact')

# at the end of the loop, print final item (if any)
if [[ $in_item = true ]]; then
	print_item
fi

# print error message if not a regular Council Agenda
if [[ ! $title =~ "CITY COUNCIL AGENDA" ]]; then
	echo "Not a standard agenda, please review manually"
fi