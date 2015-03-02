#!/bin/sh
echo Redis killed called with $*
host=$1
client=$2
echo CLIENT KILL $client | redis-cli -h $host