#!/bin/bash

#AUTH: Shan Destromp
#LICENSE: GNU GPL v2.0
#SOURCE HOMEPAGE: https://github.com/ShanDestromp/HTPC_Scripts



MV=`which mv`
MK=`which mkdir`
CWD=`which pwd`
CHOWN=`which chown`

IFS='
'

SERIES=$1
SEASON=$2
ROOT="/mnt/tardis/conv"


if [[ $3 ]] 
then
	COUNT=$3
else
	COUNT=01
fi

for I in *
do 
	EXT=${I#*.}
	#O=${I::-1}
	
	EPISODE=$(printf "%02d" $COUNT)
	O=$SERIES" S"$SEASON"E"$EPISODE"."$EXT
	
	if [ ! -d $ROOT"/"$SERIES ]
	then
		$MK $ROOT"/"$SERIES
	fi
	if	[ ! -d $ROOT"/"$SERIES"/Season "$SEASON ]
	then
		$MK $ROOT"/"$SERIES"/Season "$SEASON
	fi

	$MV "./${I}" "${ROOT}/${SERIES}/Season ${SEASON}/$O"

	((COUNT+=1))
done

$CHOWN -R master:master $ROOT"/"$SERIES