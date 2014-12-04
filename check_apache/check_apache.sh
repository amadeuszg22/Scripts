#!/bin/bash
#config
dns="http://edgetechnology.pl" #host to check
maxl="15" #max accepted load
httpc="200" #http code given by server
astate="not" # accepted state is not or empty. not if you want to check if apache is down epty if ypu want tocheck if is up 
rcpt="ama@thedigitals.pl" #mail notification rcpt
ldir="/tmp/check_apache.log"

host=$(hostname)
date=$(date +"%m-%d-%Y %T")
status=$(/etc/init.d/apache2 status)
check=$(echo "$status" |nawk -F " " 'NR=='1' {print $4}')
checka=$(curl -I $dns | grep HTTP | nawk -F " " 'NR=='1' {print $2}')
checkb=$(cat /proc/loadavg | nawk -F " " 'NR=='1' {print $1}')
checkb1=$(printf '%.0f\n' $checkb) 
#echo $checkb
#echo $checkb1

if [ "$check" == "$astate" ] || [ "$checka" != "$httpc" ] || [ "$checkb1" -ge "$maxl" ]; then
echo "$host:$date-Critical!:$status restart in progress host $dns is $checka (LOAD:$checkb)"
echo "$host:$date-Critical!:$status Restart in progress host $dns is $checka (LOAD:$checkb)">>$ldir
null=$(/etc/init.d/apache2 restart > /dev/null 2>&1)
sleep 2
srv=$(/etc/init.d/apache2 status)
check2=$(echo "$srv" |nawk -F " " 'NR=='1' {print $4}')
check2a=$(curl -I $dns | grep HTTP | nawk -F " " 'NR=='1' {print $2}')
check2b=$(cat /proc/loadavg | nawk -F " " 'NR=='1' {print $1}')
check2b1=$(printf '%.0f\n' $check2b)
#echo $check2b
#echo $check2b1
#echo "$check2"
	
	if [ "$check2" == "$astate" ] || [ "$check2a" != "$httpc" ] || [ "$check2b1" -ge "$maxl" ]; then
	echo "$host:$date-Critical!:$srv After restart retry host $dns is $check2a (LOAD:$check2b)"
	echo "$host:$date-Critical!:$srv After restart retry host $dns is $check2a (LOAD:$check2b)">>$ldir
        echo "$host:$date-Critical!:$srv After restart retry host $dns is $check2a (LOAD:$check2b)"| mail -s "$host:Apache Notifier Critical" $rcpt #ama@thedigitals.pl -r ama@thedigitals.pl
	exit 2
	else
	echo "$host:$date-OK:$srv After restart retry host $dns is $check2a (LOAD:$check2b)"
	echo "$host:$date-OK:$srv After restart retry host $dns is $check2a (LOAD:$check2b)">>$ldir
	echo "$host:$date-OK:$srv After restart retry host $dns is $check2a (LOAD:$check2b)"| mail -s "$host:Apache Notifier OK" $rcpt  #ama@thedigitals.pl -r ama@thedigitals.pl
	exit 0
	fi

exit 2
else
echo "$host:$date-OK:$status host $dns is $checka (LOAD:$checkb)"
echo "$host:$date-OK:$status host $dns is $checka (LOAD:$checkb)">>$ldir
exit 0
fi
