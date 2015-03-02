#!/bin/bash

echo `date` Entering $0

. `dirname $0`/common.sh

${LOT49_HOME}/bin/updateAds.sh

cd $LOT49_HOME/log

rm -rf *

export log_config=${LOT49_HOME}/conf/log4j.demo.ci.opendsp.com.json

debug=""

if [ "$1" == "debug" ]; then
    debug="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=10002,suspend=n"
fi

nohup \
    java \
    $debug \
    -XX:-OmitStackTraceInFastThrow \
    -server \
    -cp "${LOT49_HOME}/jars/*" \
    -DLog4jContextSelector=org.apache.logging.log4j.core.selector.BasicContextSelector \
    -Dlog4j.configurationFile=$log_config \
    -Dorg.eclipse.jetty.LEVEL=DEBUG \
    -Dorg.eclipse.jetty.util.log.Logger.level=DEBUG \
    -Dorg.eclipse.jetty.util.log.class=org.eclipse.jetty.util.log.StdErrLog \
    -Dorg.eclipse.jetty.LEVEL=INFO \
    -Dorg.eclipse.jetty.websocket.LEVEL=DEBUG \
    -Djava.security.policy=${LOT49_HOME}/conf/java.policy \
    com.enremmeta.rtb.Bidder \
    -c ${LOT49_HOME}/conf/lot49.demo.ci.opendsp.com.json 1>${LOT49_HOME}/log/nohup.out 2>&1 &

pid=$!

echo Started process $pid

pid_exist=`ps -p $pid | grep $pid`
(tail -f ${LOT49_HOME}/log/nohup.out)&
while [ "$pid_exist" != "" ];
do
start_test=`grep 'Lot49.*is listening on 10001' ${LOT49_HOME}/log/nohup.out`
if [ "$start_test" = "" ];
then
echo Waiting to initialize...
sleep 1
pid_exist=`ps -p $pid | grep $pid`
else
sleep 1
echo Started $pid
echo $pid>/var/lock/lot49.pid

echo -e "\n"
exit
fi
done

echo Could not start: $start_test.

