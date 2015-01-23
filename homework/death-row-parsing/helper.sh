# create data-hold subdirectory
mkdir data-hold
cd data-hold

# download texas files
curl http://www.tdcj.state.tx.us/death_row/dr_offenders_on_dr.html \
-o tx_current.html
curl http://www.tdcj.state.tx.us/death_row/dr_list_all_dr_1923-1973.html \
-o tx_old.html

# download florida files
curl http://www.dc.state.fl.us/activeinmates/deathrowroster.asp \
-o fl_current.html
curl http://www.dc.state.fl.us/oth/deathrow/execlist.html \
-o fl_exec_current.html
curl http://www.dc.state.fl.us/oth/deathrow/execlist2.html \
-o fl_exec_old.html

# download california file
curl http://www.cdcr.ca.gov/capital_punishment/docs/condemnedinmatelistsecure.pdf \
-o ca.html

# change back to assignment directory
cd ..
