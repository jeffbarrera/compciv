# convert pdf to text
pdftotext data-hold/ca.html data-hold/ca.txt -layout |\

cat data-hold/ca.txt |\
# get rows of inmates
grep 'Living' |\
# grep up to ethnic code
grep -oE "[[:alpha:]]+[[:space:]]+[[:alpha:]]+[[:space:]]+[[:alpha:]]+[[:space:]]+[[:upper:]]{3,3}" |\
# get last three characters
grep -o '...$'
