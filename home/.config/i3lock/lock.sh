#!/bin/bash

PICTURE=${HOME}/Pictures/witcher.png
SCREENSHOT="scrot $PICTURE"

BLUR="5x4"

$SCREENSHOT
convert $PICTURE -blur $BLUR $PICTURE
i3lock -i $PICTURE -t
rm $PICTURER