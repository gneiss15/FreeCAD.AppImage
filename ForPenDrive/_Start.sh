#set -o xtrace

###############################################################
# Config
###############################################################
SHOW_VARS_ONLY="n"	# Set to anything != "n" to only show the Vars and exit

DO_MELD="n"		# Set to anything != "n" to enable compare of cuser.cfg changed due to mount path change
DOBACKGROUND="y"	# Call Freecad in Background (with nohup)

SAVE_USER_B="y"		# Set to anything != "n" to enable save of user.cfg at start of script
SAVE_USER_A="n"		# Set to anything != "n" to enable save of user.cfg after path change
SAVE_SYSTEM_A="n"	# Set to anything != "n" to enable save of system.cfg after path change
SAVE_CONF_FILE="n"	# Set to anything != "n" to enable save of FreeCAD.conf at start of script

CREATE_LOG=		# Set to -l to enable logging (CREATE_LOG=-l)

MELD="meld"		# tool used for comparsion

###############################################################
# Log Infos
###############################################################
#echo "FreeCad" ${APPDIR} >${APPDIR}/FreeCadStart.log
#echo " APPDIR:" ${APPDIR} >>${APPDIR}/FreeCadStart.log
#echo " PWD:" ${PWD} >>${APPDIR}/FreeCadStart.log
#echo " LD_LIBRARY_PATH:" ${LD_LIBRARY_PATH} >>${APPDIR}/FreeCadStart.log
#echo " PATH:" ${PATH} >>${APPDIR}/FreeCadStart.log

###############################################################
# Install Icon if not already installed
###############################################################
if [ ! -f ~/.local/share/icons/hicolor/48x48/apps/FreeCad.png ]; then
  xdg-icon-resource install --novendor --context apps --size 48 FreeCad.png
fi

###############################################################
# Determine exe
###############################################################
EXE=$(find . -maxdepth 1 -executable -name "${EXE_SEARCH}*.AppImage")
EXE_CNT=$(find . -maxdepth 1 -executable -name "${EXE_SEARCH}*.AppImage" | grep -c ".AppImage")
if [ ${EXE_CNT} -ne 1 ]; then 
  read -p "Invaid # of AppImages found: ${EXE_CNT}"
  exit
fi

###############################################################
# Set Vars
###############################################################

# Start_FreeCad.sh ############################################
#EXE_SEARCH="FreeCAD_weekly"
# Settings/user.cfg & Settings/system.cfg
#USER_CFG_FILE="user.cfg"
#SYSTEM_CFG_FILE="system.cfg"
#CFG_REL_PATH=""

# Start_Link-Daily.sh #########################################
#EXE_SEARCH="FreeCAD-asm3-Daily-"
# Settings/.FreeCAD/link.user.cfg & Settings/.FreeCAD/link.system.cfg
#USER_CFG_FILE="link.user.cfg"
#SYSTEM_CFG_FILE="link.system.cfg"
#CFG_REL_PATH=".FreeCAD/"

SETTINGSDIR="${APPDIR}/Settings"
USER_CFG="${SETTINGSDIR}/${CFG_REL_PATH}${USER_CFG_FILE}"
SYSTEM_CFG="${SETTINGSDIR}/${CFG_REL_PATH}${SYSTEM_CFG_FILE}"

# Settings/.config/FreeCAD/FreeCAD.conf
CONF_FILE="FreeCAD.conf"
CONF_REL_PATH=".config/FreeCAD"

SAVE_DIR="${SETTINGSDIR}/Save/${SAVE_REL_PATH}"

###############################################################
# Create Dirs
###############################################################

mkdir -p "${SETTINGSDIR}"
mkdir -p "${SETTINGSDIR}/${CFG_REL_PATH}"
mkdir -p "${SAVE_DIR}"

###############################################################
# Calculate Save-FileNames
#
# Names: <nr>.<cfg-name>_<id>
# nr := running number
# id:
#	B: Before 'Adjust path...'
#	A: After  'Adjust path...' (only if path has changed)
###############################################################

# $1: Cfg-File-Name (without path)
# $2: Extension
# $3: Start-Number
FindSaveNr() {
  local nr=${3}
  while [ -f "${SAVE_DIR}/${nr}.${1}_${2}" ]; do
    nr=$(expr ${nr} + 1)
  done
  echo ${nr}
}

SAVE_NR=$(FindSaveNr "${USER_CFG_FILE}" 	"B" 1)		# B: Before 'Adjust path...' (only if path has changed)
SAVE_NR=$(FindSaveNr "${USER_CFG_FILE}"		"A" ${SAVE_NR})	# A: After  'Adjust path...'
SAVE_NR=$(FindSaveNr "${SYSTEM_CFG_FILE}"	"A" ${SAVE_NR})	# A: After  'Adjust path...'
SAVE_NR=$(FindSaveNr "${CONF_FILE}"		""  ${SAVE_NR})	#  : FreeCAD.conf

if [ "${SHOW_VARS_ONLY}" != "n" ]; then
  echo "APPDIR:          ${APPDIR}"
  echo "SETTINGSDIR:     ${SETTINGSDIR}"
  echo "USER_CFG:        ${USER_CFG}"
  echo "USER_CFG_FILE:   ${USER_CFG_FILE}"
  echo "SYSTEM_CFG:      ${SYSTEM_CFG}"
  echo "CONF_FILE:       ${CONF_FILE}"
  echo "CONF_REL_PATH:   ${CONF_REL_PATH}"
  echo "SAVE_DIR:        ${SAVE_DIR}"
  echo "SAVE_NR:         ${SAVE_NR}"
  echo "SYSTEM_CFG_FILE: ${SYSTEM_CFG_FILE}"
  echo "Sys-Call:"
  echo HOME="${SETTINGSDIR}" FREECAD_USER_HOME="${SETTINGSDIR}" nohup "${EXE}" -u "${USER_CFG}" -s "${SYSTEM_CFG}" ${CREATE_LOG}

  #echo ": ${}"
  exit
fi

###############################################################
# Check for invalid entries in "${USER_CFG}"
###############################################################

if grep "<<" "${USER_CFG}" >/dev/null; then
  echo "invalid entries in \"${USER_CFG}\""
  read -s -n 1 -p "press any key to continue"</dev/tty
  echo

  sed -e 's/<<//g' -e 's/>>//g' "${USER_CFG}" >"${USER_CFG}.tmp"
  meld "${USER_CFG}" "${USER_CFG}.tmp"

  echo -n "Right Side OK ?"
  res=""
  while [ "$res" != "Y" ] && [ "$res" != "N" ]; do
    echo
    read -s -n 1 -p "Enter y or n (Yes or No)" res</dev/tty
    res="$(echo $res | tr a-z A-Z)"
  done
  
  if [ "$res" != "Y" ]; then
    exit
  fi
  
  rm "${USER_CFG}"
  mv "${USER_CFG}.tmp" "${USER_CFG}"
fi

###############################################################
# Adjust path inside "${USER_CFG}" to current mount path
# and
# Save config-files
###############################################################

# Escape '/' and '.' inside ${1} into '\/' and '\.'
Escape()
 {
  local res
  res=${1//\//\\\/}; 
  res=${res//\./\\\.};
  echo "${res}"
 }

GetYesNo()
 {
  local res
  while true; do
    read -p "${1}? (y/n):" res
    [[ ${res} != [yYnN] ]] || break
    echo "Please enter Y or N" 
  done
  [[ ${res} == [yY] ]]
 }

if [ -f "${USER_CFG}" ]; then
  LAST_MOUNT_PATH=$(Escape "$(sed -e '/^.*<FCText Name=.*>.*\/Portables\/FreeCad\//!d;s:^.*<FCText Name=[^>]*>\(.*\)/Portables/.*:\1:g;q' ${USER_CFG})")
  CURRENT_MOUNT_PATH=$(Escape "$(readlink -f -- ${APPDIR} | sed -e "s:\(.*\)/Portables/.*:\1:g")")

  #echo "LAST_MOUNT_PATH: ${LAST_MOUNT_PATH}"
  #echo "CURRENT_MOUNT_PATH: ${CURRENT_MOUNT_PATH}"

  if [ \( -n "${LAST_MOUNT_PATH}" \) -a \( "${LAST_MOUNT_PATH}" != "${CURRENT_MOUNT_PATH}" \) ]; then
    sed -e "s:${LAST_MOUNT_PATH}:${CURRENT_MOUNT_PATH}:g" "${USER_CFG}" >"${USER_CFG}.tmp"
    if [ "${DO_MELD}" != "n" ]; then
      meld "${USER_CFG}" "${USER_CFG}.tmp"
      if ! GetYesNo "New CFG OK"; then
        rm "${USER_CFG}.tmp"
        exit 
      fi
    fi

    # SAVE_USER_B
    if [ "${SAVE_USER_B}" != "n" ]; then
      mv "${USER_CFG}" "${SAVE_DIR}/${SAVE_NR}.${USER_CFG_FILE}_B"
     else
      rm "${USER_CFG}"
    fi
    mv "${USER_CFG}.tmp" "${USER_CFG}"
  fi

  # SAVE_USER_A
  if [ "${SAVE_USER_A}" != "n" ]; then
    cp "${USER_CFG}" "${SAVE_DIR}/${SAVE_NR}.${USER_CFG_FILE}_A"
  fi

  # SAVE_SYSTEM_A
  if [ "${SAVE_SYSTEM_A}" != "n" ]; then
    cp "${SYSTEM_CFG}" "${SAVE_DIR}/${SAVE_NR}.${SYSTEM_CFG_FILE}_A"
  fi

  # SAVE_CONF_FILE
  if [ "${SAVE_CONF_FILE}" != "n" ]; then
    cp "${SETTINGSDIR}/${CONF_REL_PATH}/${CONF_FILE}" "${SAVE_DIR}/${SAVE_NR}.${CONF_FILE}"
  fi
fi

###############################################################
# Start FreeCAD
###############################################################

#XAUTHORITY=$HOME/.Xauthority 

#  -u [ --user-cfg ] arg     User config file to load/save user settings
#  -s [ --system-cfg ] arg   System config file to load/save system settings
if [ "${DOBACKGROUND}" != "y" ]; then
  HOME="${SETTINGSDIR}" FREECAD_USER_HOME="${SETTINGSDIR}" "${EXE}" -u "${USER_CFG}" -s "${SYSTEM_CFG}" ${CREATLOG}
 else
  #-rm -f nohup.out
  #HOME="${SETTINGSDIR}" FREECAD_USER_HOME="${SETTINGSDIR}" nohup "${EXE}" -u "${USER_CFG}" -s "${SYSTEM_CFG}" ${CREATLOG} & >/dev/null
  HOME="${SETTINGSDIR}" FREECAD_USER_HOME="${SETTINGSDIR}" nohup "${EXE}" -u "${USER_CFG}" -s "${SYSTEM_CFG}" ${CREATLOG} >"nohup.out" 2>&1 &
  sleep 2
fi
