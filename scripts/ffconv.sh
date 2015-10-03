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

#CROP SETTINGS
ACSS="600" #How far in to start scanning in seconds
ACTL="120" #How long to scan in seconds

#The following is intended for situations where your HTPC software runs as a different user/group than who ran this script
USER="master" #who you want to own the output
GROUP="master" #what group owns the output

#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#
#@@@@@@# END CONFIGURATION @@@@@@@@#
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#

FF=`which ffmpeg` #locates ffmpeg program
CHOWN=`which chown` #locates chown command
MV=`which mv` #locates move command


ENC_OPTS="$VID_OPTS $AUD_OPTS $SUB_OPTS $OTH_OPTS" #All encoding options grouped together
MODE="$(echo $1 | tr '[A-Z]' '[a-z]')" #mode in lowercase for ease
IFCROP="$(echo $2 | tr '[A-Z]' '[a-z]')" #lowercase 2nd var to check if cropping

#Have to pass a mode otherwise we don't know what to do
if [ "$MODE" != "series" ] && [ "$MODE" != "movie" ]
then
	echo "You must pass a MODE:  'series' or 'movie'" 
	exit 1
fi

for I in ./*
do
	OUT=${I%\.*} #Removes file extension
	OUT="${OUT//\.\/}" #removes ./
	OUT="${OUT//_/ }" #Replaces "_" with " "

	#Ensures that we don't try and do anything with a void file, cwd or cwd-1
	if [ "$OUT" != "" ] && [ "$OUT" != "." ] && [ "$OUT" != ".." ]
	then
		#Makes the movie output folder based upon initial filename
		if [ "$MODE" = "movie" ] 
		then	
			OUT=${OUT::-4} #Trims t## at the end of the name
			OUT_DIR="./$OUT"
			mkdir "$OUT_DIR"

		#it's a TV show, check for a ./converted folder and make as needed
		elif [ "$MODE" = "series" ] && [ ! -d "./converted" ]
		then
			OUT_DIR="converted"
			mkdir "./$OUT_DIR"
		else
			OUT_DIR="converted"
		fi
		
		#If Cropping get crop amount, else no crop
		if [ "$IFCROP" = "crop" ]
		then 
			CROP=`$FF -ss $ACSS -i "$I" -f matroska -t $ACTL -an -vf cropdetect -y -crf 51 -preset ultrafast /dev/null 2>&1 | grep -o crop=.* | sort -bh | uniq -c | sort -bh | tail -n1 | grep -o crop=.*`
			CROP=" -vf $CROP"
			echo $CROP
		else
			CROP=""
		fi
		
		#Process the file based upon settings
		$FF -analyzeduration 500M -probesize 500M -i "$I" $CROP $ENC_OPTS $QUAL '-f' $OUT_TYPE "$OUT_DIR/$OUT.mkv"
		$CHOWN '-R' $USER:$GROUP "$OUT_DIR" #change ownership of the file
		
		#Move the movie folder to it's home
		if [ "$MODE" = "movie" ] 
		then
			$MV "$OUT_DIR" "$END/$OUT_DIR"
		fi
	fi
done
exit 0
