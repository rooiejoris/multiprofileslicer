# chmod 700 first

set -x
BASE="/werk/ultimaker/scripts/profilecombiner"
cd "${BASE}"/

FILE=test.stl
MAKESTL=false
RESLICE=false

if [ "$MAKESTL" = "true" ]
then
	/Applications/Blender\ 2.70a/blender.app/Contents/MacOS/blender opzet08.blend --background --python convert_blend_to_fbx.py -- temp.obj
	/Applications/meshlab/meshlab.app/Contents/MacOS/meshlabserver -i temp.obj -o temp_small.stl -s ../meshlab_test.mlx
	mv temp_small.stl "${FILE}
fi

PROFILE=profile01

if [ ! -f "${FILE%%.*}${PROFILE}".gcode ] || [ "$RESLICE" = "true" ]
then
		/Applications/Cura/Cura.app/Contents/MacOS/Cura -i "${BASE}"/"${PROFILE}".ini -s "${BASE}"/"${FILE}"
		mv "${FILE}".gcode "${FILE%%.*}${PROFILE}".gcode
fi

#always copy first section to _total.code
#cp "${FILE%%.*}${PROFILE}".gcode "${FILE%%.*}"_total.gcode
cp "${FILE%%.*}${PROFILE}".gcode total.gcode


PROFILE=profile02
FROMLAYER=100

# add a check if "${FILE%%.*}${PROFILE}".gcode exist, if exist AND reslice is false, no slicing is necessary
if [ ! -f "${FILE%%.*}${PROFILE}".gcode ] || [ "$RESLICE" = "true" ]
then
	/Applications/Cura/Cura.app/Contents/MacOS/Cura -i "${BASE}"/"${PROFILE}.ini" -s "${BASE}"/"${FILE}"
	mv "${FILE}".gcode "${FILE%%.*}${PROFILE}".gcode
fi
python chop.py -l "${FROMLAYER}" -f "${FILE%%.*}${PROFILE}".gcode



PROFILE=profile01
FROMLAYER=300

if [ ! -f "${FILE%%.*}${PROFILE}".gcode ] || [ "$RESLICE" = "true" ]
then
	/Applications/Cura/Cura.app/Contents/MacOS/Cura -i "${BASE}"/"${PROFILE}.ini" -s "${BASE}"/"${FILE}"
	mv "${FILE}".gcode "${FILE%%.*}${PROFILE}".gcode
fi
python chop.py -l "${FROMLAYER}" -f "${FILE%%.*}${PROFILE}".gcode



# test string for command line
#python chop.py -l 15 -f test01.gcode

