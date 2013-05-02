#!/bin/sh

if [ "$#" -ne 2 ]; then
  echo "usage: $0 file.brd top.png" 1>&2
  exit 1
fi

/Applications/EAGLE-6.4.0/EAGLE.app/Contents/MacOS/EAGLE -C "RATSNEST; DISPLAY NONE; DISPLAY TOP PADS VIAS DIMENSION TPLACE TNAMES; EXPORT IMAGE ${2} MONOCHROME 600" ${1}
