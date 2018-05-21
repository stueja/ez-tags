#!/bin/bash

# ez-tags
# 
# exiftool and zenity provide easy access to changing EXIF and IPTC tags
# Jan Stuehler, 2018

# inspired by: ExZenToo by kjoe, ~2013
# http://u88.n24.queensu.ca/exiftool/forum/index.php/topic,4715.0.html

# flow:
# - script called with parameter (path to image)
# - check if file exists and is writable
# - read IPTC tag "keywords" and EXIF tag "comment" from image
# -- probably needed:
# -- 1. split by ","
# -- 2. remove leading and trailing whitespace
# -- 3. display
# - display a text box containing existing tags, if any, allowing for additional tags
# - upon "Enter", convert a single comma "," and semicolon ";" to comma followed by space ", "
# - save the value in IPTC "keywords" and EXIF "comment"

# zenity, up to now, does not provide an element to show a picture in. Also, I would
# have to create some sort of navigation.
# Geeqie, an image
# editor, provides support for so-called plugins. I hope that I can use Geeqie to show
# the image, press a key, maybe F3, enter tags and save them easily.
# Setup Geeqie
# To use ez-tags as a plugin to Geeqie, Geeqie needs to be configured via
# Edit > Configure Plugins > New
# At least edit the line beginning with "Exec":
# Exec=/home/jan/Documents/Scripte/ez-tags.sh -p %f
# and maybe the line "Name":
# Name=ez-tags
# and save. 

# In Geeqie, use "Edit > Preferences > Keyboard", find the plugin (ez-tags), and assign
# a hotkey to it, maybe F3

progname=$(basename $0)
usage="Usage:\t$progname -p path [-t] [-v]\n\t$progname -h"



while getopts "p:tvh" options ; do
  case $options in
    p) IncomingPath="$OPTARG" ;;
    t) TESTFLAG="-t" ;;
    v) VERBOSE="-v" ;;
    h) echo -e $usage ; exit ;;
  esac
done



if [[ ! -w "$IncomingPath" ]] 
then
	echo "file $IncomingPath not found or not writable"
	exit 2
fi


# mandatory programs
for NEEDED in exiftool logger zenity
do
	command -v $NEEDED >/dev/null 2>&1
	if [[ $? -ne 0 ]]
	then
		echo "$NEEDED not installed"
		logger -p alert -t ez-tags $0 "needed program $NEEDED not found -- exiting"
		exit 3
	fi
done


function zenity(){
    /usr/bin/zenity "$@" 2>/dev/null
}


# IPTC:Keywords (0-64 char)
# writing:
# https://www.sno.phy.queensu.ca/~phil/exiftool/faq.html#Q17
# exiftool -sep ", " -keywords="one, two, three" img.jpg
# exiftool -sep ", " -comment="one, two, three" img.jpg

# reading:
# https://photo.stackexchange.com/a/56678
# exiftool -s3 -keywords img.jpg

Separator=", "

ReadKeywords=$(exiftool -s3 -keywords "$IncomingPath")
ReadComment=$(exiftool -s3 -comment "$IncomingPath")

file="$(dirname $0)/ez-tags.preset"
echo "reading $file"
if [[ -f "$file" ]]
then
	while read -r line; do
		[[ "$line" =~ ^#.*$ ]] && continue
		DefaultKeywords="$line${Separator}"
	done < "$file"
fi

if [[ ! "$ReadKeywords" == "" ]]
then
	ReadKeywords=$ReadKeywords${Separator}
fi

if [[ ! "$ReadComment" == "" ]]
then
	ReadComment=$ReadComment${Separator}
fi

Line1=$(echo ${ReadKeywords}${ReadComment}${DefaultKeywords} | tr "," "\n")
echo $Line1
for e in "${Line1[@]}"
do
	tk=$(echo "$e" | awk '{$1=$1};1')
	tokens+=("$tk")
done
#Line3=$(echo "$Line1" | sort | uniq)
#echo "$Line3"
CommentsLine=$(echo "$tokens" | sort | uniq | perl -pe "s/\n/$Separator/g")

# https://stackoverflow.com/a/45201229
#echo ${ReadKeywords}${ReadComment}${TestKeywords} | sed "s/$Separator/\n/g" | sort | uniq | sed "s/\n/$Separator/g"
#CommentsLine=$(echo "${ReadKeywords}${ReadComment}${TestKeywords}" | sed "s/$Separator/\n/g" | sort | uniq | perl -pe  "s/\n/$Separator/g") | sed -e 's/^[ ,]*//;s/[, ]*$//' 
echo $CommentsLine

NewTags=$(zenity --entry --title="ez-tags" --ok-label="Save" --cancel-label="Abort" --width="300" --text="Edit image tags" --entry-text="${CommentsLine}" )
if [[ $? -eq 0 ]]
then
	echo $NewTags

	CorrectedTags=$(echo $NewTags | perl -pe "s/,(?! )/$Separator/g")
	echo $CorrectedTags


	exiftool -sep ", " -keywords="${CorrectedTags}" "$IncomingPath"
	exiftool -sep ", " -comment="${CorrectedTags}" "$IncomingPath"
else
	echo "aborted."
fi
