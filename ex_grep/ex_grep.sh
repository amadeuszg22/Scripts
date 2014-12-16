#!/bin/bash 
DIR="$1"
FILE="/tmp/grepsh"
i=1
LC=$(ls -1 $DIR|wc -l)
FN=$(ls -1 $DIR > $FILE)

if [ $# -lt 2 ]
  then
    echo "Usage: ex_grep [DIR] [Syntax] "
  exit 2
fi

until [ $i = $LC ]; do
POS=$(cat $FILE |nawk -F ";" 'NR=='$i' {print $1}')

cont=$(grep "$2" $DIR$POS)
if [ "$cont" != "" ];then
echo $DIR$POS
echo -e "\n $cont"
fi
i=$[i + 1]

done
##