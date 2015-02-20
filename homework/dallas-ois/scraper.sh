#create data-hold and data-hold/pdfs subdirectories, if don't already exist
if [[ ! -d ./data-hold ]]; then
	mkdir ./data-hold
fi
if [[ ! -d ./data-hold/pdfs ]]; then
      mkdir ./data-hold/pdfs
fi

#set base url for dallas police website
base_url=http://www.dallaspolice.net

# create function to download pdf given relative url
function downloadPDF () {
        pdf_name=$(basename $1)
        curl -o ./data-hold/pdfs/$pdf_name $base_url/$1
}

#curl current ois page
curl -o ./data-hold/ois_current.html $base_url/ois/ois.html

# extract list of and download pdfs from current page
while read pdf; do
	downloadPDF $pdf
done < <(cat ./data-hold/ois_current.html | pup 'table table tr td a attr{href}')

# extract urls and download archive pages
while read url; do
	name=$(basename $url)
	curl -o ./data-hold/$name $base_url/$url

	# extract and download list of PDFs
	while read pdf; do
		downloadPDF $pdf
	done < <(cat ./data-hold/$name | pup 'table table tr td a attr{href}')

done < <(cat data-hold/ois_current.html | pup '#help li:nth-child(n+2) a attr{href}')

