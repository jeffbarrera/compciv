# assign input to named variable
username=$1

# create data-hold if it doesn't already exist
mkdir -p ./data-hold

# set filename based on inputed username
file=./data-hold/$username-timeline.csv

# use t to download the tweets in CSV form and save to file
echo "Fetching tweets for $username into $file"
t timeline -n 3200 --csv $username > $file

# Get the count of lines using csvfix and its order subcommand
count=$(csvfix order -f 1 $file | wc -l)

# The timestamp of the tweet is in the field (i.e. column) named, 'Posted at'
# and the oldest tweet is in the last line
oldestDate=$(csvfix order -fn 'Posted at' $file | tail -n 1)

# Echo basic stats about account
echo "Analyzing $count tweets by $username since $oldestDate"

# Get hashtags
echo "Top 10 hashtags by $username"
csvfix  order -ifn -smq -fn 'Text' $file | grep -oiE '#[a-z,0-9,_]+\b' | tr [[:upper:]] [[:lower:]] | sort | uniq -c | sort -rn | head -n 10

# Get retweets
echo "Top 10 retweeted users by $username"
csvfix  order -ifn -smq -fn 'Text' $file | grep -oiE '^RT[[:space:]]?@[a-z,0-9,_]+\b' | tr [[:upper:]] [[:lower:]] | cut -d " " -f 2 | sort | uniq -c | sort -rn | head -n 10

# Get mentioned users
echo "Top 10 mentioned users (not including retweets) by $username"
csvfix  order -ifn -smq -fn 'Text' $file | grep -viE '^[[:punct:]]?RT ' | grep -oiE '@[a-z,0-9,_]+\b' | grep -v "@$username" | tr [[:upper:]] [[:lower:]] | sort | uniq -c | sort -rn | head -n 10

# Get most frequent words
echo "Top 10 tweeted words with 5+ letters by $username"
csvfix  order -ifn -smq -fn 'Text' $file | grep -oE '[[:space:]][^@#][[:alpha:]]{5,}\b' | grep -vE 'http.+\b' | tr [[:upper:]] [[:lower:]] | tr -d "'* " | sort | uniq -c | sort -rn | head -n 10
