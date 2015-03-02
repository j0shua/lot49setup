#!/usr/bin/python
import sys
import os
import time
import datetime
import boto.dynamodb
import simplejson
import fileinput

conn = None
table = None
def main():
    region = os.environ['AWS_REGION']
    if region == 'compute-1':
        region = 'us-east-1'
    global conn
    print 'Connecting to %s' % region
    conn = boto.dynamodb.connect_to_region(region)
    global table
    table = conn.get_table('users1')
    if len(sys.argv) == 1:
        for line in fileinput.input():
            printUser(line) 
    else:
        user = sys.argv[1]
        printUser( user)

def printUser(user):
    if not user:
        print
        return
    user = user.strip()
    if not user or user == '-':
        print
        return
    try:
        item = table.get_item(hash_key=user)
        json = item['doAttr']
        print json
    except boto.dynamodb.exceptions.DynamoDBKeyNotFoundError:
        print "[]"

if __name__ == "__main__":
    main()
