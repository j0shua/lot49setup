#!/bin/bash

echo `date` Entering $0
. `dirname $0`/common.sh

echo Connecting to ${BUDGET_CACHE}
export timeNow=`date +"%s"`
for ts in `echo 'KEYS budget_*' | redis-cli -h ${BUDGET_CACHE} | cut -f2 -d' '| cut -d_ -f2`;
do 
echo For $ts
export budget=`echo GET budget_$ts | redis-cli -h ${BUDGET_CACHE}`
#echo Micros: $budget
export budget=`echo ${budget}/1000000 | bc`
#echo \$: $budget
export endsOn=`echo GET endsOn_$ts | redis-cli -h ${BUDGET_CACHE}`
#echo Ends on: $endsOn
echo Budget \$$budget until $endsOn
if [ "$1" = "-v" ]; then
  export pacingLogKey="pacingLog_$ts"
  export log=`echo ZREVRANGE $pacingLogKey 0 -10 | redis-cli -h ${BUDGET_CACHE}`
  echo Last pacing messages:
  echo $log
fi 
echo ======================================================== 
done
