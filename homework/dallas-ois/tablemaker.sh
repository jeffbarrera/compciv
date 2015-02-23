#========================
# incidents.psv
#========================

#prepare tables/incidents.psv
printf 'case_number|date|location|suspect_status|suspect_weapon|suspects|officers|grand_jury|latitude|longitude|narrative\n' > ./tables/incidents.psv

#filter html pages for table rows, 
#remove line breaks within each row, 
#then read line-by-line
while read row; do

	#filter out header rows
	if [[ ! $row =~ "<th>" ]];then
		# strip out html tags, replace with | separators
		clean_row=$(echo $row | sed -E 's:<td[^>]+>::g' | sed 's:<tr>::g' | sed 's:</tr>::g' | sed 's:</td>:|:g')

		# extract associated pdf narrative name
		pdf_name=$(basename $(echo $clean_row | pup 'a attr{href}'))

		# extract narrative from pdf, remove line breaks and trailing whitespace
		narrative=$(pdftotext ./data-hold/pdfs/$pdf_name - | tr '\n' ' ' | sed -E 's/[[:space:]]+$//g')

		# remove link from case number field
		case_num=$(echo $clean_row | pup 'a text{}')
		clean_row=$(echo $clean_row | sed -E "s:<a href=[^<]+</a>:$case_num:")

		# extract address from $clean_row
		address=$(echo $clean_row | cut -d '|' -f 3)

		# check if address is the weird broken one
		if [[ $address =~ "2120 52" ]]; then
			address="2120 52nd Street"
			clean_row=$(echo $clean_row | sed -E 's:nd[^S]+Street:2120 52nd Street:')
		fi
		# fix if row is the weird 2-row one
		if [[ $address =~ "Handgun" ]]; then
			address=" 5813 Bonnie View Road "
			clean_row="281418N | 4/18/2004 | 5813 Bonnie View Road | Deceased | Handgun | Hibbler, Marcus B/M | Jablon, James W/M <br> Mondy, Mike B/M Owens, James W/M | No Bill |"
		fi

		# remove extra whitespace from addresses
		address=$(echo $address | sed 's/^ //g' | sed 's/ $//g')

		# find address in geocodes.psv
		geocode_line=$(cat ./tables/geocodes.psv | grep "$address")
		lat=$(echo $geocode_line | cut -d '|' -f 2)
		lng=$(echo $geocode_line | cut -d '|' -f 3)

		# write complete line to ./tables/incidents.psv
		printf '%s%s|%s|"%s"\n' "$clean_row" "$lat" "$lng" "$narrative" >> ./tables/incidents.psv
	fi
	
done < <(cat data-hold/*.html  | pup 'table table tr' | tr -d '\n' | sed 's:/tr>:/tr>\n:g')

#========================
# officers.psv
#========================

#prepare tables/officers.psv
printf 'case_number|date|suspect_killed|suspect_weapon|last_name|first_name|race|gender\n' > ./tables/officers.psv

# read in incidents from incidents.psv
while read incident; do

	# pull basic info from incidents.psv, remove extra whitespace
	case_num=$(echo $incident | cut -d '|' -f 1 | sed 's/^ //g' | sed 's/ $//g')
	date=$(echo $incident | cut -d '|' -f 2 | sed 's/^ //g' | sed 's/ $//g')
	suspect_weapon=$(echo $incident | cut -d '|' -f 5 | sed 's:<br>::g' | sed 's/^ //g' | sed 's/ $//g')

	# determine if suspect was killed
	suspect_status=$(echo $incident | cut -d '|' -f 4)
	if [[ $suspect_status =~ "Deceased" ]]; then
		suspect_killed=true
	else
		suspect_killed=false
	fi

	# pull officers field
	officers=$(echo $incident | cut -d '|' -f 7 | sed -E 's:<br ?/?>::g')

	# make sure officer field is not 'see summary'
	if [[ ! $officers =~ "See Summary" ]]; then

		# iterate over list of officers
		while read officer_line; do

			#check if line is blank (artifact of splitting mechanism)
			if [[ $officer_line =~ ',' ]]; then

				# get officer's last name, remove extra whitespace
				last_name=$(echo $officer_line | cut -d ',' -f 1 | sed 's/^ //g' | sed 's/ $//g')

				#check if name is unknown
				if [[ $last_name =~ "Unknown" ]]; then
					first_name="Unknown"
					race=$(echo $officer_line | cut -d ',' -f 2 | cut -d '/' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					gender=$(echo $officer_line | cut -d ',' -f 2 | cut -d '/' -f 2 | sed 's/^ //g' | sed 's/ $//g')

				elif [[ $last_name =~ " " && $last_name != "St. Clair" ]]; then #check for unusually formatted cases without commas
					last_name=$(echo $last_name | cut -d ' ' -f 2)
					officer_line=$(echo $officer_line | sed 's/ /,/')

					first_name=$(echo $officer_line | cut -d ',' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					race=$(echo $officer_line | cut -d ',' -f 3 | cut -d '/' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					gender=$(echo $officer_line | cut -d ',' -f 3 | cut -d '/' -f 2 | sed 's/^ //g' | sed 's/ $//g')
				
				else
					first_name=$(echo $officer_line | cut -d ',' -f 2 | sed -E 's/^ +//g' | sed -E 's/ +$//g')
					race=$(echo $officer_line | cut -d ',' -f 3 | cut -d '/' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					gender=$(echo $officer_line | cut -d ',' -f 3 | cut -d '/' -f 2 | sed 's/^ //g' | sed 's/ $//g')
				fi

				# print complete line to ./tables/officers.psv
				printf '%s|%s|%s|%s|%s|%s|%s|%s\n' "$case_num" "$date" "$suspect_killed" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> ./tables/officers.psv
			fi

		done < <(echo $officers | sed -E 's:[A-Z]+/[A-Z]:,&\n:g')

	else
		last_name="See Summary"
		first_name="See Summary"
		race="See Summary"
		gender="See Summary"

		# print complete line to ./tables/officers.psv
		printf '%s|%s|%s|%s|%s|%s|%s|%s\n' "$case_num" "$date" "$suspect_killed" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> ./tables/officers.psv
	fi

done < <(csvfix echo -smq -sep '|' -osep '|' ./tables/incidents.psv)

#========================
# suspects.psv
#========================

#prepare tables/suspects.psv
printf 'case_number|date|suspect_weapon|last_name|first_name|race|gender\n' > ./tables/suspects.psv


# read in incidents from incidents.psv
while read incident; do

	# pull basic info from incidents.psv, remove extra whitespace
	case_num=$(echo $incident | cut -d '|' -f 1 | sed 's/^ //g' | sed 's/ $//g')
	date=$(echo $incident | cut -d '|' -f 2 | sed 's/^ //g' | sed 's/ $//g')
	suspect_weapon=$(echo $incident | cut -d '|' -f 5 | sed 's:<br>::g' | sed 's/^ //g' | sed 's/ $//g')

	# pull suspect field
	suspect=$(echo $incident | cut -d '|' -f 6)

	# make sure suspect field is not 'see summary'
	if [[ ! $suspect =~ "See Summary" ]]; then

		# iterate over list of suspects
		while read suspect_line; do

			#check if line is blank (artifact of splitting mechanism)
			if [[ $suspect_line =~ ',' ]]; then

				# get suspect's last name, remove extra whitespace
				last_name=$(echo $suspect_line | cut -d ',' -f 1 | sed 's/^ //g' | sed 's/ $//g')

				#check if name is unknown
				if [[ $last_name =~ "Unknown" ]]; then
					first_name="Unknown"
					race=$(echo $suspect_line | cut -d ',' -f 2 | cut -d '/' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					gender=$(echo $suspect_line | cut -d ',' -f 2 | cut -d '/' -f 2 | sed 's/^ //g' | sed 's/ $//g')

				elif [[ $last_name =~ " " ]]; then #check for unusually formatted cases without commas
					last_name=$(echo $last_name | cut -d ' ' -f 2)
					suspect_line=$(echo $suspect_line | sed 's/ /,/')

					first_name=$(echo $suspect_line | cut -d ',' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					race=$(echo $suspect_line | cut -d ',' -f 3 | cut -d '/' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					gender=$(echo $suspect_line | cut -d ',' -f 3 | cut -d '/' -f 2 | sed 's/^ //g' | sed 's/ $//g')

				else
					first_name=$(echo $suspect_line | cut -d ',' -f 2 | sed 's/^ //g' | sed 's/ $//g')
					race=$(echo $suspect_line | cut -d ',' -f 3 | cut -d '/' -f 1 | sed 's/^ //g' | sed 's/ $//g')
					gender=$(echo $suspect_line | cut -d ',' -f 3 | cut -d '/' -f 2 | sed 's/^ //g' | sed 's/ $//g')
				fi

				# print complete line to ./tables/suspects.psv
				printf '%s|%s|%s|%s|%s|%s|%s\n' "$case_num" "$date" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> ./tables/suspects.psv
			fi

		done < <(echo $suspect | sed -E 's:[A-Z]+/[A-Z]:,&\n:g')

	else
		last_name="See Summary"
		first_name="See Summary"
		race="See Summary"
		gender="See Summary"

		# print complete line to ./tables/suspects.psv
		printf '%s|%s|%s|%s|%s|%s|%s\n' "$case_num" "$date" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> ./tables/suspects.psv
	fi

done < <(csvfix echo -smq -sep '|' -osep '|' ./tables/incidents.psv)











