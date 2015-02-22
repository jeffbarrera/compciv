# create data-hold/geocodes, if it doesn't exist
if [[ ! -d ./data-hold/geocodes ]]; then
      mkdir ./data-hold/geocodes
fi

# create tables directory, if it doesn't exist
if [[ ! -d ./tables ]]; then
      mkdir ./tables
fi

# extract addresses from html files, exclude broken address, save to addresses.txt
cat data-hold/*.html | pup 'table table tr td:nth-child(3) text{}' |\
grep -E '^[[:space:]]+?[[:digit:]]+' | grep -v '2120' > ./data-hold/geocodes/addresses.txt

#append clean version of weirdly formatted address
echo "2120 52nd Street" >> ./data-hold/geocodes/addresses.txt

#prepare tables/geocodes.psv, if it doesn't exist yet
if [[ ! -s ./tables/geocodes.psv ]]; then
	printf 'location|latitude|longitude\n' > ./tables/geocodes.psv
fi

# geocode each address
cat ./data-hold/geocodes/addresses.txt | while read address; do
	address_url=$(echo $address | tr -d '[:punct:]' | tr ' ' '+')
	address_slug=$(echo $address | sed s/[^A-z0-9]//g)
	address_filename="data-hold/geocodes/$address_slug.json"

	# if file exists and is non-zero then we don't need to download it
	if [[ -s "$address_filename" ]]; then
  		echo "Already downloaded $address_filename"
	else
  		echo "Geocoding $address"
		curl "https://maps.googleapis.com/maps/api/geocode/json?address=$address_url+Dallas+TX" > $address_filename
		
		# extract lat and lng from downloaded json
		lat_long=$(cat $address_filename | jq '.results[0] .geometry .location')
		lat=$(echo $lat_long | jq '.lat')
		lng=$(echo $lat_long | jq '.lng')

		#write results to tables/geocodes.psv
		printf '%s|%s|%s\n' "$address" "$lat" "$lng" >> ./tables/geocodes.psv

		# sleep to avoid hammering geocoding server
		sleep 1
	fi
done
