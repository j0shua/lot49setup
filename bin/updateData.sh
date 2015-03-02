#!/bin/bash
# Update lookup tables -- geo for now

echo `date` Entering $0

. `dirname $0`/common.sh

set -x

rm -rf ${LOT49_HOME}/data
mkdir -p ${LOT49_HOME}/data/geo/maxmind
mkdir -p ${LOT49_HOME}/data/geo/skyhook
mkdir -p ${LOT49_HOME}/data/geo/adx
mkdir -p ${LOT49_HOME}/data/ip/integral

echo Syncing data from ${S3_DATA_DEPLOY_PATH} to ${LOT49_HOME}/data/
/usr/bin/s3cmd --delete-removed --config=/root/.s3cfg sync ${S3_DATA_DEPLOY_PATH} ${LOT49_HOME}/data/

#echo Syncing data from s3://scripts.opendsp.com/lot49/data/ to ${LOT49_HOME}/data
#/usr/bin/s3cmd --delete-removed --config=/root/.s3cfg sync s3://scripts.opendsp.com/lot49/data/ ${LOT49_HOME}/data

echo Synced from S3:
ls -1 ${LOT49_HOME}/data | wc -l

cd ${LOT49_HOME}/data/geo/maxmind

echo Extracting Geo
for gz in ${LOT49_HOME}/data/geo/maxmind/GeoIP2*.tar.gz ; do
tar xvfz $gz --strip=1
rm $gz
done

ls -l ${LOT49_HOME}/data
ls -l ${LOT49_HOME}/data/geo/maxmind
ls -l ${LOT49_HOME}/data/geo/skyhook
ls -l ${LOT49_HOME}/data/geo/adx
ls -l ${LOT49_HOME}/data/ip/integral
