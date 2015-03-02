#!/bin/sh
echo `date` Entering $0

. `dirname $0`/common.sh
${LOT49_HOME}/bin/userLookup.py $*