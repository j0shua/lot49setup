#!/bin/bash

echo `date` Entering $0

. `dirname $0`/common.sh
 
function update {
    gitDir=${LOT49_HOME}/git/$1
    adDir=${LOT49_HOME}/$2
    repoName=$3
    if [ ! -d $gitDir ]; then
	repo=git@github.com:${repoName}.git
	echo git clone $repo $adDir
	git clone $repo $gitDir 
	mkdir -p $adDir
    fi

    cd $gitDir
    echo In `pwd`
    git reset --hard --
    git pull --all
    git log | head 

    cd $adDir
    if [ -f reading.txt ]; then
	echo Lot49 is reading: reading.txt:
	cat reading.txt
    else 
	rm -f wrote.txt
	rm -rf src
	mv -f ${gitDir}/src $adDir
	date > wrote.txt
	echo wrote.txt:
	cat wrote.txt
    fi 
    popd
    echo
}

pushd ${LOT49_HOME}

update Lot49Ads ads Enremmeta/Lot49Ads
# TODO this can be more automated by iterating over config 
# (this info is in DB, ld_client table).
update wml wml Enremmeta/wml
