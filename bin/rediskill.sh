#!/bin/bash

echo `date` Entering $0
. `dirname $0`/common.sh

if [ "$1" = "all" ];
then
grep_for=.
else
grep_for=`hostname | cut -d'-' -f2,3,4,5 --output-delimiter=.`
echo My IP is $grep_for
fi

i=0
echo Getting client list
for line in `echo CLIENT LIST | redis-cli -h user10.${SHORT_REGION}.opendsp.com | grep $grep_for | cut -f1 -d' ' | cut -f2 -d=`;
do 
echo Killing $line

${LOT49_HOME}/bin/timeout.sh -t 2 ${LOT49_HOME}/bin/rediskillclient.sh user10.${SHORT_REGION}.opendsp.com $line
((i++))
done;

echo Killed $i connections to user10


echo Getting client list
i=0
for line in `echo CLIENT LIST | redis-cli -h pace.${SHORT_REGION}.opendsp.com | grep $grep_for | cut -f1 -d' ' | cut -f2 -d=`;
do 
echo Killing $line

${LOT49_HOME}/bin/timeout.sh -t 2 ${LOT49_HOME}/bin/redisclientkill.sh pace.${SHORT_REGION}.opendsp.com $line

((i++))
done;

echo Killed $i connections to pace
echo Exiting $0