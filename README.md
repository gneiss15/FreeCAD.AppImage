# FreeCAD.AppImage
### Download
Latest: [Download](/../../releases/latest)\
All Releases: [Releases](/../../releases)
### Preface
Whenever FreeCAD publish a new release of FreeCAD (see: [here](https://github.com/FreeCAD/FreeCAD/releases), this repository will build a new AppImage that Adjust path inside "${USER_CFG}" to current mount path
### Using
- Copy the files inside subfolder "ForPenDrive" to a Dir an Your PenDrive.
- Copy an AppImage (from Releases) into the same Dir.
- Make the AppImage executable (chmod a+x).
- There MUST be only one executable AppImage inside Your Dir that matches the pattern "${EXE_SEARCH}*.AppImage".\
  (EXE_SEARCH is "FreeCAD-Link-" for Link/realthunder and "FreeCAD-Orig-" for Original FreeCAD)
- On the system that is used for the AppImage, meld should be installed (or Change the var MELD inside _Start.sh)
- By modifing the Config settings inside _Start.sh You may change the behaviour of the script.
- The file OpenSCADAppimageStart.sh may be used to start OpenSCAD from within FreeCAD (the OpenSCAD AppImage must be in the same Dir)
### Background
The Original AppImages (both from FreeCAD and Link/realthunder) didn't well when used on a portable (PenDrive).\
I wrote a wrapper script that makes them fully portable (all data is stored on the PenDrive).\
This wrapper primary adjust the path inside "${USER_CFG}" to the current mount path of the PenDrive and (optional) save the config-files.\
The script Start_Link-Daily.sh will start an executable "FreeCAD-Link-*.AppImage", the script Start_FreeCad.sh will start an executable "FreeCAD-Orig-*.AppImage".\
So You may place both versions inside one dir. The script enshures that the configurations are seperated.\
Because this is not enougth to make the AppImage fully portable, I have to modify AppRun inside the AppImage.\
This is done by this repository.\

### There is still (at least) one drawback:
The path to fonts used in Shapestring (or similar) are stored inside the FCSTD-file.\
I found no way to intercept file->open and adjust the path to the current mount path (tmp mount of AppImage)

