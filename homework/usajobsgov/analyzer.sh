#check if argument was passed in
if [[ -z $1 ]]; then
    echo "Please enter a subdirectory name"

else # proceed with argument that was passed in

	# check if argument in a valid directory
	dataDir=./data-hold/scrapes/$1
	if [[ ! -d $dataDir ]];then
	    echo "Please enter a valid directory name"

	else # proceed using entered directory

		#select yearly jobs
		yearlyJobs=$(cat $dataDir/*.json | jq '.JobData[] | select(.SalaryBasis == "Per Year")')

		# iterate through top jobs
		while read line; do
	        cleanJob=$(echo $line | sed -E s/^[0-9]+[[:space:]]//)

	        # find highest salary for current job
	        salaryHigh=0
	        while read line; do
	            if [[ $line -gt $salaryHigh ]]; then
	                salaryHigh=$line
	            fi
	        done < <(echo $yearlyJobs | jq -r --arg cleanJob "$cleanJob" 'select(.JobTitle == $cleanJob) | .SalaryMax' | tr -d '$,' | cut -d '.' -f 1)

	         # find lowest salary for current job
	        salaryLow=$(echo $yearlyJobs | jq -r --arg cleanJob "$cleanJob" 'select(.JobTitle == $cleanJob) | .SalaryMin' | tr -d '$,' | cut -d '.' -f 1 | head -n 1)

	        while read line; do
	            if [[ $line -lt $salaryLow ]]; then
	                salaryLow=$line
	            fi
	        done < <(echo $yearlyJobs | jq -r --arg cleanJob "$cleanJob" 'select(.JobTitle == $cleanJob) | .SalaryMin' | tr -d '$,' | cut -d '.' -f 1)

		echo "$cleanJob|$salaryLow.00|$salaryHigh.00"

		done < <(echo $yearlyJobs | jq -r '.JobTitle' | sort | uniq -c | sort -rn | head -n 25)

	fi #close valid directory condition
fi #close valid argument condition
