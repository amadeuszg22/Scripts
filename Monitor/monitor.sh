#!/bin/bash

host=192.168.0.16
user=pi
pass=Zaq220991

cpu_temp=$(/opt/vc/bin/vcgencmd measure_temp | nawk -F "=" 'NR=='1' {print $2}'|nawk -F "'" 'NR=='1' {print $1}')
free_mem=$(free -m | nawk -F " " 'NR=='2' {print $4}')
used_mem=$(free -m | nawk -F " " 'NR=='2' {print $3}')
cache_mem=$(free -m | nawk -F " " 'NR=='2' {print $7}')
used_disk=$(df -h | nawk -F " " 'NR=='2' {print $3}'|nawk -F "G" 'NR=='1' {print $1}')
free_disk=$(df -h | nawk -F " " 'NR=='2' {print $4}'|nawk -F "G" 'NR=='1' {print $1}')
uptime_const=$(uptime | nawk -F " " 'NR=='1' {print $3}'|nawk -F "," 'NR=='1' {print $1}')
uptime_h=$(uptime | nawk -F " " 'NR=='1' {print $3}'|nawk -F "," 'NR=='1' {print $1}'|nawk -F ":" 'NR=='1' {print $1}')
uptime_m=$(uptime | nawk -F " " 'NR=='1' {print $3}'|nawk -F "," 'NR=='1' {print $1}'|nawk -F ":" 'NR=='1' {print $2}')
uptime=$uptime_h.$uptime_m
load_5=$(uptime | nawk -F " " 'NR=='1' {print $9}' |nawk -F "," 'NR=='1' {print $1}')
load_10=$(uptime | nawk -F " " 'NR=='1' {print $10}' |nawk -F "," 'NR=='1' {print $1}')
load_15=$(uptime | nawk -F " " 'NR=='1' {print $11}' |nawk -F "," 'NR=='1' {print $1}')
wlan0_sig=$(sudo iwconfig wlan0 |nawk -F " " 'NR=='7' {print $4}'|nawk -F "=" 'NR=='1' {print $2}')
wlan0_qa=$( sudo iwconfig wlan0 |nawk -F " " 'NR=='7' {print $2}'|nawk -F "=" 'NR=='1' {print $2}'|nawk -F "/" 'NR=='1' {print $1}')
wlan0_br=$( sudo iwconfig wlan0 |nawk -F " " 'NR=='3' {print $2}'|nawk -F "=" 'NR=='1' {print $2}')
wlan0_statcon=$(sudo iwconfig wlan0 |nawk -F " " 'NR=='1' {print $4}'|nawk -F ":" 'NR=='1' {print $2}')
wlan0_stat=n/a
sysdesc=$(uname -a)
date=$(date +"%Y-%d-%m %H:%M:%S")

if [ "$wlan0_statcon" == '"ama1"' ]; then
        wlan0_stat=up
        wlan0_stat1=1
else
        wlan0_stat=down
        wlan0_stat1=0
fi


echo CPU Temperature $cpu_temp "'C"
echo Free Memory $free_mem M
echo Used Memory $used_mem M
echo Cached Memory $cache_mem M
echo Used Disk $used_disk G
echo Free Disk $free_disk G
echo Uptime $uptime
echo Load 5 $load_5
echo Load 10 $load_10
echo Load 15 $load_15
echo Signal $wlan0_sig dmb
echo Link Quality $wlan0_qa
echo Bit Rate $wlan0_br MB/s
echo Wlan0 status $wlan0_stat
echo System Description $sysdesc
echo Date: $date

echo "INSERT INTO wordpressblog.wp_system (N0, CPU_TEMP, FREE_MEM, USED_MEM, CACHED_MEM, DISK_USED, DISK_FREE, UPTIME, LOAD_5, LOAD_10, LOAD_15, WLAN0_SIG, WLAN0_QA, WLAN0_BR, WLAN0_STATE, SYSDEC, DT) VALUES (NULL, '$cpu_temp', '$free_mem', '$used_mem', '$cache_mem', '$used_disk', '$free_disk', '$uptime', '$load_5', '$load_10', '$load_15', '$wlan0_sig', '$wlan0_qa', '$wlan0_br', '$wlan0_stat1', '$sysdesc', STR_TO_DATE('$date', '%Y-%d-%m %H:%i:%S'));">feed.sql

mysql -u $user --password=$pass -h $host <feed.sql
