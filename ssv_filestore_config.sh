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
	echo "Directory $1 exists!! Continuing without adding. Please add manually."
fi