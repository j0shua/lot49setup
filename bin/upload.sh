#!/bin/bash

# Upload rotated (gzipped) files to S3. Only upload files older 
# than 5 (see file_age below) minutes, unless -f is specified. 
# To be run via crontab, or (with -f option) from stop.sh

echo `date` Entering $0

. `dirname $0`/common.sh

echo Upload home: ${LOT49_HOME}

echo "upload.sh" >> /var/log/shsh

/usr/bin/logger -s Barabule2
mkdir ${LOT49_HOME}/log/uploaded > /dev/null 2>&1

# TODO this is temporary - move this stuff to tmp cause these are large
# and we don't want to move them to S3 quite yet... Keep in tmp
# and later clean out.
#for logFileType in {aws,debugreq,decision,jetty,main,rawrequest,response}; do
#  echo Move ${LOT49_HOME}/log/rotated/year=*/month=*/day=*/hour=*/type=$logFileType/ ${LOT49_HOME}/log/tmp/
#  find ${LOT49_HOME}/log/rotated/year=*/month=*/day=*/hour=*/type=$logFileType/ -type f -print0 | xargs -0 /bin/mv -t ${LOT49_HOME}/log/tmp/
#done

if [ "$1" = "-f" ]; then
   file_age=0
   echo GZipping all...
   log_files=`find ${LOT49_HOME}/log/rotated -name '*.log'`
   if [ "$log_files" = "" ]; then
       echo No log files to compress.
   else
       echo Found files:
       echo $log_files
       ls -l $log_files
       for f in $log_files; do
	   echo Getting line count for $f
	   lc=`wc -l $f`
	   echo Line count: file $f has $lc lines
	   echo Getting size for $f
	   size=`stat -c %s $f`
	   echo Size: file $f has $size bytes
	   echo gzip "$f" 
	   gzip "$f" &
       done
       wait
       echo Forcing upload of all.
   fi
else
   file_age=5
fi

date
echo Changing dir to ${LOT49_HOME}/log/rotated
cd ${LOT49_HOME}/log/rotated
echo Looking for files older than $file_age minutes...
for f in `find ${LOT49_HOME}/log/rotated -type f -mmin +$file_age -name '*gz'` ; do
key=`echo $f | sed -e "s/^.*\/log\/rotated\///"`
echo Putting $f under key $key
echo Getting compressed size of $f
comp_size=`stat -c %s $f`
echo Stats: File $f has `/bin/zcat $f | wc -l` lines, compressed size $comp_size bytes
echo Executing s3cmd put $f s3://stats-new.opendsp.com/$key and moving $f to ${LOT49_HOME}/log/uploaded
(s3cmd --multipart-chunk-size-mb=5 put $f s3://stats-new.opendsp.com/$key 2>&1 && /bin/mv $f ${LOT49_HOME}/log/uploaded && echo "OK: File $f has been uploaded") &
done
echo Done.
echo Remaining '*.log'
find ${LOT49_HOME}/log/rotated -name '*.log'
echo Remaining '*.log.gz'
find ${LOT49_HOME}/log/rotated -name '*.log.gz'

echo Changing dir to ${LOT49_HOME}/log/uploaded
cd ${LOT49_HOME}/log/uploaded
uploaded_file_age=`echo '60*24*7'|bc`
echo Looking for files older than $uploaded_file_age minutes...
for f in `find ${LOT49_HOME}/log/uploaded -type f -mmin +$uploaded_file_age -name '*gz'` ; do
echo Removing $f
/bin/rm -f $f
done

echo -e "\n"
echo "upload.sh - end" >> /var/log/shsh
echo Exiting $0
