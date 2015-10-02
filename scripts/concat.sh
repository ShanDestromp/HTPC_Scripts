#!/bin/bash

#AUTH: Shan Destromp
#FILE: concat.sh
#LICENSE: GNU GPL v2.0
#SOURCE HOMEPAGE: https://github.com/ShanDestromp/HTPC_Scripts

#########TODO############
#Make it general-purpose#
#########TODO############

###############
#CONFIGURATION#
###############

#The following is intended for situations where your HTPC software runs as a different user/group than who ran this script
USER="master" #who you want to own the output
GROUP="master" #what group owns the output

############
#END CONFIG#
############

SRC=./*
IFS='
'
FF=`which ffmpeg`

COUNT=1
SERIES=""

for I in *
do

	if [ ! -d "./tmp" ]
	then
		mkdir "./tmp"
	fi

	EXT=${I##*.}
	
	RACE=`echo ${I}| cut -d "-" -f 3`
	RACE=${RACE%\.*}
	RACE=$(sed -e 's/^[[:space:]]*//' <<<"$RACE")
	
	SSN=`echo ${I}| cut -d "-" -f 2`
	SSN=${SSN%\.*}
	SSN=$(sed -e 's/^[[:space:]]*//' <<<"$SSN")
	
	O=$SERIES" - "$SSN" - "$RACE"."$EXT
	
	if (( $COUNT % 2 == 0 )) 
	then
		$FF -i concat:"${TI}|${I}" -c copy "./tmp/${O}"
		TI=""
	else 
		TI=${I}
	fi
	
	((COUNT+=1))
done

chown -R $USER:$GROUP ./tmp
