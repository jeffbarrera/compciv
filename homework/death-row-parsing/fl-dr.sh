#open fl current
cat data-hold/fl_current.html |\
# get race/gender code for each offender (exclude header row)
pup 'tr:nth-of-type(n+2) td:nth-of-type(3) text{}' |\
# filter out empty lines
grep -oE "[[:alpha:]][[:alpha:]]"

#open fl executions current
cat data-hold/fl_exec_current.html |\
# get race/gender code for each offender
pup 'td:nth-of-type(3) text{}'

#open fl executions old
cat data-hold/fl_exec_old.html |\
# get race/gender code for each offender
pup 'td:nth-of-type(3) text{}'
