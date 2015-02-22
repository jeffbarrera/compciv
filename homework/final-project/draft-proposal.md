Jeffrey Barrera
Comm 213
Dan Nguyen
2/22/

Final Project Proposal
======================

Last summer, I interned with Working Partnerships USA, a public policy think tank in San Jose. One of their regular projects is to monitor the meeting agendas for various local government agencies, so they know what upcoming issues to pay attention to. This information is very helpful, but collecting it takes up a lot the research team’s time each week. They have to manually visit the website for each government, download the agendas (typically PDFs, though the format varies by agency), reformat and combine them into a MS Word document, and then read through each agenda item and flag important items. 

For my final project, I want to see how much of this agenda-monitoring process I can automate. Focusing on the City of San Jose and the County of Santa Clara (two of the biggest local governments in the region), I aim to write a program that will scrape each website, check if a new agenda has been posted since the script was last run, download the agenda listing, convert it into plain text, parse the file to extract each agenda item, and save it in a more structured format (probably a CSV file). 

I would also like to try automating some of the initial analysis and flagging of key agenda items. Ideally, this would involve obtaining the past year of manually-flagged items from Working Partnerships, and then using these data as a training set for a machine-learning classification algorithm. However, that’s probably beyond the scope of this project, so instead I’ll at least allow users to pass in a list of keywords when running the program, and then calculate a word-count-based relevance score for each agenda item.

For the most part, I think the components of this project should be relatively straightforward. The most difficult part will be parsing the PDFs — these lack nicely structured markup or meta-data, so it will be pretty complicated to tell where each agenda item begins and ends. I’m looking into a few more advanced PDF-to-text tools that try to use the document’s layout to interpret an XML structure, which can then be refined using regular expressions. I’d appreciate any suggestions you have about this (I’ve included links to sample agendas below, in case that’s helpful).

City of San Jose: http://sanjoseca.gov/DocumentCenter/View/40106
County of Santa Clara: http://sccgov.iqm2.com/Citizens/FileOpen.aspx?Type=14&ID=5764&Inline=True
