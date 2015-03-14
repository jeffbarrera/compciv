import csv
with open('./tables/2015-03-14.csv', 'rb') as csvfile:
	spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
	for row in spamreader:
		print '|,| '.join(row)
		print "---------------------"