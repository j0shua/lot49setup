#!/bin/bash
#
# Build Lot49. An optional argument is a branch. If the branch is
# omitted, master is assumed. If the branch is master, the built
# JARs are deployed to S3 for bootstrap.sh to pull them when deploying
# other instances.

echo `date` Entering $0

. `dirname $0`/common.sh

echo Cleaning JARs directory.
rm -rf ${LOT49_HOME}/jars
mkdir ${LOT49_HOME}/jars

cd ${LOT49_HOME}/git/Lot49

if [ "$LOT49_HOME" == "/opt/lot49.demo" ]; then
   S3_JAR_DEPLOY_PATH="s3://deploy-us-east-new.opendsp.com/lot49/ci-opendsp-com/"
fi

if [ -n "${S3_JAR_DEPLOY_PATH}" ];then
        rm -rf ${LOT49_HOME}/jars
        mkdir -p ${LOT49_HOME}/jars
        echo Syncing JAR files from ${S3_JAR_DEPLOY_PATH} to ${LOT49_HOME}/jars/
        /usr/bin/s3cmd --config=/root/.s3cfg sync ${S3_JAR_DEPLOY_PATH} ${LOT49_HOME}/jars/
        ls -l ${LOT49_HOME}/jars
        exit 0;
fi

if [ "$1" == "" ]; then
  branch=master
else
  branch=$1
fi
echo Pulling $branch
git fetch --all
git reset --hard origin/$branch

if [ "$?" != "0" ]; then
   echo Pull unsuccessful.
   exit 1
fi

echo Checking out branch $branch.
git checkout $branch

if [ "$?" != "0" ]; then
   echo Checkout unuccessful.
   exit 1
fi

commit=`git log | head -1 | sed -e 's/commit //'`
mvn -e -X clean dependency:copy-dependencies package -Dmaven.test.skip=true

cp target/Lot49*jar target/dependency/*jar ${LOT49_HOME}/jars

# TODO should be in maven later
rm ${LOT49_HOME}/jars/servlet-api-2.5-20081211.jar 

echo BRANCH: $branch  > ${LOT49_HOME}/jars/VERSION.TXT
echo REVISION: $commit >> ${LOT49_HOME}/jars/VERSION.TXT

echo Copying JARs to S3...
s3cmd sync --delete-removed ${LOT49_HOME}/jars/ s3://scripts-new.opendsp.com/lot49/build/${branch}/jars/
echo Synched to S3:
ls -1 ${LOT49_HOME}/jars | wc -l

echo "Build $commit."
echo -e "\n"

