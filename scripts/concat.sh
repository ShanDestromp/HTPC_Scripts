#!/bin/bash

SRC=./*
IFS='
'
FF=`which ffmpeg`

COUNT=1
SERIES="Formula 1"


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

chown -R master:master ./tmp
