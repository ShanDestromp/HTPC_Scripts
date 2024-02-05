#!/bin/bash

WISP=/app/.venv/bin/whisper

IFS='
'
FORM="srt"
LANG="en"
DEV="cuda"
VERB="False" # True or False

MODE="$(echo $1 | tr '[A-Z]' '[a-z]')" #lowercase mode

if [ "$MODE" != "ext" ] && [ "$MODE" != "file" ]
then
        echo "You must pass a MODE:  'ext' or 'file'"
        exit 1
fi

if [ "$MODE" = "ext" ]
then
  EXT="$2"
  for f in ./*."$EXT"
  do

    OUT=${f%\.*} #Removes file extension
    OUT="${OUT//\.\/}" #removes ./

    if [ -f ./$OUT.srt ] # Check if existing srt exists
    then
      echo "$f"
      $WISP --output_format $FORM --language $LANG --device $DEV --verbose=$VERB "$f"
    else
      echo "Existing sub track: $OUT.srt"
    fi
  done
else
  $WISP --output_format $FORM --language $LANG  --device $DEV --verbose=$VERB "$2"
fi

exit 0
