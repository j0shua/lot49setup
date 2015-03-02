#!/bin/bash

if [ -f /var/lock/lot49.pid ]; 
then
    echo /var/lock/lot49.pid exists
    pid=`cat /var/lock/lot49.pid`
    echo Started process $pid
else
    echo /var/lock/lot49.pid does not exist
    echo Looking in processes:
    ps auxwww |grep com.enremmeta.rtb.Bidder
    pid=`ps auxwww |grep com.enremmeta.rtb.Bidder|grep -v grep | sed -e 's/ \+/\t/g' | cut -f2`
    if [ "$pid" = "" ]; then
	echo "No process found."
    fi
fi

kill_try_count=0
if [ "$pid" != "" ]; then
  echo Killing $pid
  # 15 is SIGTERM
  kill -15 $pid
  pid_exist=`ps -p $pid | grep $pid`
  while [ "$pid_exist" != "" ];
  do
    echo Waiting for $pid to die, try $kill_try_count
    sleep 1
    pid_exist=`ps -p $pid | grep $pid`
    kill_try_count=$(($kill_try_count+1))
    if [ "$kill_try_count" = "15" ]; then
	# 9 is SIGKILL
	echo "Killing -9"
	kill -9 $pid
    fi
  done
  
  /bin/rm -f /var/lock/lot49.pid
#  /bin/rm -f /opt/lot49/log/nohup.out
fi 
