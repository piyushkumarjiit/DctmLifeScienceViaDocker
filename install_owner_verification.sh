#!/bin/bash
echo "Starting Install Owner Account confirmation for $1 in $HOSTNAME"
#Check that install Owner User Account exists. Add if missing.
#user_exists=$(id -u $INSTALL_OWNER > /dev/null 2>&1; echo $?)
# if [[ $user_exists == "1" ]]
# then
	# echo "Adding user: $INSTALL_OWNER"
	# useradd -m -p $INSTALL_OWNER_PASSWORD $INSTALL_OWNER
	# INSTALL_OWNER_UID=$(cat /etc/passwd | grep $INSTALL_OWNER | awk -F ":" '{print $3}')
	# export INSTALL_OWNER_UID=$INSTALL_OWNER_UID
	# echo "User created for " $INSTALL_OWNER " with UID:" $INSTALL_OWNER_UID
	# echo $INSTALL_OWNER_UID
	
# else
	# echo "User $INSTALL_OWNER exists!! Continuing without adding."
# fi


user_exists=$(id -u $1 > /dev/null 2>&1; echo $?)
if [[ $user_exists == "1" ]]
then
	echo "Adding user"
	#user_passwd=$(openssl passwd -crypt $2)
	user_passwd=$2
	useradd -m -p $user_passwd $1
	INSTALL_OWNER_UID=$(cat /etc/passwd | grep $1 | awk -F ":" '{print $3}')
	export INSTALL_OWNER=$1
	export INSTALL_OWNER_PASSWORD=$2
	export INSTALL_OWNER_UID=$INSTALL_OWNER_UID
	echo "User: "$INSTALL_OWNER" created with password: "$INSTALL_OWNER_PASSWORD " and UID:" $INSTALL_OWNER_UID
	#echo $INSTALL_OWNER_UID
	
else
	echo "User $1 exists!! Continuing without adding."
fi

