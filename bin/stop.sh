#!/bin/bash
#
# Stop Script - do not remove the comments. 
# 
# Dude, if you change scripts, pls commit them -- bootstrap will 
# check them out so you so don't need to make AMIs. -- GG.
#
# chkconfig: 0123456 00 00
# description: This script stops the music. 
# Stops the music.

. `dirname $0`/common.sh

date > /tmp/maintenance.txt

echo `date` Entering $0


NOW=$(date +"%M:%S-%m-%d-%Y")
echo "stop the music begin at $NOW" >> /var/log/stop_the_music

# Upload first what's ready to be uploaded.
${LOT49_HOME}/bin/upload.sh -f 2>&1 >> ${LOT49_HOME}/log/upload.log &

service nginx stop
sleep 3

if [ -f /var/lock/lot49.pid ]; 
then
    echo /var/lock/lot49.pid exists
    pid=`cat /var/lock/lot49.pid`
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
fi


/bin/rm -f /var/lock/lot49.pid

${LOT49_HOME}/bin/rotate.sh 2>&1 >> ${LOT49_HOME}/log/upload.log 
${LOT49_HOME}/bin/upload.sh -f 2>&1 >> ${LOT49_HOME}/log/upload.log &

# Kill all the Redis connections that may be held - 
# is this unnecessary or harmful?
${LOT49_HOME}/bin/rediskill.sh &

NOW=$(date +"%M:%S-%m-%d-%Y")
echo "stop the music end at $NOW" >> /var/log/stop_the_music
echo Exiting $0
