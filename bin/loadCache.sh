#!/bin/bash

# Runs the bidder with appropriate arguments.
# Waits for it to fully startup (listen on port 10000) or exit.

echo `date` Entering $0

. `dirname $0`/common.sh

ulimit -c unlimited

config_file=lot49.${CONFIG_FILE_SUFFIX}
log_config_file=log4j-verbose.${CONFIG_FILE_SUFFIX}

echo Bulk load for last $1 hours from directory $2

java \
    -server \
    -Dlog4j.configuration=${LOT49_HOME}/conf/log4j.properties \
    -Dlog4j.configurationFile=${LOT49_HOME}/conf/$log_config_file \
    -cp "${LOT49_HOME}/jars/*" \
    com.enremmeta.rtb.cli.HazelLoader -c ${LOT49_HOME}/conf/$config_file -h $1 -d $2
