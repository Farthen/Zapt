#!/bin/sh

MASTER=$1

cp $MASTER Icon-1024.png
convert $MASTER -resize 80x80 Icon-iPhone-Spotlight-40@2x.png
convert $MASTER -resize 120x120 Icon-iPhone-AppIcon-60@2x.png

convert $MASTER -resize 40x40 Icon-iPad-Spotlight-40.png
convert $MASTER -resize 80x80 Icon-iPad-Spotlight-40@2x.png
convert $MASTER -resize 76x76 Icon-iPad-AppIcon.png
convert $MASTER -resize 152x152 Icon-iPad-AppIcon.png@2x.png
