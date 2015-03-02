#!/bin/sh
set -x
cd /opt/lot49/git/Lot49
git pull -f --all
mvn -e -X clean dependency:copy-dependencies package -Dmaven.test.skip=true
yes | cp `find target -name '*jar'` /opt/lot49/jars/
stop.sh
cd /opt/lot49/log
rm -rf 
run.sh
service nginx restart
