#!/bin/bash

# Runs the bidder on jenkins for integration tests.
# Waits for it to fully startup (listen on port 10000) or exit.


echo Jenkins workspace: ${WORKSPACE}
# Jenkins workspace: /var/lib/jenkins/jobs/Lot49 - OB-592/workspace

echo Job directory: ${WORKSPACE}/../../${JOB_NAME}
# Job directory: /var/lib/jenkins/jobs/Lot49 - OB-592/workspace/../../Lot49 - OB-592

echo Build data: ${WORKSPACE}/../../${JOB_NAME}/builds/${BUILD_ID}
# Build data: /var/lib/jenkins/jobs/Lot49 - OB-592/workspace/../../Lot49 - OB-592/builds/6


LOT49_HOME=/opt/lot49
LOT49_DYNAMODB_ENDPOINT="dynamodb.us-east-1.amazonaws.com"
debugGc=""
err=${LOT49_HOME}/log/nohup.err
config_file=lot49.jenkins.json
heapMax=-Xmx8g
heapMin=-Xmx4g
maxNewSize=12g
log_config_file=log4j-ci.json

export LOT49_HOME
export LOT49_DYNAMODB_ENDPOINT

echo Configuration: $config_file
echo Log configuration: $log_config_file

echo Restart bidder

${LOT49_HOME}/bin/stopTestBidder.sh

cd "${WORKSPACE}"
mvn -e -X clean dependency:copy-dependencies package -Dmaven.test.skip=true

echo Cleaning JARs directory.
rm -rf ${LOT49_HOME}/jars
mkdir ${LOT49_HOME}/jars

cd "${WORKSPACE}/target/"
cp ./Lot49*.jar ${LOT49_HOME}/jars/

cd "${WORKSPACE}/target/dependency/"
mv ./*.* ${LOT49_HOME}/jars/

echo BRANCH: ${GIT_BRANCH} > ${LOT49_HOME}/jars/VERSION.TXT
echo REVISION: ${GIT_COMMIT} >> ${LOT49_HOME}/jars/VERSION.TXT

nohup java \
    -XX:+OmitStackTraceInFastThrow \
    -XX:ObjectAlignmentInBytes=16 \
    -XX:+UseCompressedOops \
    -XX:CompressedClassSpaceSize=3G \
    -XX:+UseStringCache \
    -XX:+AggressiveOpts \
    -Xnoclassgc \
    -XX:+UseG1GC \
    $debugGc \
    -XX:MaxGCPauseMillis=10 \
    -XX:+UseLargePages \
    -XX:+DisableExplicitGC \
    -XX:+UseCondCardMark \
    -XX:MaxInlineSize=1024 \
    -XX:CompileCommandFile=${LOT49_HOME}/bin/compileCommand.txt \
    $heapMax $heapMin \
    -server \
    -DLog4jContextSelector=org.apache.logging.log4j.core.async.AsyncLoggerContextSelector \
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

# echo Start IT
# cd ${WORKSPACE}
# mvn org.jacoco:jacoco-maven-plugin:prepare-agent-integration -Prun-integration -Dsonar.host.url=http://jenkins.opendsp.com:9000/

exit
fi
done

echo Could not start: $start_test.

echo Exiting $0
