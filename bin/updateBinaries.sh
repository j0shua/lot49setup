#!/bin/bash

echo `date` Entering $0

. `dirname $0`/common.sh

rm -rf ${LOT49_HOME}/jars
mkdir ${LOT49_HOME}/jars
s3cmd sync s3://bin.opendsp.com/lot49/jars/ ${LOT49_HOME}/jars
echo Synched from S3:
ls -1 ${LOT49_HOME}/jars | wc -l
