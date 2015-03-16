#####################
# SETUP TASKS
#####################

# if it doesn't exist, create data-hold directory
if [[ ! -d ./data-hold ]]; then
	mkdir ./data-hold
fi

#####################
# CITY OF SAN JOSE
#####################

echo "Checking the City of San Jose"

baseDir=./data-hold/san-jose
baseURL=http://sanjoseca.gov

# if it doesn't exist, create data-hold/san-jose directory
if [[ ! -d $baseDir ]]; then
	mkdir $baseDir
fi

# if it doesn't exist, create data-hold/san-jose/current-pdfs directory
if [[ ! -d $baseDir/current-pdfs ]]; then
	mkdir $baseDir/current-pdfs
fi

# if it doesn't exist, create data-hold/san-jose/old-pdfs directory
if [[ ! -d $baseDir/old-pdfs ]]; then
	mkdir $baseDir/old-pdfs
fi

# if there are pdfs in san-jose/current-pdfs, move to san-jose/old-pdfs
if [[ "$(ls -A $baseDir/current-pdfs)" ]]; then
	mv $baseDir/current-pdfs/*.pdf $baseDir/old-pdfs
fi

# download current agenda listing, extract agenda links
while read link; do

	#extract file basename
	filename=$(basename $link).pdf

	# check if pdf has already been downloaded. if not, download the pdf
	if [[ ! -s $baseDir/old-pdfs/$filename ]]; then
		echo "downloading $filename"
		curl -s -L -o $baseDir/current-pdfs/$filename $baseURL/$link 
		sleep 1
	fi

done < <(curl -s http://sanjoseca.gov/index.aspx?NID=3549 | pup '#Section1 .telerik-reTable-2 tr td:first-of-type a:first-of-type attr{href}' | grep -E "[[:alnum:]]")


#####################
# COUNTY OF SANTA CLARA
#####################

echo "Checking the County of Santa Clara"

baseDir=./data-hold/santa-clara-county
baseURL=http://sccgov.iqm2.com/citizens/

# if it doesn't exist, create data-hold/santa-clara-county directory
if [[ ! -d $baseDir ]]; then
	mkdir $baseDir
fi

# if it doesn't exist, create data-hold/santa-clara-county/current-pdfs directory
if [[ ! -d $baseDir/current-pdfs ]]; then
	mkdir $baseDir/current-pdfs
fi

# if it doesn't exist, create data-hold/santa-clara-county/old-pdfs directory
if [[ ! -d $baseDir/old-pdfs ]]; then
	mkdir $baseDir/old-pdfs
fi

# if there are pdfs in santa-clara-county/current-pdfs, move to santa-clara-county/old-pdfs
if [[ "$(ls -A $baseDir/current-pdfs)" ]]; then
	mv $baseDir/current-pdfs/*.pdf $baseDir/old-pdfs
fi

# download current agenda listing, extract agenda links
while read link; do

	#extract file id
	filename=$(echo $link | grep -oE "[[:digit:]]{4}").pdf

	# check if pdf has already been downloaded. if not, download the pdf
	if [[ ! -s $baseDir/old-pdfs/$filename ]]; then
		echo "downloading $filename"
		url=$(echo $link | sed 's/\&amp;/\&/g') # convert &amp; to & for url
		curl -s $baseURL/$url > $baseDir/current-pdfs/$filename # download pdf
	fi

done < <(curl -s -d 'ctl00$ContentPlaceholder1$DepartmentID'="1179" http://sccgov.iqm2.com/Citizens/Calendar.aspx | pup '#ContentPlaceholder1_pnlMeetings .MeetingRow .MeetingLinks div:first-of-type a attr{href}' | grep -E "[[:alnum:]]")







