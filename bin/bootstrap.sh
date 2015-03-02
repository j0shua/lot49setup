#!/bin/bash

# Run by AutoScaling (or whenever bootstrapping needs to happen).

echo `date` Entering $0

LOT49_HOME=/opt/lot49
export LOT49_HOME

cd ${LOT49_HOME}/git/Lot49Setup
git stash
git pull --all
git checkout master
git pull --all 
git checkout master

. `dirname $0`/common.sh

${LOT49_HOME}/bin/stop.sh

mkdir -v -p /media/ephemeral0/log

echo Starting bootstrap at `date`... 

set -x

echo s3cmd settings:
/usr/bin/s3cmd --config=/root/.s3cfg --dump-config
echo -e "\n"

# Turn off logging on non-main instances
echo "Entering logging setup"

# MAIN_INSTANCE_ID is defined in common.sh

echo Checking if I, $instanceId, am the main instance: $MAIN_INSTANCE_ID.
if [ isLeader ]; then
echo "I am the main instance!"
cat ${LOT49_HOME}/git/Lot49Setup/conf/nginx.conf | sed -e 's/# MAIN_NODE //g' > /etc/nginx/nginx.conf
else
echo "I am NOT the main instance!"
cat ${LOT49_HOME}/git/Lot49Setup/conf/nginx.conf | sed -e 's/# NON_MAIN_NODE //g' > /etc/nginx/nginx.conf
fi

echo Copying up-to-date ads.
cd ${LOT49_HOME}/git/Lot49Ads
git stash
git pull --all 
git checkout master
git pull --all 

rm -rf ${LOT49_HOME}/ads
mkdir -p ${LOT49_HOME}/ads
cp -r src ${LOT49_HOME}/ads

rm -rf ${LOT49_HOME}/jars
echo Syncing JAR files from ${S3_JAR_DEPLOY_PATH} to ${LOT49_HOME}/jars/
/usr/bin/s3cmd --config=/root/.s3cfg sync ${S3_JAR_DEPLOY_PATH} ${LOT49_HOME}/jars/
ls -l ${LOT49_HOME}/jars 

${LOT49_HOME}/bin/updateCron.sh
${LOT49_HOME}/bin/start.sh 

echo Done at `date`. 
echo Exiting $0