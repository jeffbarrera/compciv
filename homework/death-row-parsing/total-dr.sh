# CA
ca=$(bash ca-dr.sh)
for LINE in $ca; do
	echo "CA,$LINE" |\
	sed 's/WHI/White/' |\
	sed 's/BLA/Black/' |\
	sed 's/HIS/Hispanic/' |\
	sed 's/OTH/Other/'
done

# FL
fl=$(bash fl-dr.sh)
for LINE in $fl; do
        echo "FL,$LINE" |\
        sed 's/WM/White/' |\
	sed 's/WF/White/' |\
        sed 's/BM/Black/' |\
	sed 's/BF/Black/' |\
        sed 's/HM/Hispanic/' |\
	sed 's/HF/Hispanic/' |\
        sed 's/OM/Other/'
done

# TX
tx=$(bash tx-dr.sh)
for LINE in $tx; do
        echo "TX,$LINE"
done




