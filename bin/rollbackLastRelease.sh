#!/bin/bash

#
#

echo `date` Entering $0

DEST_S3_PATH=lot49/current/
DEST_S3_PATH_PREVIOUS=lot49/previous/

ACCESS_KEY=AKIAISUFNVKSK32327XA
SECRET_KEY=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

echo Rollback last release ...

if [ "$1" == "" ] || [ "$1" == "va" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-us-east-new.opendsp.com/$DEST_S3_PATH_PREVIOUS s3://deploy-us-east-new.opendsp.com/$DEST_S3_PATH 
fi

if [ "$1" == "" ] || [ "$1" == "tk" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-tokyo-new.opendsp.com/$DEST_S3_PATH_PREVIOUS s3://deploy-tokyo-new.opendsp.com/$DEST_S3_PATH
fi

if [ "$1" == "" ] || [ "$1" == "sg" ]; then
	s3cmd  --access_key=$ACCESS_KEY --secret_key=$SECRET_KEY sync --delete-removed s3://deploy-singapore-new.opendsp.com/$DEST_S3_PATH_PREVIOUS s3://deploy-singapore-new.opendsp.com/$DEST_S3_PATH
fi

echo -e "\n"