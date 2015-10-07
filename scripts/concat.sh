#!/bin/bash

#AUTH: Shan Destromp
#FILE: concat.sh
#LICENSE: GNU GPL v2.0
#SOURCE HOMEPAGE: https://github.com/ShanDestromp/HTPC_Scripts

#################################################
#USEAGE
# /path/to/concat.sh 
# 
# Script assumes that all files are named in sequence and combines in 
# sequence in pairs (eg files 1 and 2 combine to make A; 3 and 4 make B etc).
# It also requires that your local ffmpeg has 'concat' compiled in; and there
# are limitations to what file formats / encoders this works with.  Typically any AVI
# files will work fine.  Read more at https://trac.ffmpeg.org/wiki/Concatenate
#
# The script attempts to find the "true" filename by searching for differences between 1 & 2;
# dropping whatever is changed and appending 'JOINED' at the end before the file extension.
# For example MyShow_Part1.mkv and MyShow_Part2.mkv would result in ./JOINED/MyShow_JOINED.mkv
#
# Not particularly clean but it gets the job done.

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
CHOWN=`which chown`


COUNT=1 #internal counter

#Makes joined folder in current dir
if [ ! -d "./JOINED" ]
then
	mkdir "./JOINED"
fi

for I in *.* #requires the file to have an extension - helps exclude directories and merging the wrong files
do
	#For every 2 files, join them
	if (( $COUNT % 2 == 0 )) 
	then
	
		#Gets our file extension
		EXT=${I##*.}

		#Finds commanality between two filenames, removes "PART" and "CD" from filename, and trims excess whitespace
		O=`printf "%s\n%s\n" "$TI" "$I" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/' -e 's/PART//gI' -e 's/CD//gI' | xargs`
		O=$O"_JOINED."$EXT #Our new filename
				
		$FF -i concat:"${TI}|${I}" -acodec copy -vcodec copy "./JOINED/${O}"
		TI="" #Clears our temporary pointer
	#Assign temporary name for first file
	else 
		TI=${I}
	fi
	#Increment counter
	((COUNT+=1))
done

#Assigns ownership of the output folder and contents
$CHOWN -R $USER:$GROUP ./JOINED
