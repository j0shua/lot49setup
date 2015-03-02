#!/bin/bash

echo `date` Entering $0

. `dirname $0`/common.sh

${LOT49_HOME}/bin/stop.sh
sleep 1

${LOT49_HOME}/bin/start.sh

cd ${LOT49_HOME}/log

