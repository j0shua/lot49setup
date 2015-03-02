#!/bin/bash

#
#

echo `date` Entering $0

LOT49_HOME=/opt/lot49

echo Home: ${LOT49_HOME}

echo Jenkins HOME:                           ${JENKINS_HOME}
echo Jenkins workspace:                      ${WORKSPACE}
echo Job directory:                          ${WORKSPACE}/../../${JOB_NAME}
echo Build data:                             ${WORKSPACE}/../../${JOB_NAME}/builds/${BUILD_ID}
echo The current build number:               ${BUILD_NUMBER}
echo The current build ID:                   ${BUILD_ID}
echo Name of the project:                    ${JOB_NAME}
echo Name of the slave:                      ${NODE_NAME}
echo Whitespace-separated list of labels:    ${NODE_LABELS}
echo GIT_BRANCH:                             ${GIT_BRANCH}
echo GIT_COMMIT:                             ${GIT_COMMIT}
echo GIT_BRANCH_NAME:                        ${GIT_BRANCH#*/}

GIT_BRANCH_NAME=${GIT_BRANCH#*/}
GIT_BRANCH_NAME=${GIT_BRANCH_NAME/\//_}
LAST_BUILD_DIR=${LOT49_HOME}/last-build/$GIT_BRANCH_NAME
DEST_S3_PATH=lot49/current/
DEST_S3_PATH_PREVIOUS=lot49/previous/
ACCESS_KEY=AKIAISUFNVKSK32327XA
SECRET_KEY=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

cd "${WORKSPACE}"
mvn -e -X clean dependency:copy-dependencies package -Dmaven.test.skip=true

echo Cleaning JARs directory.
rm -rf $LAST_BUILD_DIR
mkdir $LAST_BUILD_DIR

cd "${WORKSPACE}/target/"
cp ./Lot49*.jar $LAST_BUILD_DIR

cd "${WORKSPACE}/target/dependency/"
mv ./*.* $LAST_BUILD_DIR

echo BRANCH: ${GIT_BRANCH} > $LAST_BUILD_DIR/VERSION.TXT
echo REVISION: ${GIT_COMMIT} >> $LAST_BUILD_DIR/VERSION.TXT

echo Copying JARs to S3...

if [ "$1" == "demo" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed $LAST_BUILD_DIR/ s3://deploy-us-east-new.opendsp.com/lot49/ci-opendsp-com/
fi

if [ "$1" == "" ] || [ "$1" == "ca" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-ca-new.opendsp.com/$DEST_S3_PATH s3://deploy-ca-new.opendsp.com/$DEST_S3_PATH_PREVIOUS
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed $LAST_BUILD_DIR/ s3://deploy-ca-new.opendsp.com/$DEST_S3_PATH
fi

if [ "$1" == "" ] || [ "$1" == "va" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-us-east-new.opendsp.com/$DEST_S3_PATH s3://deploy-us-east-new.opendsp.com/$DEST_S3_PATH_PREVIOUS
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed $LAST_BUILD_DIR/ s3://deploy-us-east-new.opendsp.com/$DEST_S3_PATH
fi

if [ "$1" == "" ] || [ "$1" == "eu" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-ireland-new.opendsp.com/$DEST_S3_PATH s3://deploy-ireland-new.opendsp.com/$DEST_S3_PATH_PREVIOUS
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed $LAST_BUILD_DIR/ s3://deploy-ireland-new.opendsp.com/$DEST_S3_PATH
fi

if [ "$1" == "" ] || [ "$1" == "tk" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-tokyo-new.opendsp.com/$DEST_S3_PATH s3://deploy-tokyo-new.opendsp.com/$DEST_S3_PATH_PREVIOUS
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed $LAST_BUILD_DIR/ s3://deploy-tokyo-new.opendsp.com/$DEST_S3_PATH
fi

if [ "$1" == "" ] || [ "$1" == "sg" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-singapore-new.opendsp.com/$DEST_S3_PATH s3://deploy-singapore-new.opendsp.com/$DEST_S3_PATH_PREVIOUS
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed $LAST_BUILD_DIR/ s3://deploy-singapore-new.opendsp.com/$DEST_S3_PATH
fi

echo "Copy ${BUILD_ID}."
echo -e "\n"