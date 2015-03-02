#!/bin/bash

. `dirname $0`/common.sh
cd ${LOT49_HOME}

java \ 
    -XX:-OmitStackTraceInFastThrow \
    -Xnoclassgc \
    -XX:+UseG1GC \
    -XX:MaxGCPauseMillis=50 \
    -XX:+UseLargePages \
    -XX:+UseCondCardMark \
    -XX:MaxInlineSize=1024 \
    -XX:CompileCommandFile=${LOT49_HOME}/bin/compileCommand.txt \
    -server -cp "${LOT49_HOME}/jars/*" \
    -Dorg.eclipse.jetty.LEVEL=DEBUG \
    -Dorg.eclipse.jetty.util.log.Logger.level=DEBUG \
    -Dorg.eclipse.jetty.util.log.class=org.eclipse.jetty.util.log.StdErrLog \
    -Dorg.eclipse.jetty.LEVEL=INFO \
    -Dorg.eclipse.jetty.websocket.LEVEL=DEBUG \
    com.enremmeta.rtb.Bidder \
    -c ${LOT49_HOME}/conf/lot49.json.debug.va.opendsp.com
