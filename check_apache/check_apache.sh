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
apstat () {
	status=$(/etc/init.d/apache2 status)
	check=$(echo "$status" |nawk -F " " 'NR=='1' {print $4}')
	echo "$check"
if [ "$check" == "$astate" ]; then
	return 1
else
	return 0
fi
}
hstat (){
checka=$(curl -I $dns | grep HTTP | nawk -F " " 'NR=='1' {print $2}')
}
lstat () {
checkb=$(cat /proc/loadavg | nawk -F " " 'NR=='1' {print $1}')
checkb1=$(printf '%.0f\n' $checkb) 
}

apstat
ret=$?
hstat
lstat

if [ "$ret" == 1 ] || [ "$checka" != "$httpc" ] || [ "$checkb1" -ge "$maxl" ]; then
echo "$host:$date-Critical!:$status restart in progress host $dns is $checka (LOAD:$checkb)"
echo "$host:$date-Critical!:$status Restart in progress host $dns is $checka (LOAD:$checkb)">>$ldir
null=$(/etc/init.d/apache2 restart > /dev/null 2>&1)
sleep 2

apstat
ret=$?
hstat
lstat
	
	if [ "$ret" == "1" ] || [ "$checka" != "$httpc" ] || [ "$checkb1" -ge "$maxl" ]; then
	echo "$host:$date-Critical!:$status After restart retry host $dns is $checka (LOAD:$checkb)"
	echo "$host:$date-Critical!:$status After restart retry host $dns is $checka (LOAD:$checkb)">>$ldir
        echo "$host:$date-Critical!:$status After restart retry host $dns is $checka (LOAD:$checkb)"| mail -s "$host:Apache Notifier Critical" $rcpt #ama@thedigitals.pl -r ama@thedigitals.pl
	exit 2
	else
	echo "$host:$date-OK:$status After restart retry host $dns is $checka (LOAD:$checkb)"
	echo "$host:$date-OK:$status After restart retry host $dns is $checka (LOAD:$checkb)">>$ldir
	echo "$host:$date-OK:$status After restart retry host $dns is $checka (LOAD:$checkb)"| mail -s "$host:Apache Notifier OK" $rcpt  #ama@thedigitals.pl -r ama@thedigitals.pl
	exit 0
	fi

exit 2
else
echo "$host:$date-OK:$status host $dns is $checka (LOAD:$checkb)"
echo "$host:$date-OK:$status host $dns is $checka (LOAD:$checkb)">>$ldir
exit 0
fi
