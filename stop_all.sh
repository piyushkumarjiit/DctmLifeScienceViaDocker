#!/bin/bash
#Author: Piyush Kumar (piyushk@opentext.com)

#Identify if it is Ubuntu or Centos/RHEL
distro=$(cat /etc/*-release | awk '/ID=/ { print }' | head -n 1 | awk -F "=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')
DCTM_VERSION=$1
DCTM_PATCH_VERSION=$2
echo "ENV DCTM_VERSION: "$DCTM_VERSION
echo "ENV DCTM_PATCH_VERSION: "$DCTM_PATCH_VERSION
DCTM_DEFAULT_VERSION=166
#Set DCTM_VERSION if not available from environment.
if [[ -z $DCTM_VERSION ]]
then
	temp_version=""
	#Find all YAML Files in current directory
	for yaml_file in  $(ls ./*.[Yy]*[Ll]);
	do
		echo "Processing: $yaml_file"
		
		if [[ $(echo $yaml_file | grep xplore > > /dev/null 2>&1; echo $?) == 0 ]]
		then
			DCTM_VERSION=$( echo $yaml_file | awk -F "." '{print $2}' | awk -F "_" '{print $6}' )
			#If you want to extract the numerical part of the DCTM_VERSION use below command
			#echo $yaml_file | awk -F "." '{print $2}' | awk -F "_" '{print $6}' | awk -F [[:alpha:]] '{print $1}'
			echo "For xPlore YAML File. "$DCTM_VERSION
		else
			DCTM_VERSION=$( echo $yaml_file | awk -F "." '{print $2}' | awk -F "_" '{print $5}' )
			echo "For Normal YAML Compose Files. "$DCTM_VERSION
		fi

		# if [[ -z $DCTM_PATCH_VERSION ]]
		# then
		# 	DCTM_VERSION=$( echo $yaml_file | awk -F "." '{print $2}' | sed 's/.*\(...\)/\1/')
		# 	echo "In Patch processing. "$DCTM_VERSION
		# else
		# 	DCTM_VERSION=$( echo $yaml_file | awk -F "." '{print $2}' | sed 's/.*\(....\)/\1/')
		# 	echo "In Normal processing. "$DCTM_VERSION
		# fi
		
		echo "DCTM_VERSION: "$DCTM_VERSION" while TEMP_VERSION: "$temp_version
		if [[ ( -n $temp_version) && ($temp_version != $DCTM_VERSION)]]
		then
			echo "YAML Files with multiple versions seem to be present. Setting Default DCTM_VERSION value to $DCTM_DEFAULT_VERSION. Exiting."
			DCTM_VERSION=$DCTM_DEFAULT_VERSION
			break;
		fi
		temp_version=$DCTM_VERSION
	done
else
	echo "Seems to have Value: "$DCTM_VERSION
fi

echo "Using DCTM Version: $DCTM_VERSION and Distro: $distro and Patch: $DCTM_PATCH_VERSION"

#DCTM_IMAGE_IDS="e36e66548d7b a69e22cfbcde 3f94b614b8ae 470d167a1f89 7d99c80f6d0f 0e8361f2565c e3b6ce03c407 028e0d6d5196 c14a575fed0e e8ffe74e4e1a 05e6ff1aa030 f6a72d6f0a1c 2a440282b925 d7c36d63c55c ea79c91d42bb 7bf64a664362 b0855b1483ec 6d2b3d545600 b993fca07adc 0846eef15a7c a2dcda4c3f4d 5e497111358e 6b8c7ef27448 1c15c7933c43 81d17b332e36 aad0149c2303 fe5a6caa7cd8 55b3025a1307 70d360bc8d7c"
DCTM_IMAGE_IDS=$(docker images | awk -F " " '{print $3}' | sed "s#IMAGE##g")
#DCTM_EXTERNAL_VOLUMES="ichigo_lsd2repo1_data ichigo_postgres_db_data ichigo_xcp-extra-dars ichigo_xplore"
DCTM_EXTERNAL_VOLUMES=$(docker volume ls | awk -F " " '{print $2}' | sed "s#VOLUME##g")
#Folders created by script to store data/logs in volumes
DCTM_EXTERNAL_FOLDERS="lsd2repo1_data lsd2repo1_xplore postgres postgres_db_data xcp-extra-dars logs"

# if [[ -z DCTM_PATCH_VERSION ]]
# then 
# 	BPM_COMPOSE_FILE=$(pwd)"/bpm_compose_"$distro"_updated_"$DCTM_VERSION".yml"
# 	echo "BPM: "$BPM_COMPOSE_FILE
# 	D2LS_COMPOSE_FILE=$(pwd)"/lsd2_compose_"$distro"_updated_"$DCTM_VERSION".yml"
# 	echo "LS: "$D2LS_COMPOSE_FILE
# 	D2LS_XPLORE_COMPOSE_FILE=$(pwd)"/lsd2_compose_"$distro"_updated_xplore_"$DCTM_VERSION".yml"
# 	echo "Xplore: "$D2LS_XPLORE_COMPOSE_FILE
# else
	# BPM_COMPOSE_FILE="bpm_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	# D2LS_COMPOSE_FILE="lsd2_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	# D2LS_XPLORE_COMPOSE_FILE="lsd2_compose_"$distro"_updated_xplore_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	#We no longer need patch we get the entire string including patch as DCTM_VERSION
	BPM_COMPOSE_FILE="bpm_compose_"$distro"_updated_"$DCTM_VERSION".yml"
	D2LS_COMPOSE_FILE="lsd2_compose_"$distro"_updated_"$DCTM_VERSION".yml"
	D2LS_XPLORE_COMPOSE_FILE="lsd2_compose_"$distro"_updated_xplore_"$DCTM_VERSION".yml"
	DFS_COMPOSE_FILE="dfs_compose_"$distro"_updated_"$DCTM_VERSION".yml"
#fi

#Bring the services down.
echo "Bringing the services down."
docker-compose -f $DFS_COMPOSE_FILE down
docker-compose -f $D2LS_XPLORE_COMPOSE_FILE down
docker-compose -f $D2LS_COMPOSE_FILE down
docker-compose -f $BPM_COMPOSE_FILE down

while true; 
	do
		read -p "Do you want to Delete Container Volumes? (Yes/No): " user_reply
		case $user_reply in
			#Deleting DCTM Container Volumes
			[Yy]*) 	echo "Deleting DCTM Container Volumes."
					docker volume rm $DCTM_EXTERNAL_VOLUMES
					docker volume prune
					echo "DCTM Container Volumes Deleted."
					sleep 2
					break;;
			
			#Not Deleting DCTM Container Volumes
			[Nn]*) 	echo "Not Deleting DCTM Container Volumes."
					sleep 2
					break;;
			
			* ) 	echo "Please answer Yes or No."
		esac
	done
			
while true; 
	do
		read -p "Do you want to Delete External Folders used by Containers? (Yes/No): " user_reply
		case $user_reply in
			#Deleting DCTM External Folders
			[Yy]*) 	echo "Deleting DCTM External Folders."
					sudo rm -r $DCTM_EXTERNAL_FOLDERS
					echo "DCTM External Folders Deleted. Removing YAML files."
					sudo rm $D2LS_XPLORE_COMPOSE_FILE $D2LS_COMPOSE_FILE $BPM_COMPOSE_FILE $DFS_COMPOSE_FILE stop_LS.sh start_LS.sh
					sleep 2
					break;;
					
			#Not Deleting DCTM Container Volumes
			[Nn]*) 	echo "Not Deleting DCTM Container Volumes."
					sleep 2
					break;;
					
			* ) echo "Please answer Yes or No."
		esac
	done

while true; 
	do
		read -p "Do you want to Delete DCTM Images used by Containers? (Yes/No): " user_reply
		case $user_reply in
			#Deleting DCTM Images
			[Yy]*) 	echo "Deleting DCTM Images."
					docker rmi -f $DCTM_IMAGE_IDS
					echo "DCTM Images Deleted."
					sleep 2
					break;;
					
			#Not Deleting DCTM Images
			[Nn]*) 	echo "Not Deleting DCTM Images."
					sleep 2
					break;;	
					
			* ) echo "Please answer Yes or No."
		esac
	done

echo "All Done."	

#docker rmi -f 70d360bc8d7c 55b3025a1307 fe5a6caa7cd8 aad0149c2303 81d17b332e36 1c15c7933c43 6b8c7ef27448 5e497111358e a2dcda4c3f4d 0846eef15a7c b993fca07adc