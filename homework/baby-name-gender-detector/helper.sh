mkdir -p ./data-hold
cd data-hold
# download the file into names.zip
curl -o names.zip http://stash.compciv.org/ssa_baby_names/names.zip
# unzip directly into standard output and convert via dos2unix
unzip -p names.zip yob1973.txt yob2013.txt | dos2unix > namesample.txt
# move back up to homework/baby-name-gender-detector
cd ..
