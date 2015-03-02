#!/bin/bash
host=$1
client=$2
echo CLIENT KILL $client | redis-cli -h $host