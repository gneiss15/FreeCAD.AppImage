#!/usr/bin/env bash

APPDIR="$(dirname -- "$(readlink -f -- "${0}")" )"

cd ${APPDIR}
export PATH=$PATH:${APPDIR}

###############################################################
# Set Vars
###############################################################

EXE_SEARCH="FreeCAD-Orig-"
# Settings/user.cfg & Settings/system.cfg
USER_CFG_FILE="user.cfg"
SYSTEM_CFG_FILE="system.cfg"
CFG_REL_PATH=""
SAVE_REL_PATH="FreeCad"

. _Start.sh

