#!/bin/bash
echo "Starting SSV Configuration in $HOSTNAME"
#Check that install Owner User Account exists. Add if missing.
mount_exists=$(cd $1 > /dev/null 2>&1; echo $?)
if [[ $mount_exists == "1" ]]
then
	echo "Creating Directory for SSV Filestore mounting"
	mkdir $1
	mount -t cifs -o username=$3,password=$4 $2  $1
	echo "Created Directory $1 and mounted $2 for SSV Filestore mounting."
else
	echo "Directory $1 exists!! Trying to mount on existing directory."
	mount -t cifs -o username=$3,password=$4 $2  $1
fi
object_count=$(ls $1 | wc -l)
if [[ object_count == "0" ]]
then
	echo "Mounted path seems empty. Please manually verify."
fi