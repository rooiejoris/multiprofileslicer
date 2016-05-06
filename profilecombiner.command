#sudo chmod +x profilecombiner*.command 
#chmod 700 first on mac

set -x
BASE="/werk/ultimaker/scripts/profilecombiner"
#BASE="/werk/fhvbbdo/3d design"
cd "${BASE}"/

FILE=test.stl
#FILE="column-04B_.stl"
FILE="column-04C_.stl"
MAKESTL=false
RESLICE=false

if [ "$MAKESTL" = "true" ]
then
	/Applications/Blender\ 2.70a/blender.app/Contents/MacOS/blender "${FILE%%.*}".blend --background --python convert_blend_to_obj.py -- temp.obj
#	/Applications/meshlab/meshlab.app/Contents/MacOS/meshlabserver -i temp.obj -o temp_small.stl -s ../meshlab_test.mlx
	/Applications/meshlab/meshlab.app/Contents/MacOS/meshlabserver -i elephant.stl -o elephant_small.stl -s meshlab_test.mlx
	mv temp_small.stl "${FILE}"
fi

#PROFILE=profile01
PROFILE=support-bottom

if [ ! -f "${FILE%%.*}${PROFILE}".gcode ] || [ "$RESLICE" = "true" ]
then
		/Applications/Cura/Cura.app/Contents/MacOS/Cura -i "${BASE}"/profiles/"${PROFILE}".ini -s "${BASE}"/"${FILE}"
		mv "${FILE}".gcode "${FILE%%.*}${PROFILE}".gcode
fi

#always copy first section to _total.code
#cp "${FILE%%.*}${PROFILE}".gcode "${FILE%%.*}"_total.gcode
cp "${FILE%%.*}${PROFILE}".gcode total.gcode

function chop {
	# add a check if "${FILE%%.*}${PROFILE}".gcode exist, if exist AND reslice is false, no slicing is necessary
	if [ ! -f "${FILE%%.*}${PROFILE}".gcode ] || [ "$RESLICE" = "true" ]
	then
		/Applications/Cura/Cura.app/Contents/MacOS/Cura -i "${BASE}"/profiles/"${PROFILE}".ini -s "${BASE}"/"${FILE}"
		mv "${FILE}".gcode "${FILE%%.*}${PROFILE}".gcode
	fi
	python chop.py -l "${FROMLAYER}" -f "${FILE%%.*}${PROFILE}".gcode
}


#PROFILE=infill
#FROMLAYER=265

#chop

PROFILE=spiralize
FROMLAYER=515

chop

PROFILE=infill
FROMLAYER=1355

chop

PROFILE=spiralize
FROMLAYER=1595

chop

PROFILE=infill
FROMLAYER=2900

chop


mv total.gcode "${FILE%%.*}"total.gcode

#TimeEstimateCalc.command "${FILE%%.*}"total.gcode


# test string for command line
#python chop.py -l 15 -f test01.gcode

