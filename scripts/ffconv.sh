#!/bin/bash

#AUTH: Shan Destromp
#FILE: ffconv.sh
#LICENSE: GNU GPL v2.0
#SOURCE HOMEPAGE: https://github.com/ShanDestromp/HTPC_Scripts

#################################################
#USEAGE
# /path/to/ffconv.sh MODE [CROP]
#
# Mode consists of either 'movie' or 'series'
#
# When set to movie, script will recursively run files
# through ffmpeg, outputting temporarily to source_directory/FILENAME/OUTPUT_FILENAME.
# Upon completing the batch, the video will be moved to the END location set in the configuration,
# whilst retaining the filename_folder/filename.extension format
#
# When mode is set to 'series', the script will output all files to the source_directory/converted/filename
# This mode is intended for TV-shows and other media which doesn't need individual folders.
#
# the CROP flag enables automatic cropping of the source media.  Many movies that are filmed in anything other than 4:3
# or 16:9 have black bars *embedded* into the media.  This attempts to crop that out to save a bit of space but is unreliable
# When using the crop flag ALWAYS CHECK THE OUTPUT; if it is incorrect (over / under cropped) change "-ss" and "-vframes"
# near the bottom of the configuration.  The scripted-defaults are 1675 and 7005 respectively; these indicate how far into the 
# video (in frames) and and how long to scan while auto-detecting.

##########
#EXAMPLES#
##########

# ./ffconv.sh movie crop
# /home/user/scripts/ffconv.sh series

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#@@@@@@@ SET CONFIGURATION @@@@@@@@#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

VID_OPTS="-c:v libx264 -profile:v main -preset ultrafast -tune film" #x264 encoded, main profile ultrafast with film tuning
OUT_TYPE='matroska' #Output  type

QUAL='-crf 22' #Quality

AUD_OPTS='' #Audio Options

SUB_OPTS='-c:s copy' #By Default just copy all sub tracks

OTH_OPTS='-map 0'

END="/mnt/tardis/conv/temp/" #Post-compress movie destination

SS="1675" #Auto-Crop settings
VFRAMES="7005" #Auto-Crop settings
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#@@@@@@# END CONFIGURATION @@@@@@@@#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

FF=`which ffmpeg` #locates ffmpeg program
CHOWN=`which chown` #locates chown command
MV=`which mv` #locates move command


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
			CROP=`${FF} -analyzeduration 500M -probesize 500M -ss ${SS} -i "${I}" -vframes ${VFRAMES} -t 1 -vf "cropdetect=24:16:0" -f null - 2>&1 | awk '/crop/ { print $NF }' | tail -1`
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