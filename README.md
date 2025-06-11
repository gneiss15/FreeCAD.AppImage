# FreeCAD.Link.AppImage
### Background
The Original AppImages (both from FreeCAD and realthunder) didn't well when using as a portable (pindrive).
I wrote a wrapper script that makes them fully portable (all data is stored on the pindrive).
But there are still drawbacks:
### Preface
Whenever realthunder publish a new release of his version of FreeCAD (see: [here](https://github.com/realthunder/FreeCAD/releases)), this repository will build a new AppImage that Adjust path inside "${USER_CFG}" to current mount path


###############################################################
# Adjust path inside "${USER_CFG}" to current mount path
###############################################################

while getopts ":u:" option; do
  case $option in
    u) USER_CFG="$OPTARG";;
    *) ;;
  esac
done

if [ -z ${USER_CFG} ]; then
  USER_CFG="~/.config/FreeCAD/link.user.cfg"
fi

sed -i s:/tmp/\.mount_[^/]*/:${HERE}/:g ${USER_CFG}


### Download

Latest: [Download](/../../releases/latest)

All Releases: [Releases](/../../releases)
