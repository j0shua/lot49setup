#!/bin/bash

. `dirname $0`/common.sh

set -x
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
    -Xprof \
    -XX:+PrintGCApplicationStoppedTime \
    -XX:+PrintGCTimeStamps \
    -XX:+PrintGCDetails \
    -XX:+PrintAssembly \
    -XX:+PrintCompilation \
    -XX:+PrintInlining \
    -XX:+UnlockDiagnosticVMOptions \
    -XX:+LogCompilation \   
    -server -cp "${LOT49_HOME}/jars/*" \
    com.enremmeta.rtb.Bidder \
    -c ${LOT49_HOME}/conf/lot49.json.production.va.opendsp.com
