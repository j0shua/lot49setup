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

cd ${LOT49_HOME}/git/Lot49Setup
git reset --hard --
git pull --no-edit --all
git pull --no-edit --all origin $branch

cd ${LOT49_HOME}/git/Lot49

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
s3cmd sync --delete-removed ${LOT49_HOME}/jars/ s3://scripts.opendsp.com/lot49/build/${branch}/${commit}/jars/
echo Synched to S3:
ls -1 ${LOT49_HOME}/jars | wc -l

echo "Build $commit."
echo -e "\n"

