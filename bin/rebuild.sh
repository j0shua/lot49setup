#!/bin/bash

echo `date` Entering $0



. `dirname $0`/common.sh

if [ "$LOT49_HOME" = "/opt/lot49.demo" ]; then
    echo Do not use rebuild.sh on ci machine, just do:
    echo ${LOT49_HOME}/bin/build.sh
    echo Then kill Java and do
    echo ${LOT49_HOME}/bin/runDemoApp.sh
    exit 1
fi

# TODO this is temporary - move this stuff to tmp cause these are large
# and we don't want to move them to S3 quite yet... Keep in tmp
# and later clean out.
mkdir -p ${LOT49_HOME}/log/tmp

cd ${LOT49_HOME}/log

${LOT49_HOME}/bin/build.sh && ${LOT49_HOME}/bin/updateCron.sh && ${LOT49_HOME}/bin/stop.sh && (/bin/rm -f -d ${LOT49_HOME}/logs/*; echo "Cleaned up") && ${LOT49_HOME}/bin/start.sh
