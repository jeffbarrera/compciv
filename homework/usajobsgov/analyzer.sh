dataDir=./data-hold/scrapes/2015-01-29_2100

#select yearly jobs
yearlyJobs=$(cat $dataDir/*.json | jq '.JobData[] | select(.SalaryBasis == "Per Year")')

# iterate through top jobs
while read line; do
	cleanJob=$(echo $line | sed -E s/^[0-9]+[[:space:]]//)
	echo $yearlyJobs | jq --arg cleanJob "$cleanJob" 'select(.JobTitle == $cleanJob) | .JobTitle'
	# TO DO: TWEAK PREVIOUS LINE TO GET SALARY INFO, THEN FIND MIN/MAX SALARY, PRINT OUT

	echo "$line test"
done < <(echo $yearlyJobs | jq -r '.JobTitle' | sort | uniq -c | sort -rn | head -n 25)
