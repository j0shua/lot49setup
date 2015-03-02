#!/bin/bash

echo `date` Entering $0

. `dirname $0`/common.sh

if isLeader; then 
  date
  ${LOT49_HOME}/bin/bidder_count.py 
  date
fi
