#!/bin/bash
current_dir() {
pwd|rev|awk -F \/ '{print $1}'|rev
}

generate_ideC() {
echo "$ide_name=$PWD flags=Sr filter=\"*.c*.cc*.cpp*.h*.hpp*.hh*.inl\" {" > $ide_file
find . -iname "*.hpp" -o -iname "*.hh" -o -iname "*.h" -o -iname "*.cpp" -o -iname "*.cc" -o -iname "*.c" -o -iname "*.inl" >> $ide_file
echo "}" >> $ide_file
}

if [ $# -eq 0 ]; then
ide_count=$(find . -iname "*.ide" | grep ".ide" -c)
if [ $ide_count -eq 0 ]; then
	echo "INFO: Inferring ide project name from the current directory name"
	ide_name=$(current_dir)
else 
	ide_file=$(find . -iname "*.ide")
	ide_name=$(find . -iname "*.ide" | sed 's/\(.*\)\.ide/\1/')
	if [ $ide_count -eq 1 ]; then
		echo "INFO: retrieving ide project on folder "
	else
		echo "ERR: $ide_count ide projects exist on the folder, specify either"
		echo $ide_name
		exit
	fi
fi
else
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
	echo "Usage:"
	echo "  ide"
	echo "  ide <project-file>"
	echo "Description:"
	echo "  Creates a new project-file and loads it into gvim. The project"
	echo "  created contains all C/C++ files in the current folder and all"
	echo "  traversable folders. By default the newly created project has"
	echo "  the extension '.ide'"
	echo "Details:"
	echo "  This script is usefull when creating a project out of a complex"
	echo "  source code structure, a somehow simpler approach can be achieved"
	echo "  by typing into a file"
	echo "    main=. flags=Sr filter=\"*.c*.cc*.cpp*.h*.hpp*.hh*.inl\" {" 
	echo "    }"
	echo "  loading it into the IDE and then pressing '\r' followed by '<F2>'"
	exit
else
	ide_name=$1
fi
fi
ide_file="$ide_name.ide"

echo "ide name: $ide_name"
echo "ide file: $ide_file"

if [ -f $ide_file ]; then
echo "Loading ide file"
gvim -c "IDE $ide_file"
else
echo "Generating IDE project file"
generate_ideC
if [ -f $ide_file ]; then
	echo "Loading ide project file"
	gvim -c "IDE $ide_file"
else
	echo "Failed. Aborting execution."
fi
fi


