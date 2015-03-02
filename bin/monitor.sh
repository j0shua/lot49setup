#!/bin/bash
#
# Some monitoring values
#

. `dirname $0`/common.sh

date
echo Load: 
/usr/bin/w
echo Socket stats:
ss -s 
#echo Connections: 
#/bin/netstat -an|/bin/awk '/tcp/ {print $6}'|sort| uniq -c 
echo -e "\n"
/bin/date

nginx_before=`/usr/bin/wc -l ${LOT49_HOME}/log/nginx-access.log | cut -d' ' -f1`
echo NGINX BEFORE: $nginx_before
lot49_before=`/usr/bin/wc -l ${LOT49_HOME}/log/request.log | cut -d' ' -f1`
echo LOT49 BEFORE: $lot49_before

/bin/sleep 10
/bin/date
nginx_after=`/usr/bin/wc -l ${LOT49_HOME}/log/nginx-access.log | cut -d' ' -f1`
echo NGINX AFTER:  $nginx_after
lot49_after=`/usr/bin/wc -l ${LOT49_HOME}/log/request.log | cut -d' ' -f1`
echo LOT49 AFTER: $lot49_after
nginx_qps=`echo "($nginx_after-$nginx_before)/10" |bc`
lot49_qps=`echo "($lot49_after-$lot49_before)/10" |bc`
echo NGINX QPS: $nginx_qps
echo Lot49 QPS: $lot49_qps


if [ "$lot49_qps" == "0" ] || [ "$lot49_qps" == "" ]; then
  echo ALERT: Lot49 STOPPED PROCESSING
fi

echo -e "\n"