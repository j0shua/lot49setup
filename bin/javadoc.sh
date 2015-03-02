
#!/bin/bash

function jd() {
  branch=$1
  cd /opt/git/lot49src
  # Just in case
  git checkout $branch
  git pull --all
  rm -rf /opt/git/lot49src/target/*
  mvn javadoc:javadoc 
  cp -r /opt/git/lot49src/target/site/apidocs/* /var/www/html/lot49/javadoc/$branch
}

date 
jd master
date
