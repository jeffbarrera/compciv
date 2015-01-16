for file in $(ls data-hold/*.TXT)
do
	cat $file | sort -n -r -t ',' -k 5 | head -n 1
done
