#!/bin/bash
# 
# Intended to be used from stop or start - when service is not running.
#

echo `date` Entering $0

. `dirname $0`/common.sh

/usr/bin/logger -s Barabule1

echo "rotated.bash1" >> /var/log/shsh

instanceId=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`

cd ${LOT49_HOME}/log
tmp=${LOT49_HOME}/log/tmp
mkdir $tmp > /dev/null 2>&1 

skipped=0
rotated=0

for logFileType in {abtestassignment,access,aws,bid,click,debugreq,decision,impression,jetty,lost,main,nohuperr,nohupout,pseudowin,rawrequest,request,response,session,tagdecision,upload,urls,win}; do
  logFile="${logFileType}.log"
  if [ "$logFileType" = "nohuperr" ]; then
      logFile="nohup.err"
  fi
  if [ "$logFileType" = "nohupout" ]; then
      logFile="nohup.out"
  fi
  
  if [ ! -f $logFile ]; then
      /bin/echo "$logFile ($logFileType)  does not exist, skipping..."
      skipped=`/bin/echo $skipped+1|bc`
      continue
  fi

  rotateDir=`/bin/date +"rotated/type=${logFileType}/year=%Y/month=%m/day=%d/hour=%H"`
  # rotateDir="${rotateDir}/type=$logFileType"
  /bin/mkdir -p $rotateDir > /dev/null 2>&1

  fileNumber=1
  for rotatedFile in `/bin/ls $rotateDir/`; do
    rotatedBasename=`/bin/basename $rotatedFile`
    existingFileNumber=`/bin/echo $rotatedBasename | /bin/cut -d. -f5`
    # /bin/echo Looking at \[$rotatedBasename\]: Comparing $existingFileNumber to $fileNumber
    if [ "$fileNumber" -le "$existingFileNumber" ]; then
      ((fileNumber=existingFileNumber+1))
    fi
  done
  /bin/echo In $rotateDir will assign fileNumber=$fileNumber
  filenameDatePart=`date +"%Y-%m-%d-%H"`
  nanos=`date +"%N"`
  millis=`echo $nanos/1000 | bc`
  ts=`date +"%M-%S"`
  ts=${ts}-$millis
  newFileName="${logFileType}.${instanceId}.${SHORT_REGION}.${filenameDatePart}.${fileNumber}.${ts}.log"

  # TODO this is temporary - move this stuff to tmp cause these are large
  # and we don't want to move them to S3 quite yet... Keep in tmp
  # and later clean out.
#  if [ "$logFileType" = "debugreq" ] || [ "$logFileType" = "decision" ] || [ "$logFileType" = "nohuperr" ] || [ "$logFileType" = "nohupout" ] || [ "$logFileType" = "rawrequest" ] || [ "$logFileType" = "response" ]; then
#      newFileName="${tmp}/${newFileName}"
#  else
      newFileName="${rotateDir}/${newFileName}"
#  fi

  /bin/echo Moving $logFile to $newFileName
  /bin/mv $logFile $newFileName
  /bin/gzip $newFileName
  rotated=`/bin/echo $rotated+1|bc`
  /bin/echo -e "\n"
done
msg="Done, rotated $rotated files; skipped $skipped missing logs."
/bin/echo $msg
/usr/bin/logger $msg
/usr/bin/logger -s Barabule.
echo "rotated.bash1 - end " >> /var/log/shsh
echo Exiting $0
