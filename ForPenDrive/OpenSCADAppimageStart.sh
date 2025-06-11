#!/usr/bin/env bash

FREECAD_APPDIR="$(dirname -- "$(readlink -f -- "${0}")" )"
APPDIR="$FREECAD_APPDIR/../OpenSCAD"

###############################################################
# Log Infos
###############################################################
#echo "OpenSCAD" >$FREECAD_APPDIR/OpenSCADAppimageStart.log
#echo " APPDIR:" $APPDIR >>$FREECAD_APPDIR/OpenSCADAppimageStart.log
#echo " PWD:" $PWD >>$FREECAD_APPDIR/OpenSCADAppimageStart.log
#echo " LD_LIBRARY_PATH:" $LD_LIBRARY_PATH >>$FREECAD_APPDIR/OpenSCADAppimageStart.log
#echo " PATH:" $PATH >>$FREECAD_APPDIR/OpenSCADAppimageStart.log

###############################################################
# Determine exe
###############################################################
EXE=$(find "$APPDIR" -maxdepth 1 -executable -name "OpenSCAD*.AppImage")
EXE_CNT=$(find "$APPDIR" -maxdepth 1 -executable -name "OpenSCAD*.AppImage" | grep -c ".AppImage")
if [ $EXE_CNT -ne 1 ]; then 
  read -p "Invaid # of AppImages found: $EXE_CNT"
  exit
fi

#echo " Cmd: " ${EXE} $* >"$APPDIR"/StartOpenSCADAppimage.log

###############################################################
# Start OpenSCAD
###############################################################
unset LD_LIBRARY_PATH
exec "${EXE}" $*

