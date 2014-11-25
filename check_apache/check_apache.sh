#!/bin/bash
host=$(hostname)
#echo $host
date=$(date +"%m-%d-%Y %T")
status=$(/etc/init.d/apache2 status)
check=$(echo "$status" |nawk -F " " 'NR=='1' {print $4}')
checka=$(curl -I karlik.hyundai.pl| grep HTTP | nawk -F " " 'NR=='1' {print $2}')

if [ "$check" == "not" ] || [ "$checka" != "200" ]; then
echo "$host:Critical!:$status restart in progress"
echo "$host:$date-Critical!:$status Restart in progress">>/tmp/check_apache.log
null=$(/etc/init.d/apache2 restart > /dev/null 2>&1)
sleep 2
srv=$(/etc/init.d/apache2 status)
check2=$(echo "$srv" |nawk -F " " 'NR=='1' {print $4}')
check2a=$(curl -I karlik.hyundai.pl| grep HTTP | nawk -F " " 'NR=='1' {print $2}')
#echo "$check2"
	
	if [ "$check2" == "not" ] || [ "$check2a" != "200" ]; then
	echo "$host:Critical!:$srv After restart retry"
	echo "$host:date-Critical!:$srv After restart retry">>/tmp/check_apache.log
        echo "$host:$date-Critical!:$srv After restart retry"| mail -s "$host:Apache Notifier Critical" ama@thedigitals.pl dpacholczyk@gmail.com #ama@thedigitals.pl -r ama@thedigitals.pl
	exit 2
	else
	echo "$host:OK:$srv After restart retry"
	echo "$host:$date-OK:$srv After restart retry">>/tmp/check_apache.log
	echo "$host:$date-OK:$srv After restart retry"| mail -s "$host:Apache Notifier OK" ama@thedigitals.pl dpacholczyk@gmail.com  #ama@thedigitals.pl -r ama@thedigitals.pl
	exit 0
	fi

exit 2
else
echo "$host:OK:$status"
echo "$host:$date-OK:$status">>/tmp/check_apache.log
exit 0
fi
