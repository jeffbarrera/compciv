Agenda Checker
=====================================
By Jeffrey Barrera

Overview
--------
This is a program that downloads meeting agendas for the San Jose City Council and the Santa Clara County Board of Supervisors, builds a CSV file containing each agenda item, and (optionally) ranks the items in the CSV file according to a set of inputted search terms.

It was created as a final project for [Comm 213: Computational Methods in the Civic Sphere](http://www.compciv.org), a Stanford Journalism course taught by Dan Nguyen.

Usage
--------
To use, run the `agenda-checker.sh` script - this program calls the other scripts as needed. If you include a list of quoted, space-separated search terms, the script will use these to generate a relevance score for each agenda item (see the **Relevance Scoring** section below for details). The script will generate a date-stamped CSV file in the `tables` subdirectory.

Notes
--------
* Agencies often post agendas for closed sessions, special events, and commission meetings on the same webpages. These documents do not follow the format of regular agendas, so are ignored by the parser script. When such an atypical document is encountered, the script will print out a message to review the document manually.
* This program uses the Python [PDFminer](http://www.unixuser.org/~euske/python/pdfminer/) package and its pdf2txt utility to extract content from the San Jose agenda PDFs. The script will therefore attempt to automatically install PDFminer.
* If the program is run repeatedly on the same day, it will overwrite any CSV files with the same date-stamp filename.

Relevance Scoring
-----------------
If you include a list of quoted, space-separated, case-insensitive terms as arguments when running `agenda-checker.sh`, the script will estimate a relevance score for each agenda item. This score is calculated as follows:
* Regular agenda items begin with a relevance score of 1. 
* On the assumption that ceremonial and routine items are less likely to be relevant, items listed under the consent calendar, ceremonial, and closing headings begin with a relevance score of 0.
* For each mention of a term, the item's score is increased by 2.

Usage example:

	bash agenda-checker.sh "Budget" "public health"


CHECK WHAT ELSE SHOULD BE INCLUDED