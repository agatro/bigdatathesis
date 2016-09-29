#!/bin/bash

# Return error if arg is missing
if [ ! "$1" ]; then
  echo "Please point towards journal CSV file to be processed"
  exit 1
fi

if [ ! "$2" ]; then
  echo "Please point towards output folder"
  exit 1
fi

if [ ! "$3" ]; then
  echo "Please indicate YYYY-MM-DD from which you want to search (MM-DD optional)"
  exit 1
fi

if [ ! "$4" ]; then
  echo "Please indicate YYYY-MM-DD until which you want to search (MM-DD optional)"
  exit 1
fi
LOOP=$(cat $1 | wc -l)

for i in $(eval echo {2..$LOOP}); # skip header
  do 
  PRINT=$(csvcut -c "print issn" $1 | sed -n "$(echo $i)p")
  ONLINE=$(csvcut -c "online issn" $1 | sed -n "$(echo $i)p")
  
  if [ ! "$PRINT" -a ! "$ONLINE" ]; then
  		echo 'No ISSN for row $i'
  		exit 1
  fi

  if [ "$ONLINE" = '""' ]; then
  	getpapers --api crossref -o "$2" --filter "type:journal-article,issn:$PRINT,from-pub-date:$3,until-pub-date:$4"
  	echo "Just downloaded CrossRef metadata for ISSN $PRINT into folder $2"
  elif [ "$PRINT" = '""' ]; then
  	getpapers --api crossref -o "$2" --filter "type:journal-article,issn:$ONLINE,from-pub-date:$3,until-pub-date:$4"
  	echo "Just downloaded CrossRef metadata for ISSN $ONLINE into folder $2"
  else
 	getpapers --api crossref -o $2 --filter "issn:$ONLINE,issn:$PRINT,type:journal-article,from-pub-date:$3,until-pub-date:$4"
  	echo "Just downloaded CrossRef metadata for ISSN $PRINT and $ONLINE into folder $2"
  fi

done
