#!/usr/bin/env bash
URL_BASE="https://catalogo.bn.gov.ar/F/MRLSKKFJCFFTGL85NK3TBEYMBMU4QA31GYN2P5AJYK9569BR2C-48685"
CFILE=numsistemas_photos.csv

get_cookie()
{
	echo	
}

check_error()
{
	if [ $(grep '''console.log("''' $1 | sed 's/console.log("\(.*\)");/\1/g' | wc) ]; then
		echo -n "Website error: " 
		grep '''console.log("''' $1 | sed 's/console.log("\(.*\)");/\1/g'
		echo "Exiting..."
		print_results
		exit 1
	fi
}

get_photolist()
{
DATEMIN=$1
DATEMAX=$2

echo "Getting photo list from $URL_BASE page 1 - Years $DATEMIN - $DATEMAX..."
wget "$URL_BASE?func=short-refine-exec&set_number=016620&request_op=AND&find_code=WRD&request=&filter_code_1=WLN&filter_request_1=&filter_code_4=WFM&filter_request_4=VM&filter_code_5=WSL&filter_request_5=&filter_code_2=WYR&filter_request_2=$DATEMIN&filter_code_3=WYR&filter_request_3=$DATEMAX&name=" -q -O photolist-page1-$DATEMAX-tmp.html

REGS=$(grep '''"pagination-data-top"''' photolist-page1-$DATEMAX-tmp.html | sed 's/.*Registros.*de *\(.*\)<\/strong.*/\1/')
MAXPAGE=$(($REGS/10+$REGS%10))

for NPAGE in $(seq 1 $MAXPAGE); do
	grep "No. Sistema" photolist-page$NPAGE-$DATEMAX-tmp.html | sed 's/.*Sistema: \(.*\)<br.*/\1/' >>$CFILE
	check_error photolist-page$NPAGE-$DATEMAX-tmp.html 
	echo "Getting photo list from page $NPAGE of $MAXPAGE..."
	wget "$URL_BASE?func=short-jump&jump=$(printf "%05u" $NPAGE)1" -q -O photolist-page$(($NPAGE+1))-$DATEMAX-tmp.html
done
}

print_results()
{
	echo "Collected: $(wc -l $CFILE | awk '{print $1}') file numbers"
       	echo "$(sort $CFILE | uniq -d | wc -l) duplicates"
}

get_photolist 1800 1900
get_photolist 1901 1920
get_photolist 1921 1928
get_photolist 1929 1935
get_photolist 1936 1990

print_results
