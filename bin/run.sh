#!/bin/bash

# Runs the bidder with appropriate arguments.
# Waits for it to fully startup (listen on port 10000) or exit.

echo `date` Entering $0

. `dirname $0`/common.sh

${LOT49_HOME}/bin/updateAds.sh

# Allow core dumps
ulimit -c unlimited

datestamp=`date +"%Y-%m-%d_%H%M%S.%N"`
${LOT49_HOME}/bin/rotate.sh 2>&1 >> ${LOT49_HOME}/log/upload.log 
${LOT49_HOME}/bin/upload.sh -f 2>&1 >> ${LOT49_HOME}/log/upload.log &

debugGc=""
debug=""
# https://docs.oracle.com/javase/8/docs/technotes/tools/unix/java.html
if isLeader; then 
  stackTraceOption="-XX:-OmitStackTraceInFastThrow"
  # debugGc="-verbosegc -XX:+PrintTenuringDistribution -XX:+PrintGCDateStamps"
  debug="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5000"
  err=${LOT49_HOME}/log/nohup.err
else
  err=/dev/null
  stackTraceOption="-XX:+OmitStackTraceInFastThrow"
fi


echo Will log stderr to ${err}.

config_file=lot49.${CONFIG_FILE_SUFFIX}
heapMax=-Xmx24g
heapMin=-Xmx24g
maxNewSize=12g

if isLeader; then
  log_config_file=log4j-verbose.${CONFIG_FILE_SUFFIX}
  # log_config_file=log4j-terse.${CONFIG_FILE_SUFFIX}
else
  log_config_file=log4j-terse.${CONFIG_FILE_SUFFIX}
fi

echo Configuration: $config_file
echo Log configuration: $log_config_file
echo Heap: $heap

#     -XX:SurvivorRatio=16 \
#     -XX:NewRatio=2 \
# -XX:+UseBiasedLocking - do not use until code fixed
#    -XX:MaxNewSize=$maxNewSize \
#    -XX:MaxTenuringThreshold=15 \

#    -XX:G1HeapRegionSize=32m \
nohup java \
    $stackTraceOption \
    -XX:ObjectAlignmentInBytes=16 \
    -XX:+UseCompressedOops \
    -XX:CompressedClassSpaceSize=3G \
    -XX:+UseStringCache \
    -XX:+AggressiveOpts \
    -Xnoclassgc \
    -XX:+UseG1GC \
    $debugGc \
    $debug \
    -XX:MaxGCPauseMillis=10 \
    -XX:+UseLargePages \
    -XX:+DisableExplicitGC \
    -XX:+UseCondCardMark \
    -XX:MaxInlineSize=1024 \
    -XX:CompileCommandFile=${LOT49_HOME}/bin/compileCommand.txt \
    $heapMax $heapMin \
    -server \
    -DLog4jContextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector \
    -DAsyncLogger.ExceptionHandler=com.enremmeta.rtb.LogExceptionHandler \
    -Dlog4j.configurationFile=${LOT49_HOME}/conf/$log_config_file \
    -Djava.security.policy=${LOT49_HOME}/conf/java.policy \
    -cp "${LOT49_HOME}/jars/*" \
    com.enremmeta.rtb.Bidder \
    -c ${LOT49_HOME}/conf/$config_file 1>${LOT49_HOME}/log/nohup.out 2>$err &

pid=$!

echo Started process $pid

pid_exist=`ps -p $pid | grep $pid`
(tail -f ${LOT49_HOME}/log/nohup.out)&
while [ "$pid_exist" != "" ];
do
start_test=`grep 'Lot49.*is listening on 10000' ${LOT49_HOME}/log/nohup.out`
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
echo Exiting $0
exit
fi
done

echo Could not start: $start_test.

echo Exiting $0

