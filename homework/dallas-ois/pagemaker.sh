# create WWW/projects directory, if it doesn't exist
if [[ ! -d ~/WWW/projects ]]; then
	mkdir -p ~/WWW/projects
fi

# store webpage name as var
webpage=~/WWW/projects/dallas-shootings.html

# add HTML before loops
cat > $webpage <<'EOF'
  <html>
  <head>
    <title>Dallas Police Shootings</title>
    <meta charset="UTF-8">
  </head>
  <body>
    <h1>Dallas Police Shootings</h1>
EOF

####################
# incidents table
####################

cat >> $webpage <<'EOF'

<h2>Incidents</h2>
  <table>
  	<tr>
  		<th>Case Number</th>
  		<th>Date</th>
  		<th>Location</th>
  		<th>Suspect Outcome</th>
  		<th>Suspect Weapon</th>
  		<th>Suspect(s)</th>
  		<th>Officer(s)</th>
  		<th>Grand Jury Dispositon</th>
  	</tr>
EOF

# set up template for each row
read -r -d '' incident_row <<'EOF'
	<tr>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
	</tr>  
EOF

# read in incidents from incidents.psv
while read incident; do

	# pull relevant fields from incidents.psv, strip extra whitespace
	case_num=$(echo $incident | cut -d '|' -f 1 | sed 's/^ //g' | sed 's/ $//g')
	date=$(echo $incident | cut -d '|' -f 2 | sed 's/^ //g' | sed 's/ $//g')
	location=$(echo $incident | cut -d '|' -f 3 | sed 's/^ //g' | sed 's/ $//g')
	suspect_outcome=$(echo $incident | cut -d '|' -f 4 | sed 's/^ //g' | sed 's/ $//g')
	suspect_weapon=$(echo $incident | cut -d '|' -f 5 | sed 's/^ //g' | sed 's/ $//g')
	suspects=$(echo $incident | cut -d '|' -f 6 | sed 's/^ //g' | sed 's/ $//g')
	officers=$(echo $incident | cut -d '|' -f 7 | sed 's/^ //g' | sed 's/ $//g')
	jury=$(echo $incident | cut -d '|' -f 8 | sed 's/^ //g' | sed 's/ $//g')

	# print to webpage
	printf "$incident_row" "$case_num" "$date" "$location" "$suspect_outcome" "$suspect_weapon" "$suspects" "$officers" "$jury" >> $webpage

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/incidents.psv)

# close incidents table
cat >> $webpage <<'EOF'
  </table>
EOF

####################
# Officers table
####################

cat >> $webpage <<'EOF'

<h2>Officers</h2>
  <table>
  	<tr>
  		<th>Case Number</th>
  		<th>Date</th>
  		<th>Suspect Killed</th>
  		<th>Suspect Weapon</th>
  		<th>Last Name</th>
  		<th>First Name</th>
  		<th>Race</th>
  		<th>Gender</th>
  	</tr>
EOF

# set up template for each row
read -r -d '' officer_row <<'EOF'
	<tr>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
	</tr>  
EOF

# read in officers from officers.psv
while read officer; do

	# pull relevant fields from officers.psv
	case_num=$(echo $officer | cut -d '|' -f 1)
	date=$(echo $officer | cut -d '|' -f 2)
	suspect_killed=$(echo $officer | cut -d '|' -f 3 | sed 's/false/No/' | sed 's/true/Yes/')
	suspect_weapon=$(echo $officer | cut -d '|' -f 4)
	last_name=$(echo $officer | cut -d '|' -f 5)
	first_name=$(echo $officer | cut -d '|' -f 6)
	race=$(echo $officer | cut -d '|' -f 7 |\
		sed 's/L/Latino/' | sed 's/W/White/' | sed 's/B/Black/' | sed 's/NA/Native American/' | sed -E 's/A$/Asian/')
	gender=$(echo $officer | cut -d '|' -f 8 | sed 's/M/Male/' | sed 's/F/Female/')

	# print to webpage
	printf "$officer_row" "$case_num" "$date" "$suspect_killed" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> $webpage

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/officers.psv)

# close incidents table
cat >> $webpage <<'EOF'
  </table>
EOF


####################
# suspects table
####################

cat >> $webpage <<'EOF'

<h2>Suspects</h2>
  <table>
  	<tr>
  		<th>Case Number</th>
  		<th>Date</th>
  		<th>Suspect Weapon</th>
  		<th>Last Name</th>
  		<th>First Name</th>
  		<th>Race</th>
  		<th>Gender</th>
  	</tr>
EOF

# set up template for each row
read -r -d '' suspect_row <<'EOF'
	<tr>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
	</tr>  
EOF

# read in suspects from suspects.psv
while read suspect; do

	# pull relevant fields from suspects.psv
	case_num=$(echo $suspect | cut -d '|' -f 1)
	date=$(echo $suspect | cut -d '|' -f 2)
	suspect_weapon=$(echo $suspect | cut -d '|' -f 3)
	last_name=$(echo $suspect | cut -d '|' -f 4)
	first_name=$(echo $suspect | cut -d '|' -f 5)
	race=$(echo $suspect | cut -d '|' -f 6 |\
		sed 's/L/Latino/' | sed 's/W/White/' | sed 's/B/Black/' | sed 's/NA/Native American/' | sed -E 's/A$/Asian/')
	gender=$(echo $suspect | cut -d '|' -f 7 | sed 's/M/Male/' | sed 's/F/Female/')

	# print to webpage
	printf "$suspect_row" "$case_num" "$date" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> $webpage

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/suspects.psv)

# close incidents table
cat >> $webpage <<'EOF'
  </table>
EOF


# close html tags
cat >> $webpage <<'EOF'
  </body>
  </html>
EOF