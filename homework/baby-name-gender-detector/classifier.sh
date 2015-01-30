#set sample location as variable
sample='data-hold/namesample.txt'

#make sure at least one name was passed in
if [[ -n $1 ]]; then

	#iterate through names passed in
	for name in "$@"; do

		#find all matches for current name in sample
		name_matches=$(cat $sample | grep "$name,")

		#set empty vars to count babies by gender
		m_count=0
		f_count=0

		#create vars for final output
		gender="NA"
		pct=0

		#iterate over matches in name_matches
		for row in $name_matches; do
			#get count of babies
			babies=$(echo $row | cut -d ',' -f '3')
			if [[ $row =~ ',M,' ]]; then
				#add to male count
				m_count=$((m_count + babies))
			else
				#add to female count
				f_count=$((f_count + babies))
			fi
		done

		#calculate gender ratios
		total_babies=$((m_count + f_count))

		if [[ ! $total_babies -eq 0 ]]; then
			pct_female=$((100 * f_count / total_babies))

			if [[ $pct_female -ge 50 ]]; then
				gender="F"
				pct=$pct_female
			else
				gender="M"
				pct=$((100 - pct_female))
			fi
		fi

		echo "$name,$gender,$pct,$total_babies"

	done

else #no names were passed in
	echo "Please pass in at least one name"
fi
