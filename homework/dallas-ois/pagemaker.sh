# create WWW/projects directory, if it doesn't exist
if [[ ! -d ~/WWW/projects ]]; then
	mkdir -p ~/WWW/projects
fi

# copy dallas-police-shootings directory (contains css,js,font files) to WWW/projects
cp -r ./dallas-police-shootings ~/WWW/projects/

#############################################################
# GENERATE GEOJSON FILE
#############################################################

# store geojson name as var
geojson=~/WWW/projects/dallas-police-shootings/scripts/geojson.js

# add array wrapper before loop
cat > $geojson <<'EOF'
	var incidents = {
		"type": "FeatureCollection",
		"features": [
EOF

# set up template for each feature
read -r -d '' feature <<'EOF'
	{
		"type": "Feature",
	    "properties": {
	        "name": "%s",
	        "popupContent": "<p class='case-num'>Case #%s</p><p>%s</p>"
	    },
	    "geometry": {
	        "type": "Point",
	        "coordinates": [%s, %s]
	    }
	}, 
EOF

# loop over incidents.psv, generate geoJSON code
while read incident; do

	# pull relevant fields from incidents.psv, strip extra whitespace
	case_num=$(echo $incident | cut -d '|' -f 1 | sed 's/^ //g' | sed 's/ $//g' | sed 's/‐/\&ndash;/g') #encode dashes
	location=$(echo $incident | cut -d '|' -f 3 | sed 's/^ //g' | sed 's/ $//g')
	lat=$(echo $incident | cut -d '|' -f 9)
	lng=$(echo $incident | cut -d '|' -f 10)
	narrative=$(echo $incident | cut -d '|' -f 11 | sed 's:“:\&quot;:g' | sed 's:”:\&quot;:g' | sed -r 's:’:\&#39;:g') #encode quotes for HTML

	# print to geoJSON
	printf "$feature" "$location" "$case_num" "$narrative" "$lng" "$lat" >> $geojson

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/incidents.psv)

# close array after loop
cat >> $geojson <<'EOF'
		]
	}
EOF


#############################################################
# GENERATE HTML
#############################################################

# store webpage name as var
webpage=~/WWW/projects/dallas-police-shootings/index.html

# add HTML before loops
cat > $webpage <<'EOF'
	<html>
<head>
	<title>Dallas Police Shootings</title>
    <meta charset="UTF-8">

    <!-- styles -->
    <link href='http://fonts.googleapis.com/css?family=Lato:300,400,700|Libre+Baskerville' rel='stylesheet' type='text/css'>
    <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.css" />
    <link rel="stylesheet" type="text/css" href="style.css" />

    <!-- js -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <script src="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.js"></script>
    <script type="text/javascript" src="scripts/jquery.tablesorter.min.js"></script>
    <script src="scripts/geojson.js"></script>
	<script src="scripts/scripts.js"></script>

</head>
<body>

<div class="preheader">
<h2><span class="jeff">Jeff</span> Barrera</h2>
</div>

<header>

	<nav>
		<h3>Jump to:</h3>
		<ul>
			<li><a href="#map">Map</a></li>
			<li><a href="#incidents">Incidents</a></li>
			<li><a href="#officers">Officers</a></li>
			<li><a href="#suspects">Suspects</a></li>
			<li><a href="#about">About</a></li>
		</ul>
	</nav>

    <h1>Dallas Police Shootings</h1>
    <p class="intro-text">The Dallas Police Department is one of the few departments that publishes records of every officer-involved shooting.</p>
    <p class="intro-text">Here is what their data show:</p>
	
</header>

<div id="map"></div>

<main>
EOF

####################
# incidents table
####################

cat >> $webpage <<'EOF'

<section id="incidents">

<h2>Incidents</h2>
  <table>
  	<thead>
  	<tr>
  		<th>Case Number</th>
  		<th>Date</th>
  		<th>Location</th>
  		<th>Suspect Outcome</th>
  		<th>Suspect Weapon</th>
  		<th>Suspect(s)</th>
  		<th>Officer(s)</th>
  		<th>Grand Jury Disposition</th>
  		<th>Details</th>
  	</tr>
  	</thead>
  	<tbody>
EOF

# set up template for each row
read -r -d '' incident_row <<'EOF'
	<tr id="%s">
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>%s</td>
		<td>
			<a href="#" class="details-link" data-panelid="panel-%s">Show Details</a>
			<div class="details-panel" id="panel-%s">
				%s
			</div>
		</td>
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
	narrative=$(echo $incident | cut -d '|' -f 11 | sed 's:“:\&quot;:g' | sed 's:”:\&quot;:g' | sed -r 's:’:\&#39;:g')

	# print to webpage
	printf "$incident_row" "$case_num" "$case_num" "$date" "$location" "$suspect_outcome" "$suspect_weapon" "$suspects" "$officers" "$jury" "$case_num" "$case_num" "$narrative" >> $webpage

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/incidents.psv)

# close incidents table
cat >> $webpage <<'EOF'
	</tbody>
  	</table>
  	</section>
EOF

####################
# Officers table
####################

cat >> $webpage <<'EOF'

<section id="officers">

<h2>Officers</h2>
  <table>
  	<thead>
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
  	</thead>
  	<tbody>
EOF

# set up template for each row
read -r -d '' officer_row <<'EOF'
	<tr>
		<td><a href="#%s">%s</a></td>
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
	printf "$officer_row" "$case_num" "$case_num" "$date" "$suspect_killed" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> $webpage

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/officers.psv)

# close incidents table
cat >> $webpage <<'EOF'
  	</tbody>
  	</table>
  	</section>
EOF


####################
# suspects table
####################

cat >> $webpage <<'EOF'

<section id="suspects">

<h2>Suspects</h2>
  <table>
  	<thead>
  	<tr>
  		<th>Case Number</th>
  		<th>Date</th>
  		<th>Suspect Weapon</th>
  		<th>Last Name</th>
  		<th>First Name</th>
  		<th>Race</th>
  		<th>Gender</th>
  	</tr>
  	</thead>
  	<tbody>
EOF

# set up template for each row
read -r -d '' suspect_row <<'EOF'
	<tr>
		<td><a href="#%s">%s</a></td>
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
	printf "$suspect_row" "$case_num" "$case_num" "$date" "$suspect_weapon" "$last_name" "$first_name" "$race" "$gender" >> $webpage

done < <(csvfix echo -smq -ifn -sep '|' -osep '|' ./tables/suspects.psv)

# close incidents table
cat >> $webpage <<'EOF'
  	</tbody>
  	</table>
  	</section>
EOF


# footer content
cat >> $webpage <<'EOF'
  	<section id="about">
		<h2>About</h2>

		<p>This is a class project for <a href="http://www.compciv.org/" target="_blank">Computational Methods in the Civic Sphere</a>, a <a href="http://journalism.stanford.edu/" target="_blank">Stanford Journalism</a> course taught by Dan Nguyen.</p>

		<p>The source data are available on the <a href="http://www.dallaspolice.net/ois/ois.html" target="_blank">Dallas Police Department website</a>, but they are broken up in HTML tables spread over several pages. To make the records easier to explore, I scraped the original pages and analyzed the data using bash. The map was created using <a href="http://leafletjs.com" target="_blank">Leaflet.js</a>.</p>

	</section>
</main>

</body>
</html>
EOF