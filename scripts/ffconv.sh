#!/bin/bash

#AUTH: Shan Destromp
#LICENSE: GNU GPL v2.0
#SOURCE HOMEPAGE: https://github.com/ShanDestromp/HTPC_Scripts

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#@@@@@@@ SET CONFIGURATION @@@@@@@@#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

VID_OPTS="-c:v libx264 -profile:v main -preset ultrafast -tune film" #x264 encoded, main profile ultrafast with film tuning
OUT_TYPE='matroska' #Output  type

QUAL='-crf 22' #Quality

AUD_OPTS=''

SUB_OPTS='-c:s copy'

OTH_OPTS='-map 0'

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#@@@@@@# END CONFIGURATION @@@@@@@@#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

#SRC=./* #Whatever directory we're in when called (not script location)
FF=`which ffmpeg` #locates ffmpeg program
CHOWN=`which chown` #locates chown command
MV=`which mv` #locates move command
END="/mnt/tardis/conv/temp/" #Post-compress movie destination


ENC_OPTS="$VID_OPTS $AUD_OPTS $SUB_OPTS $OTH_OPTS" #All encoding options
MODE="$(echo $1 | tr '[A-Z]' '[a-z]')" #TV or Movies lowercase for ease
IFCROP="$(echo $2 | tr '[A-Z]' '[a-z]')"

for I in ./*
do
	OUT=${I%\.*} #Removes file extension
	OUT="${OUT//\.\/}" #removes ./
	OUT="${OUT//_/ }" #Replaces "_" with " "

	#Ensures that we don't try and do anything with a void file, cwd or cwd-1
	if [ "$OUT" != "" ] && [ "$OUT" != "." ] && [ "$OUT" != ".." ]
	then
		if [ "$MODE" != "series" ] && [ "$MODE" != "movie" ]
		then
			echo "You must pass a MODE:  series or movie" 
			exit 1
		elif [ "$MODE" = "movie" ] 
		then	
			OUT=${OUT::-4} #Trims t## at the end of the name
			OUT_DIR="./$OUT"
			mkdir "$OUT_DIR"
		elif [ "$MODE" = "series" ] && [ ! -d "./converted" ]
		then
			OUT_DIR="converted"
			mkdir "./$OUT_DIR"
		else
			OUT_DIR="converted"
		fi
		
		if [ "$IFCROP" = "crop" ]
		then 
			CROP=`${FF} -analyzeduration 500M -probesize 500M -ss 1675 -i "${I}" -vframes 7005 -t 1 -vf "cropdetect=24:16:0" -f null - 2>&1 | awk '/crop/ { print $NF }' | tail -1`
			CROP=" -vf ${CROP}"
		else
			CROP=""
		fi
		
		$FF -analyzeduration 500M -probesize 500M -i "${I}" $CROP $ENC_OPTS $QUAL -f $OUT_TYPE "$OUT_DIR/$OUT.mkv"
		$CHOWN -R master:master "$OUT_DIR"
		
		if [ "$MODE" = "movie" ] 
		then
			$MV "$OUT_DIR" "$END/$OUT_DIR"
		fi
	else
		echo "Nothing to do in `pwd`"
		exit 0
	fi
done
exit 0