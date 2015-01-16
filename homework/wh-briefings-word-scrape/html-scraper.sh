# read in files
cat data-hold/* |\

# parse html
pup '#content p, #content .legacy-para' |\

# convert to lower case
tr [[:upper:]] [[:lower:]] |\

# run word count
grep -oE '[[:alpha:]]{7,}' |\
sort | uniq -c |\
sort -rn | head -n 10
