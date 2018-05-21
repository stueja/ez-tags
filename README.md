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


