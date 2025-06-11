#!/usr/bin/env bash

APPDIR="$(dirname -- "$(readlink -f -- "${0}")" )"

cd ${APPDIR}
export PATH=$PATH:${APPDIR}

###############################################################
# Set Vars
###############################################################

EXE_SEARCH="FreeCAD-Link-"
# Settings/.FreeCAD/link.user.cfg & Settings/.FreeCAD/link.system.cfg
USER_CFG_FILE="link.user.cfg"
SYSTEM_CFG_FILE="link.system.cfg"
CFG_REL_PATH=""
SAVE_REL_PATH="Link"

. _Start.sh

