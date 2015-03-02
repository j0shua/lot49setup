#!/usr/bin/python

import sys
import os
import urllib2
import redis
import boto.ec2 as ec2
import boto.ec2.elb as elb

instance_id=urllib2.urlopen("http://169.254.169.254/latest/meta-data/instance-id").read()

print "I am %s" % instance_id
region=os.environ['AWS_REGION']
if region == 'compute-1':
    region = 'us-east-1'
print "We are in %s" % region

ec2_con=ec2.connect_to_region(region)
elb_con= elb.connect_to_region(region)

reservations = ec2_con.get_all_instances()
instances = [i for r in reservations for i in r.instances]
elb_name=None
for instance in instances:
    if instance.__dict__['id'] == instance_id:
        elb_name=instance.__dict__['tags']['bidderElb']
        break
if elb_name is None:
    print "ERROR: cannot figure out my ELB name!"
    sys.exit(1)
print "My ELB is %s" % elb_name
elbs = elb_con.get_all_load_balancers(load_balancer_names=[elb_name])
count=0
for state in elbs[0].get_instance_health():
    if state.state == 'InService':
        count+=1
print "Current bidder count is %s" % count
redis_host=os.environ['BUDGET_CACHE']
print "Setting bidderCount in %s" % redis_host
r = redis.StrictRedis(host=redis_host)
r.set('bidderCount', count)
print "OK"







