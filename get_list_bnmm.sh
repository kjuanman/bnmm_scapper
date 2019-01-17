#!/usr/bin/env bash
URL_BASE="https://catalogo.bn.gov.ar/F/MRLSKKFJCFFTGL85NK3TBEYMBMU4QA31GYN2P5AJYK9569BR2C-19122"

get_cookie()
{
	echo	
}

check_error()
{
	if [ ! $(grep '''console.log("''' $1 | sed 's/console.log("\(.*\)");/\1/g' | wc -w) ]; then
		echo -n "Website error: " 
		grep '''console.log("''' $1 | sed 's/console.log("\(.*\)");/\1/g'
		echo "Exiting..."
		print_results
		exit 1
	fi
}

get_list()
{
TYPE=$1
SETNUMBER=$2
FILTER=$3
DATEMIN=$4
DATEMAX=$5
CFILE=numsistemas_$TYPE.csv

echo "Getting $TYPE list from $URL_BASE page 1 - Years $DATEMIN - $DATEMAX..."
wget "$URL_BASE?func=short-refine-exec&set_number=$SETNUMBER&request_op=AND&find_code=WRD&request=&filter_code_1=WLN&filter_request_1=&filter_code_4=WFM&filter_request_4=$FILTER&filter_code_5=WSL&filter_request_5=&filter_code_2=WYR&filter_request_2=$DATEMIN&filter_code_3=WYR&filter_request_3=$DATEMAX&name=" -q -O ${TYPE}list-page1-$DATEMAX-tmp.html

REGS=$(grep '''"pagination-data-top"''' ${TYPE}list-page1-$DATEMAX-tmp.html | sed 's/.*Registros.*de *\(.*\)<\/strong.*/\1/')
MAXPAGE=$(($REGS/10+$REGS%10))

for NPAGE in $(seq 1 $MAXPAGE); do
	grep "No. Sistema" ${TYPE}list-page$NPAGE-$DATEMAX-tmp.html | sed 's/.*Sistema: \(.*\)<br.*/\1/' >>$CFILE
	check_error ${TYPE}list-page$NPAGE-$DATEMAX-tmp.html 
	echo "Getting $TYPE list from page $NPAGE of $MAXPAGE..."
	wget "$URL_BASE?func=short-jump&jump=$(printf "%05u" $NPAGE)1" -q -O ${TYPE}list-page$(($NPAGE+1))-$DATEMAX-tmp.html
done
}

get_maplist()
{
get_list map 017344 MP 1500 1990
}

get_photolist()
{
PHOTOSETNUMBER=016620
get_list photo $PHOTOSETNUMBER VM 1800 1900
get_list photo $PHOTOSETNUMBER VM 1901 1920
get_list photo $PHOTOSETNUMBER VM 1921 1928
get_list photo $PHOTOSETNUMBER VM 1929 1935
get_list photo $PHOTOSETNUMBER VM 1936 1990
}

get_newslist()
{
get_list newspaper_magazine "func=short-sort&set_number=017720&sort_option=01---A03---A"
}

print_results()
{
	echo "Collected: $(wc -l $CFILE | awk '{print $1}') file numbers"
       	echo "$(sort $CFILE | uniq -d | wc -l) duplicates"
}

#get_photolist
get_maplist 
#get_newslist 

print_results
