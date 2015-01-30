#create data-hold subdirectory, if doesn't already exist
if [[ ! -d ./data-hold ]]; then
	echo "creating data hold directory"
	mkdir ./data-hold
fi
#create data-hold/scrapes subdirectory, if doesn't already exist
if [[ ! -d ./data-hold/scrapes ]]; then
        echo "creating data-hold/scrapes directory"
        mkdir ./data-hold/scrapes
fi

# download OccupationalSeries.xml
if [[ ! -a ./data-hold/OccupationalSeries.xml ]]; then
	echo "downloading OccupationalSeries.xml"
	curl -o ./data-hold/OccupationalSeries.xml http://stash.compciv.org/usajobs.gov/OccupationalSeries.xml
fi

# extract list of JobFamily values
jobFamilies=$(cat ./data-hold/OccupationalSeries.xml | hxselect -c -s '\n' CodeList#OccupationSeriesFamily ValidValue JobFamily)

#set endpoint as var
endpoint=https://data.usajobs.gov/api/jobs

# create time-stamped directory
dirName=$(date '+%Y-%m-%d_%H00')
mkdir ./data-hold/scrapes/$dirName

#iterate through jobFamilies values
for jobCode in $jobFamilies; do

    # curl 1st page
	initialPage=$(curl $endpoint?series=$jobCode)
	echo $initialPage > ./data-hold/scrapes/$dirName/$jobCode-1.json

	# find number of pages
	numPages=$(echo $initialPage | jq -r '.Pages')
	echo "num pages: $numPages"

	# curl remaining pages, if any
	if [[ $numPages -ge 2 ]]; then
        for i in $(seq 2 $numPages); do
            activeURL="$endpoint?series=$jobCode&Page=$i"
            echo "$activeURL"
            curl -o ./data-hold/scrapes/$dirName/$jobCode-$i.json $activeURL
        done
	fi
done
