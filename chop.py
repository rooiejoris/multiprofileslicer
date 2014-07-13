#Name: chop
#Info: chop a part of the gcode to combine different gcodes with different profiles
#Depend: GCode
#Type: postprocess
#Param: layer(float:30) from which layer is this profile needed
#Param: profile(float:205) size build platform X(mm)

# SPECIAL THANKS TO: jeremie [http://betterprinter.blogspot.fr/2013/02/how-tun-run-python-cura-plugin-without.html]

# see my projects on:
# www.rooiejoris.nl
# www.facebook.com/europerminutedesign
# www.thingiverse.com/joris


import re, math

############ BEGIN CURA PLUGIN STAND-ALONIFICATION ############
# This part is an "adapter" to Daid's version of my original Cura/Skeinforge plugin that
# he upgraded to the lastest & simpler Cura plugin system. It enables commmand-line
# postprocessing of a gcode file, so as to insert the temperature commands at each layer.
#
# Also it is still viewed by Cura as a regular and valid plugin!
#
# To run it you need Python, then simply run it like
#	wood_standalone.py --min minTemp --max maxTemp --grain grainSize --file gcodeFile
# It will "patch" your gcode file with the appropriate M104 temperature change.
#
import inspect
import sys
import getopt
#import math
#import os

def plugin_standalone_usage(myName):
 print "Usage:"
 print "  "+myName+" --fromlayer use the gcode from layer --part which part --file gcodeFile"
 print "  "+myName+" -l fromlayer  -p part -f gcodeFile"
 sys.exit()

try:
	filename
except NameError:
# Then we are called from the command line (not from cura)
# trying len(inspect.stack()) > 2 would be less secure btw
	opts, extraparams = getopt.getopt(sys.argv[1:],'l:p:f:',['fromlayer=','part=','file='])
#	layer = 0
#	part = ""
#	filename="test.g"
	print (opts)

for o,p in opts:
	if o in ['-l','--fromlayer']:
#		print (p)
		fromlayer = int(p)
	elif o in ['-p','--part']:
#		print int(p)
		part = int(p)
	elif o in ['-f','--file']:
#		print (p)
		filename = p
#	filename = 'test.g'
if not filename:
	plugin_standalone_usage(inspect.stack()[0][1])
#	plugin_standalone_usage('test.g')
#
############ END CURA PLUGIN STAND-ALONIFICATION ############


def getValue(line, key, default = None):
		if not key in line or (';' in line and line.find(key) > line.find(';')):
				return default
		subPart = line[line.find(key) + 1:]
		m = re.search('^[0-9]+\.?[0-9]*', subPart)
		if m == None:
				return default
		try:
				return float(m.group(0))
		except:
				return default


layer = 0
e = 0
#if part == 1:
#	removelines = 0
#else: removelines = 1

#with open(filename, "r") as f:
#	lines = f.readlines()

#- remove everything after "fromlayer"  -1 in test_total.gcode
#with open(filename.split('.', 1)[0]+"_total.gcode", "r") as total:
with open("total.gcode", "r") as total:
	lines = total.readlines()
#with open(filename.split('.', 1)[0]+"_total.gcode", "w") as total:
with open("total.gcode", "w") as total:
	removelines = 0
	for line in lines:
#remove all lines after layer -1 in total
#					print("part is 1")
			if ";LAYER:" in line:
				layer = line[7:]

			if int(layer) > int(fromlayer)-1:
				removelines = 1
#					 print("startEffect")

	
#					e = getValue(line, "E", e)		 
#					z = getValue(line, "Z", z)


			if removelines == 0:
#						f.write(line)
				total.write(line)



#with open("test_total.gcode", "a") as total:
#with open(filename.split('.', 1)[0]+"_total.gcode", "a") as total:
with open("total.gcode", "a") as total:
	with open(filename, "r") as f:
		lines = f.readlines()
		removelines = 1
		for line in lines:
				if getValue(line, "E", e) > 0:
					e = getValue(line, "E", e)
				if ";LAYER:" in line:
					layer = line[7:]
				else: layer = -1

				if int(layer) == int(fromlayer):
					removelines = 0
					total.write("+++++++++++++ PROFILE CHANGE +++++++++++++++")
					total.write("\n")
					total.write("G92 ")
					total.write("E%0.4f " %(e))
					total.write("\n")

				if removelines == 0:
					total.write(line)

# write everything in a special out files
#with open("test_total.gcode", "w") as outfile:
#	with open(filename, "rb") as infile:
#		outfile.write(infile.read())
