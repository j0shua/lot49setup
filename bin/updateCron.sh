#!/bin/bash

echo `date` Entering $0

. `dirname $0`/common.sh

echo Updating crontab
cat ${LOT49_HOME}/bin/crontab.txt | crontab -