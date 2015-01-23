# open tx current
cat data-hold/tx_current.html |\
# get race for each inmate
pup 'td:nth-of-type(7) {}'

# open tx old
cat data-hold/tx_old.html |\
# get race for each offender
pup 'td:nth-of-type(4) text{}'
