#!/bin/bash

#AUTH: Shan Destromp
#FILE: rename.sh
#LICENSE: GNU GPL v2.0
#SOURCE HOMEPAGE: https://github.com/ShanDestromp/HTPC_Scripts

#################################################
#USEAGE
# /path/to/rename.sh "SERIES_NAME" SEASON [EPISODE#]
#
# SERIES_NAME *SHOULD* be enquoted if there are any spaces or special characters
#
# SEASON is numerical (ex 1, or 22, no decimals or letters)
#
# Episode number is optional, it is where the script starts counting from

# ENSURE YOU SET THE ROOT VARIABLE BELOW, REGARDLESS OF WHERE THE SCRIPT IS CALLED 
# ALL OUTPUT WILL GO THERE.

##########
#EXAMPLES#
##########

# ./rename.sh "Family Guy" 8 4 #Outputs as 'ROOT/Family Guy/Season 08/Family Guy S08E04.ext' 
# /home/user/scripts/rename.sh Scrubs 1 #Outputs as 'ROOT/Scrubs/Season 01/Scrubs S01E01.ext'

###############
#CONFIGURATION#
###############

ROOT="/mnt/tardis/conv" #where you want the output to go

#The following is intended for situations where your HTPC software runs as a different user/group than who ran this script
USER="master" #who you want to own the output
GROUP="master" #what group owns the output

############
#END CONFIG#
############

MV=`which mv`
MK=`which mkdir`
CWD=`which pwd`
CHOWN=`which chown`

IFS='
'

SERIES=$1
SEASON=$2



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

$CHOWN -R $USER:$GROUP $ROOT"/"$SERIES