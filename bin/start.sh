#!/bin/bash

# Starts Lot49 bidder, when it starts, starts NGINX.

echo `date` Entering $0

. `dirname $0`/common.sh

${LOT49_HOME}/bin/updateSetup.sh
${LOT49_HOME}/bin/updateData.sh

${LOT49_HOME}/bin/run.sh

if [ "$LOT49_HOME" != "/opt/lot49" ]; then
  echo Some other setup \($LOT49_HOME\), not starting NGINX.
else
  service nginx restart
fi
rm /tmp/maintenance.txt
