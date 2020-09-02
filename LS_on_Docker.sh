#!/bin/bash
#Author: Piyush Kumar (piyushkumar.jiit@gmail.com)
#Step 1: Download; Step 2: Grant permission to script by "chmod 755 LS_on_Docker.sh" ; Step 3: ./LS_on_Docker.sh |& tee -a LS_Install.log

#Abort installation if any of the commands fail
set -e

#Set environment variables
export DCTM_DOCKER_HOST=$(hostname -I | cut -d" " -f 1)
export DCTM_DOCKER_PORT="5000"

# Environment Proxy details.
USE_PROXY=false
HTTP_PROXY=
HTTPS_PROXY=

#Update below value if you already have an existing Local Docker registry.
LOCAL_DOCKER_REGISTRY=localhost:5000

#To ease image loading, upload docker images into a predefined folder on the server where docker is running. I used /media/dctmimages as example
#Very important variable!!! This directory contains all your downloaded DCTM Docker images.
image_dir=/media/dctmimages4

#Define the base directory where Logs, YAML and other Shell scripts would be downloaded. User account should have full access on this directory. This needs to be updated in YAML as well.
export SETUP_BASE_DIR="/home/$USER"

#D2/LS Version (164,166,1661 etc.) Details. Remove the "." from the version. This would be used to fetch appropriate YAML file.
DCTM_VERSION="202"
#D2/LS Patch Version (P01,P02 etc.) Details. Keep the "P" for patch but remove any leading "0" from the patch number. This would be used to fetch appropriate YAML file.
#DCTM_PATCH_VERSION="P2"
export DOCUMENTUM_INSTALL_DIR="/opt/dctm"
export DCTM_INSTALL_LOCATION="/opt/dctm/product/16.4"

#Set D2 Install Location used by the LSD2CS install script. The default value is set for 16.4
export D2InstallLocation="D2-install"
export D2_INSTALL_FILE_DIR="/opt/$D2InstallLocation"

#Define OS specific YAML files. Only when this is undefined script will fetch the ones I used from my Github.
BPM_COMPOSE_FILE=
D2LS_COMPOSE_FILE=
D2LS_XPLORE_COMPOSE_FILE=

#Installation Owner details
export INSTALL_OWNER="dmadmin"
export INSTALL_OWNER_PASSWORD="DCTM4Ev3r"
#This might need to be changed in case of network data storage/mapping
export INSTALL_OWNER_UID=1000
#CS/Docbroker Details
export DOCBROKER_HOST=$(hostname -I | cut -d" " -f 1)
export DOCBROKER_PORT="1689"
export DOCBASE_NAME="lsd2repo1"
export EXTERNAL_DOCBROKER_PORT="1689"
export CONTENTSERVER_PORT="50000"
#In normal installation DOCBASE_OWNER is account automatically created with same name as repository. I used installation owner.
export DOCBASE_OWNER="dmadmin"
export DOCBASE_OWNER_PASSWORD="DCTM4Ev3r"
export DOCBASE_ID="453216"
export GLOBAL_REGISTRY_DOCBASE_NAME=$DOCBASE_NAME
export GLOBAL_REGISTRY_USER="dm_bof_registry"
export GLOBAL_REGISTRY_PASSWORD="password"
export BOF_REGISTRY_USER_PASSWORD="password"
export CRYPTO_REGISTRY_DOCBASE_NAME="lsd2repo1"
export PRESETS_PREFERENCES_USER_PASSWORD="password"
export DFC_SESSION_SECURE_CONNECT_DEFAULT="try_secure_first"
export PRESETS_PREFERENCES_USER_PASSWORD="webtop"

#JMS details
export METHOD_SVR_HOST=$(hostname -I | cut -d" " -f 1)
export METHOD_SVR_PORT="9080"
export JMS_REMOTE_PORT="9084"
export JMS_HOST=$(hostname -I | cut -d" " -f 1)
export JMS_PORT="9080"
export JMS_USER="admin"
export JMS_PASSWORD="password"
#Used in CS setup script. Could be aligned with JMS_PASSWORD as it is more intuitive.
export APP_SERVER_PASSWORD="password"
export WILDFLY_VERSION="wildfly9.0.1"
#Used inside xcp script. Should be aligned with WILDFLY_VERSION as they use the same value.
export JBOSS=$WILDFLY_VERSION

#Root account password
export ROOT_PASSWORD="Gu3ssWh@t"
#Used in IndexAgent to connect to Docbase. Use same as INSTALL_OWNER_PASSWORD
export DOCBASE_USER=$DOCBASE_OWNER
export DOCBASE_PASSWORD=$DOCBASE_OWNER_PASSWORD
export REPOSITORY_PASSWORD=$DOCBASE_OWNER_PASSWORD

#Target Database Details
export DATABASE_HOST=$(hostname -I | cut -d" " -f 1)
export DATABASE_SERVER_PORT="5432"
export DATABASE_USER="postgres"
export DATABASE_PASSWORD="password"
export USE_EXISTING_DATABASE_ACCOUNT=
export SERVICE_NAME="MyPostgres"
export EXTERNALDB_ADMIN_USER="postgres"
export EXTERNALDB_ADMIN_PASSWORD="password"
export DATABASE_TYPE="Postgresql"

#Encryption settings
export AEK_PASSPHRASE="password"
export AEK_NAME="CSaek"
export ENABLE_LOCKBOX=false
export LOCKBOX_FILE_NAME="lockbox.lb"
export USE_EXISTING_AEK_LOCKBOX=false
#There are complexity requirements for below password.
export LOCKBOX_PASSPHRASE="Password@123"

#Thumbnail Server Config Details
export CONFIGURE_THUMBNAIL_SERVER="NO"
export THUMBNAIL_SERVER_PORT="8081"
export THUMBNAIL_SERVER_SSL_PORT="8443"

#DA/D2/D2-Config/ ControlledPrint URL config
export APPSERVER_PORT="8080"
export APPSERVER_URL="http://localhost:8282"
export D2APP_NAME="D2"
export CONTROLLEDPRINT_URL="http://localhost:8383"
export D2_CONFIG_URL="http://localhost:8181/D2-Config"
export D2_CLIENT_URL="http://localhost:8282/D2"
export XMLVIEWER_URL="http://localhost:8282/XMLViewer"
export LS_WEBAPPS_APPSERVER_PORT="8383"

#DFS config
export DFS_APPSERVER_PORT="8484"
export DFS_APPSERVER_SECURE_PORT="8485"


#LS Specific Config
export LIFESCIENCES_SOLUTION="LSSuite"
export NUMBEROFSUBMISSIONS=1
export CONTROLLED_PRINT_ADMIN_USER=$INSTALL_OWNER
export CONTROLLED_PRINT_ADMIN_USER_PASSWORD=$INSTALL_OWNER_PASSWORD
export PDF_DOC_INFO="Subject"
export PDF_DOC_DELIMITER=#
export NUMBEROFSUBMISSIONS=1

export SUBMISSION_FILESTORE_LOCATION="//10.9.68.18/DctmImages/eSubmissions"
export SUBMISSION_ALIAS_VALUE="/opt/eSubmissions"
export SUBMISSION_FILESTORE_USERNAME="Reader"
export SUBMISSION_FILESTORE_PASSWORD="Test@123"


#xPlore/IndexAgent Details
export XPLORE_PRIMARY_ADDRESS="xplore"



#############################################################################################
#	Do Not Modify anything after this (unless you are sure And know what you are doing)		#
#############################################################################################
if [[ $image_dir == "" ]]
then
	echo "Docker Image directory not defined. Please update image_dir variable and re run. Exiting."
	sleep 5.
fi

if [[ $DCTM_VERSION == "166" ]]
then
	echo "Setting Wildfly and OpenJDK options for $DCTM_VERSION."
	#Extra 16.6 Variables
	export WILDFLY_VERSION="wildfly11.0.0"
	export JBOSS="wildfly11.0.0"
	export CONFIGURE_OPENJDK=true
	#Below spell check issue is in the base CS image so Don't try to fix this.
	export POSTGRES_MAJAR_VERSION=9
	export POSTGRES_MINAR_VERSION=6

	export D2InstallLocation="D2CS-install"
	export D2_INSTALL_FILE_DIR="/opt/$D2InstallLocation"

	#Local Config to crawl different folder for LS16.6P02 Docker Image files. Could come handy while testing a patch before rollout.
	if [[ $DCTM_PATCH_VERSION == "2" ]]
	then
		image_dir=
	fi
fi

if [[ $DCTM_VERSION == "1661" ]]
then
	echo "Setting Wildfly and OpenJDK options for $DCTM_VERSION."
	#Extra 16.6 Variables
	export WILDFLY_VERSION="wildfly11.0.0"
	export JBOSS="wildfly11.0.0"
	export CONFIGURE_OPENJDK=true
	#Below spell check issue is in the base CS image so Don't try to fix this.
	export POSTGRES_MAJAR_VERSION=10
	export POSTGRES_MINAR_VERSION=3
	export D2InstallLocation="D2CS-install"
	export D2_INSTALL_FILE_DIR="/opt/$D2InstallLocation"
	#Local Config to crawl different folder for LSS16.6.1 Docker Image files. Could come handy.
	#export image_dir=
fi

if [[ $DCTM_VERSION == "202" ]]
then
	echo "Setting Wildfly and OpenJDK options for $DCTM_VERSION."
	#Extra 16.6 Variables
	export WILDFLY_VERSION="wildfly17.0.1"
	export JBOSS="wildfly17.0.1"
	export CONFIGURE_OPENJDK=true
	#Below spell check issue is in the base CS image so Dont try to fix this.
	export POSTGRES_MAJAR_VERSION=10
	export POSTGRES_MINAR_VERSION=3
	#Need to be updated as it uses 20.2 CS image
	export DCTM_INSTALL_LOCATION="/opt/dctm/product/20.2"
	export D2InstallLocation="D2CS-install"
	export D2_INSTALL_FILE_DIR="/opt/$D2InstallLocation"
	#Local Config to crawl different folder for LSS20.2 Docker Image files. Could come handy while testing a patch before rollout.
	export image_dir=/media/dctmimages4
fi

if [[ $DCTM_VERSION == "166" && $DCTM_PATCH_VERSION != 2 ]]
then
	export CONFIGURE_OPENJDK=false
fi


cd $SETUP_BASE_DIR

echo "Execution started: "$(date)
echo "Installing DOCUMENTUM $LIFESCIENCES_SOLUTION $DCTM_VERSION $DCTM_PATCH_VERSION"

#Identify if it is Ubuntu or Centos/RHEL
distro=$(cat /etc/*-release | awk '/ID=/ { print }' | head -n 1 | awk -F "=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')

#Confirm internet connectivity
internet_access=$(ping -q -c 1 -W 1 1.1.1.1 > /dev/null 2>&1; echo $?)

#If Ping is blocked, set manually as a workaround.
#internet_access=0

#Fetch necessary files from github if not locally present/defined.

if [[ (($distro == "Ubuntu") || ($distro == "centos")) && ($internet_access == 0) ]]
then
	echo "Checking for applicable YAML files."
	if [[ -f $BPM_COMPOSE_FILE ]]
	then
		echo "BPM_COMPOSE_FILE already defined. Skipping download."
	else
	#Get BPM_COMPOSE_FILE file from github
	echo "Download BPM_COMPOSE_FILE from github."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/YAMLs/bpm_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	BPM_COMPOSE_FILE="bpm_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	fi
	
	if [[ -f $D2LS_COMPOSE_FILE ]]
	then
		echo "D2LS_COMPOSE_FILE already defined. Skipping download."
	else
	#Get D2LS_COMPOSE_FILE file from github
	echo "Download D2LS_COMPOSE_FILE from github."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/YAMLs/lsd2_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	D2LS_COMPOSE_FILE="lsd2_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	fi
	
	if [[ -f $D2LS_XPLORE_COMPOSE_FILE ]]
	then
		echo "D2LS_XPLORE_COMPOSE_FILE already defined. Skipping download."
	else
	#Get D2LS_XPLORE_COMPOSE_FILE file from github
	echo "Download D2LS_XPLORE_COMPOSE_FILE from github."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/YAMLs/lsd2_compose_"$distro"_updated_xplore_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	D2LS_XPLORE_COMPOSE_FILE="lsd2_compose_"$distro"_updated_xplore_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	fi
	
	if [[ ( -f $BPM_COMPOSE_FILE) && ( -f $D2LS_COMPOSE_FILE) && ( -f $D2LS_XPLORE_COMPOSE_FILE)]]
	then
		echo "All YAML Files downloaded."
	else
		echo "Unable to download and set YAML files. Exiting."
		exit 1
	fi
else
	echo "OS $distro not supported or unable to find YAML files."
	exit 1
fi

#Update Downloaded YAML Files to account for directory path of volumes
echo "Updating YAML files to folder path of volumes."
#Uses # as delimiter because the string uses "/"
sed -i "s#TargetF0lderL0cati0n#$SETUP_BASE_DIR#g" $SETUP_BASE_DIR/$BPM_COMPOSE_FILE
sed -i "s#TargetF0lderL0cati0n#$SETUP_BASE_DIR#g" $SETUP_BASE_DIR/$D2LS_COMPOSE_FILE
sed -i "s#TargetF0lderL0cati0n#$SETUP_BASE_DIR#g" $SETUP_BASE_DIR/$D2LS_XPLORE_COMPOSE_FILE

#Check if Docker needs to be installed
docker_installed=$(docker -v > /dev/null 2>&1; echo $?)
if [[ $docker_installed -gt 0 ]]
then
	set +e
	#Install Docker on server
	echo "Docker does not seem to be available. Trying to install Docker."
	curl -fsSL https://get.docker.com -o get-docker.sh
	# Remove set -e from script
	#sed -i "s*set -e*#set -e*g" get-docker.sh
	sudo sh get-docker.sh
	#sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
	#sudo dnf -y  install docker-ce --nobest
	sudo usermod -aG docker $USER
	#Enable Docker to start on start up
	sudo systemctl enable docker
	#Start Docker
	sudo systemctl start docker
	#Remove temp file.
	rm get-docker.sh
	set -e
	#Check again
	docker_installed=$(docker -v > /dev/null 2>&1; echo $?)
	if [[ $docker_installed == 0 ]]
	then
		echo "Docker seems to be working but you need to disconnect and reconnect for usermod changes to reflect."
		echo "Reconnect and rerun the script. Exiting."
		sleep 10
		exit 1
	elif [[ $distro == "centos" ]]
	then
		echo "Unable to install Docker. Trying the nobest option as last resort."
		sleep 2
		sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
		sudo dnf -y  install docker-ce --nobest
		sudo usermod -aG docker $USER
		#Enable Docker to start on start up
		sudo systemctl enable docker
		#Start Docker
		sudo systemctl start docker
		#Check again
		docker_installed=$(docker -v > /dev/null 2>&1; echo $?)
		if [[ $docker_installed != 0 ]]
		then
			echo "Unable to install Docker."
			exit 1
		else
			echo "Docker seems to be working but you need to disconnect and reconnect for usermod changes to reflect."
			sleep 2
			echo "Reconnect and rerun the script. Exiting."
			sleep 5
			exit 1
		fi
	else
		echo "Unable to install Docker."
		sleep 2
		exit 1
	fi
else
	echo "Docker already installed. Proceeding with LS installation."
fi

if [[ $USE_PROXY == "true" ]]
then
	sudo mkdir -p /etc/systemd/system/docker.service.d
	cat <<-EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
	[Service]
	Environment="HTTP_PROXY=$HTTP_PROXY"
	Environment="HTTPS_PROXY=$HTTPS_PROXY"
	Environment="NO_PROXY=localhost,127.0.0.1"
	EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker
else
	echo "Not using Proxy config for Docker."
fi


#Check if Docker Compose needs to be installed
doc_compose_installed=$(docker-compose -v > /dev/null 2>&1; echo $?)
if [[ $doc_compose_installed -gt 0 ]]
then
	#Install Docker Compose
	echo "Docker Compose does not seem to be available. Trying to install Docker Compose."
	sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	sleep 2
	#Check again
	doc_compose_installed=$(docker-compose -v > /dev/null 2>&1; echo $?)
	if [[ $doc_compose_installed == 0 ]]
	then
		echo "Docker Compose seems to be working. Proceeding with LS installation."
	else
		echo "Unable to install Docker Compose. Exiting."
		sleep 10
		exit 1
	fi
else
	echo "Docker Compose already installed. Proceeding with LS installation."
fi

#Download the run local Docker registry. 
registry_running=$(docker ps | grep registry > /dev/null 2>&1; echo $?)
if [[ $registry_running -gt 0 ]]
then
	docker run -d -p 5000:5000 --restart=always --name registry registry:2
else
	echo "Local Docker Registry container running."
fi

#Temp directory where you want to extract images (if needed)
Temp_Directory=$SETUP_BASE_DIR/extracted
if [[ -d "$Temp_Directory" ]]
	then
		echo "Temp Directory exists." 
	else
		echo "Temp Directory does not exists. Creating directory"
		mkdir $Temp_Directory
fi


#Iterate through all files uploaded in the image directory defined above to confirm if they are valid docker images and process accordingly.
for image in "$image_dir"/*.tar
do
  echo "Processing: $image"
  valid_image=$(tar -tvf "$image" | grep  manifest.json > /dev/null 2>&1; echo $?)
  	if [[ $valid_image == 0 ]]
  	then	
		echo "Trying to extract manifest.json from $image."
		tar -xf $image manifest.json 	
		echo "Extracted manifest.json inside $SETUP_BASE_DIR. Trying to read tag from manifest.json."
		
		#Fetching value between RepoTags and Layer
		tag_id=$(sed -r 's|.*RepoTags":\[\"(.*)\"\]\,"Layers.*|\1|' manifest.json)
		echo "Fetched tag from manifest.json: $tag_id ."
		
		#Tag fetched. Delete the manifest.json extracted in previous step.
		if [[ -f $SETUP_BASE_DIR/manifest.json ]]
		then
			#echo "Deleting manifest.json with tag: $tag_id and file name: $image"	
			rm $SETUP_BASE_DIR/manifest.json
		fi
		
		if [[ -n $tag_id ]]
		then
			#Check if image is already loaded
			final_tagid=$LOCAL_DOCKER_REGISTRY"/"$tag_id
			#Check after appending local Docker registry tag
			image_loaded=$(docker image inspect $final_tagid  > /dev/null 2>&1; echo $?)
			if [[ $image_loaded -gt 0 ]]
			then
				echo "Unable to find an image with tag $final_tagid in local repo."
				#Check with the fetched tag
				image_loaded=$(docker image inspect $tag_id > /dev/null 2>&1; echo $?)
				if [[ $image_loaded -gt 0 ]]
				then
					echo "Unable to find an image with tag $tag_id in local repo, proceeding with Image import."
					# Load the image
					docker load -i $image
					if [[ $? ]] 
					then
						echo "Image loaded."
						#Proceed with tagging image as per registry config so that YAML aligns
						echo "Trying to fetch docker image id based on tag: $tag_id"				
						tag_repo=$(echo $tag_id | awk -F ":" '{print $1}')
						tag_version=$(echo $tag_id | awk -F ":" '{print $2}')
						docker images | grep $tag_repo | grep $tag_version
						existing_tag_repo=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $1}')
						existing_tag_version=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $2}')
						existing_tag=$existing_tag_repo"/"$existing_tag_version
						imageid=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $3}')
						if [[ -n $imageid ]] 
						then						
							echo "Final Tag: $final_tagid"
							echo "Fetched imageID: $imageid having tag: $existing_tag"
							if [[ $existing_tag != $final_tagid ]]
							then
								echo "Updating Tag. Trying to update tag on the image $imageid to $final_tagid"
								docker image tag $imageid $final_tagid
								#Push updated tag to docker image repository
								echo "Updated image tag: "$final_tagid". Trying to push the image to Defined Docker Registry."
								docker push $final_tagid | tail -n 1
								if [[ $? ]] 
								then
									echo "Image push complete. Removing Old Tag "$existing_tag_repo":"$existing_tag_version
									docker rmi $existing_tag_repo":"$existing_tag_version 
									echo "Old Tag removed."
								else
									echo "Unable to push updated Image tag. Exiting."
									exit 1
								fi
							else
								echo "Tag already exits. No need to update."
							fi
						else
							echo "Unable to fetch imageid after load."
						fi

					else
						echo "Unable to load Image. Exiting."
						exit 1
					fi
				else
					echo "Image already loaded."
					#Proceed with tagging image as per registry config so that YAML aligns
					echo "Trying to fetch docker image id based on tag: $tag_id"					
					tag_repo=$(echo $tag_id | awk -F ":" '{print $1}')
					tag_version=$(echo $tag_id | awk -F ":" '{print $2}')
					docker images | grep $tag_repo | grep $tag_version
					existing_tag_repo=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $1}')
					existing_tag_version=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $2}')
					existing_tag=$existing_tag_repo"/"$existing_tag_version
					imageid=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $3}')
					if [[ -n $imageid ]] 
					then
						echo "Final Tag: $final_tagid"
						echo "Fetched imageID: $imageid having tag: $existing_tag"
						if [[ $existing_tag != $final_tagid ]]
						then
							echo "Updating Tag. Trying to update tag on the image $imageid to $final_tagid"
							docker image tag $imageid $final_tagid
							#Push updated tag to docker image repository
							echo "Updated image tag: "$final_tagid". Trying to push the image to Defined Docker Registry."
							docker push $final_tagid | tail -n 1
							if [[ $? ]] 
							then
								echo "Image push complete. Removing Old Tag "$existing_tag_repo":"$existing_tag_version
								docker rmi $existing_tag_repo":"$existing_tag_version 
								echo "Old Tag removed."
							else
								echo "Unable to push updated Image tag. Exiting."
								exit 1
							fi
						else
							echo "Tag is already in alignment. No need to update."
						fi
					else
						echo "Unable to fetch ImageID from Docker. Exiting."
						exit 1
					fi
				fi
			else
				echo "Image already available with Local Registry tag."
			fi
		else
			echo "Error!!! Unable to fetch Tag for $image."
		fi
  	else
		#Try to untar and process the tar file that contains YAML file along with actual docker image tar inside it.
		#Not used if we untar the downloads upfront.
		echo "Unable to find manifest.json in the tar file: $image. Trying to untar and recheck."
		#Untar the file in $SETUP_BASE_DIR/extracted directory.
		tar -xvf $image -C $SETUP_BASE_DIR/extracted/
		tmp_image_dir=$SETUP_BASE_DIR/extracted
		for temp_image in "$tmp_image_dir"/*.tar
		do
		  echo "Processing Temp image: $temp_image"
		  valid_image=$(tar -tvf "$temp_image" | grep  manifest.json > /dev/null 2>&1; echo $?)
			if [[ $valid_image == 0 ]]
			  	then
			  		echo "Trying to extract manifest.json from image."
					image_name=$(echo $temp_image | awk -F "/" '{print $4}' | awk -F "." '{print $1"."$2}')
					echo "Untarred Image Name: $image_name"
					tar -xf $temp_image $SETUP_BASE_DIR/extracted/$image_name/manifest.json
					echo "Extracted manifest.json in extracted directory inside \"$SETUP_BASE_DIR/extracted\". Trying to read tag from manifest.json."	
					tag_id=$(sed -r 's|.*RepoTags":\[\"(.*)\"\]\,"Layers.*|\1|' $SETUP_BASE_DIR/extracted/manifest.json)
					echo "Fetched tag from manifest.json: "$tag_id ". Trying to fetch docker image id."		
					if [[ -n "$tag_id" ]]
					then
						#Check after appending local Docker registry tag
						final_tagid=$LOCAL_DOCKER_REGISTRY"/"$tag_id
						image_loaded=$(docker image inspect $final_tagid > /dev/null 2>&1; echo $?)
						if [[ $image_loaded -gt 0 ]]
						then
							#Check if image is already loaded
							image_loaded=$(docker image inspect $tag_id > /dev/null 2>&1; echo $?)
							if [[ $image_loaded -gt 0 ]]
							then
								echo "Valid Temp Image, proceeding with Image import."
								# Load the image
								docker load -i $temp_image
								if [[ $? ]] 
								then
									echo echo "Temp Image loaded."
									echo "Trying to fetch docker image id."								
									imageid=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $3}')
									if [[ -n $imageid ]] 
									then
										echo "Trying to update tag on the image $imageid to $final_tagid"
										docker image tag $imageid $final_tagid
										echo "Updated image tag: "$final_tagid". Trying to push the image to Defined Docker Registry."
										#Push updated tag to docker image repository
										docker push $final_tagid | tail -n 1
										if [[ $? ]] 
										then
											echo "Image push complete. Removing Old Tag "$existing_tag_repo":"$existing_tag_version
											docker rmi $existing_tag_repo":"$existing_tag_version
											echo "Tag removed."
										else
											echo "Unable to push Updated Tag for Temp Image. Exiting."
											exit 1
										fi
									else
										echo "Unable to fetch ImageID from Docker. Exiting."
										exit 1
									fi
								else
									echo "Unable to load Temp Image. Exiting."
									exit 1
								fi
							else
								echo "Temp Image already loaded."
										#Proceed with tagging image as per registry config so that YAML aligns
								echo "Trying to fetch docker image id."								
								imageid=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $3}')
								if [[ -n $imageid ]] 
								then
									echo "Trying to update tag on the image $imageid to $final_tagid"
									docker image tag $imageid $final_tagid
									echo "Updated image tag: "$final_tagid". Trying to push the image to Defined Docker Registry."
									#Push updated tag to docker image repository
									docker push $final_tagid | tail -n 1
									if [[ $? ]] 
									then
										echo "Image push complete. Removing Old Tag "$existing_tag_repo":"$existing_tag_version
										docker rmi $existing_tag_repo":"$existing_tag_version
										echo "Tag removed."
									else
										echo "Unable to push Updated Tag for Temp Image. Exiting."
										exit 1
									fi
								else
									echo "Unable to fetch ImageID from Docker. Exiting."
									exit 1
								fi
							fi
						else
							echo "Temp Image already available with Local Registry Tag."
						fi
					else
						echo "Error!!! Unable to fetch Tag for $temp_image."
					fi
			else
					echo "Unable to find manifest.json in the tar file:"$image
					echo "Tar file might be corrupt or could be a YAML file. Please investigate."
					#exit 1
			fi
		done
		rm -r $SETUP_BASE_DIR/extracted/tmp_image_dir
	fi
done

#Remove temp files/folders
#rm manifest.json
rm -r $SETUP_BASE_DIR/extracted

echo "All images from the directory uploaded."

cd $SETUP_BASE_DIR
#Create shared folders for DB, Repository and xPlore data storage. These are the external data folders that persist between restart.
mkdir lsd2repo1_data
mkdir lsd2repo1_xplore

mkdir postgres_db_data
mkdir xcp-extra-dars
mkdir postgres
mkdir -p $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION
mkdir -p $SETUP_BASE_DIR/logs/DSearch
mkdir -p $SETUP_BASE_DIR/logs/IndexAgent

#Add shell script to create DB schema. Notice the single quoted EOF to ensure that $variables are not evaluated right now.
cat <<'EOF' > $SETUP_BASE_DIR/postgres/make_tablespace.sh
#!/bin/bash
mkdir -p ${PGDATA}/db_${DOCBASE_NAME}_dat.dat
chown -R ${POSTGRES_USER}:${POSTGRES_USER} ${PGDATA}/db_${DOCBASE_NAME}_dat.dat
EOF

echo "Created and updated the tablespace.sh."

if [[ $distro == "Ubuntu" ]]
then
	echo "Distro is Ubuntu."

	if [[ $DCTM_VERSION == "166" ]]
	then
		#Testing flags specific to Ubuntu for 16.6
		export CONFIGURE_OPENJDK=false
		echo "Set OPENJDK flag to False for Ubuntu and LS 166."
	fi

	#Create and start the xcp-cs-setup and lsd2cs container
	docker-compose -f $BPM_COMPOSE_FILE up -d

	#Wait a bit to let everything come up
	sleep 10
	
	#Fetch the IDs of containers
	db_container_id=$(docker ps -qf name=postgres)
	cs_container_id=$(docker ps -qf name=lsd2cs)
	xcp_container_id=$(docker ps -qf name=xcp)
	
	#Wait a min to let everything come up
	sleep 60
	#Copy CS Logs
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	echo -n "Waiting for Docbase config to complete.Check lsd2cs.log/ CS_install.log file in $HOME/logs for more details."
	#Wait for Docbase config to complete
	while [[ $(docker logs $xcp_container_id | tail -n 1 | grep "Waiting for docbase to be installed and ready" > /dev/null 2>&1; echo $?) == 0 ]]
	do
		sleep 60
		echo -n "."
		docker cp $cs_container_id:$DCTM_INSTALL_LOCATION/install/logs/install.log $SETUP_BASE_DIR/logs/CS_install.log
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "Docbase config completed. Proceeding with Process Engine configuration."
	
	#Wait for Process Engine set up to complete.
	echo -n "Waiting for Process Engine setup to complete. Check xCP.log file in $HOME/logs for more details."
	docker logs $xcp_container_id >& $SETUP_BASE_DIR/logs/xCP.log	
	while [[ $(cat $SETUP_BASE_DIR/logs/xCP.log | grep -w "PE configuration in CS is successful" > /dev/null 2>&1; echo $?) != 0 ]]
	do
		#overwrite "Waiting for Process Engine setup to complete. Check xCP.log file in $HOME/logs for more details."
		sleep 60
		echo -n "."
		docker logs $xcp_container_id >& $SETUP_BASE_DIR/logs/xCP.log
	done
	echo "."
	echo "Process Engine installation completed."
	
	#Save xCP set up logs
	docker logs $xcp_container_id>& $SETUP_BASE_DIR/logs/xCP.log
	
	#Wait for few minutes for everything to complete. This could be adjusted/removed based on experience.
	sleep 120
	
	#Save CS logs as they would be overwritten later.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_bpm.log
	
	#Step complete.
	echo -e '\a'
	
	#Assuming everything is OK, stop the services
	echo "Bringing down services"
	docker-compose -f $BPM_COMPOSE_FILE down
	#Wait a bit and let everything come up
	sleep 30
	
	#Create and start all the containers in LS stack
	echo "Starting LS Stack services"
	docker-compose -f $D2LS_COMPOSE_FILE up -d
	#Wait a bit and let everything come up
	sleep 10
	
	#Fetch the IDs of containers
	db_container_id=$(docker ps -qf name=postgres)	
	lsd2config_container_id=$(docker ps -qf name=lsd2config)
	lsd2client_container_id=$(docker ps -qf name=lsd2client)
	lswebapps_container_id=$(docker ps -qf name=lswebapps)
	da_container_id=$(docker ps -qf name=da)
	cs_container_id=$(docker ps -qf name=lsd2cs)


	if [[ $DCTM_VERSION == "166" || $DCTM_VERSION == "1661" ]]
	then
		docker exec -it $cs_container_id bash -c "cp -r /opt/D2-install/. /opt/D2CS-install"
		echo "Copied C2-install to D2CS-install in CS container" $cs_container_id
		D2InstallLocation="D2CS-install"
	fi

	#Create this directory to keep the log clean. Based on the repeated errors I saw in logs.
	docker exec -it $cs_container_id mkdir -p /opt/ls_install/LSSuite/working/logs
	
	#Wait for D2 specific Docbase config to complete
	echo -n "Waiting for D2 setup to complete. Check lsd2cs.log or D2_Install.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	sleep 60
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep -w "Installing LS now" > /dev/null 2>&1; echo $?) != 0 ]]
	do
		echo -n "."
		sleep 60
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
		docker cp $cs_container_id:/opt/$D2InstallLocation/D2Install.log $SETUP_BASE_DIR/logs/D2_Install.log
	done
	echo "."
	echo "D2 setup complete."
	
	#Wait for LifeSciences specific Docbase config to complete
	echo -n "Waiting for $LIFESCIENCES_SOLUTION binaries installation step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep -w "installed. Please find the log files in" > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "$LIFESCIENCES_SOLUTION binaries installed."
	
	#Wait for LifeSciences specific config to complete
	
	#Configuration imported successfully.
	echo -n "Waiting for LS Config import step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "Configuration imported successfully." > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "LS Config import complete."
		
	#Post Installation completed.
	echo -n "Waiting for LS Post Installation step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "Post Installation completed." > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "LS Post Installation step complete."
	
	#Wait for ApplyD2Configurations script execution to complete
	echo -n "Waiting for LS ApplyD2Configurations to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "ApplyD2Configurations script execution completed." > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	sleep 60.
	echo "LS Installation complete."
	
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	
	#Wait for 5 minutes to let everything complete.
	sleep 300
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	#Save the D2LS logs out before restart.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_ls.log
	docker cp $cs_container_id:/opt/$D2InstallLocation/D2Install.log $SETUP_BASE_DIR/logs/D2_Install.log
	docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/working/logs $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION
	
	#Sound two beeps to alert about completion of 2nd step
	echo -e '\a'
	echo -e '\a'
	
	#Bring LS Stack down.
	echo "Bringing down services"
	docker-compose -f $D2LS_COMPOSE_FILE down
	sleep 30
	
	#Start all the containers in LS stack including xPlore 
	echo "Starting LS Stack services"
	docker-compose -f $D2LS_XPLORE_COMPOSE_FILE up -d
	#Wait a bit to let everything come up
	sleep 10
	
	#Fetch the IDs of containers
	db_container_id=$(docker ps -qf name=postgres)
	lsd2config_container_id=$(docker ps -qf name=lsd2config)
	lsd2client_container_id=$(docker ps -qf name=lsd2client)
	lswebapps_container_id=$(docker ps -qf name=lswebapps)
	da_container_id=$(docker ps -qf name=da)
	cs_container_id=$(docker ps -qf name=lsd2cs)	
	xplore_container_id=$(docker ps -qf name=xplore)
	indexagent_container_id=$(docker ps -qf name=indexagent)
	
	#Wait for xPlore set up to complete
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/xPlore.log
	
	# IndexAgent log would say "waiting for starting xplore ..." till xPlore is up.
	echo -n "Waiting for xPlore setup to complete. Check xPlore.log file in $HOME/logs for more details."
	while [[ "$(docker logs $indexagent_container_id | tail -n 1)" == 'waiting for starting xplore ...' ]]
	do
		echo -n "."
		sleep 60
	done
	echo "."
	echo "xPlore setup complete. Proceeding with Index Agent setup."
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/xPlore.log
	
	#Wait for Index Agent set up to complete.
	echo -n "Waiting for Index Agent setup to complete. Check indexAgent.log file in $HOME/logs for more details."
	docker logs $indexagent_container_id >& $SETUP_BASE_DIR/logs/indexAgent.log
	while [[ $(cat $SETUP_BASE_DIR/logs/indexAgent.log | grep -w 'Deployed "IndexAgent.war"' > /dev/null 2>&1; echo $?) != 0 ]]
	do	
		sleep 60
		echo -n "."
		docker logs $indexagent_container_id >& $SETUP_BASE_DIR/logs/indexAgent.log
	done
	echo "."
	echo "IndexAgent setup complete."
	
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	docker logs $lsd2config_container_id >& $SETUP_BASE_DIR/logs/lsD2config.log
	docker logs $lsd2client_container_id >& $SETUP_BASE_DIR/logs/lsD2Client.log
	docker logs $lswebapps_container_id >& $SETUP_BASE_DIR/logs/lsD2Webapps.log
	docker logs $da_container_id >& $SETUP_BASE_DIR/logs/DA.log
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/DSearch/xPlore.log
	docker logs $indexagent_container_id >& $SETUP_BASE_DIR/logs/IndexAgent/indexAgent.log
	
	#Copy Install logs out to Docker Host
	docker cp $xplore_container_id:/root/xPlore/setup/dsearch/logs $SETUP_BASE_DIR/logs/DSearch
	docker cp $xplore_container_id:/root/xPlore/setup/dsearch/Logs $SETUP_BASE_DIR/logs/DSearch
	docker cp $indexagent_container_id:/root/xPlore/setup/indexagent/logs $SETUP_BASE_DIR/logs/IndexAgent
	docker cp $indexagent_container_id:/root/xPlore/setup/indexagent/Logs $SETUP_BASE_DIR/logs/IndexAgent
	echo "Install Logs copied out for xPlore and IndexAgent. "
	
	
	echo "Installed DOCUMENTUM $LIFESCIENCES_SOLUTION $DCTM_VERSION $DCTM_PATCH_VERSION"
	echo "DA URL: http://$DCTM_DOCKER_HOST:8080/da"
	echo "D2-Config URL: http://$DCTM_DOCKER_HOST:8181/D2-Config"
	echo "D2 URL: http://$DCTM_DOCKER_HOST:8282/D2"
	echo "Controlled Print URL: http://$DCTM_DOCKER_HOST:8383/controlledprint"
	echo "DSearch URL: http://$DCTM_DOCKER_HOST:9300/dsearchadmin (username: admin and password: password)" 
	echo "IndexAgent URL: http://$DCTM_DOCKER_HOST:9200/IndexAgent (username: $INSTALL_OWNER and password: $INSTALL_OWNER_PASSWORD)" 
	echo "------------------------- Important ------------------"
	echo "Login to DA and approve DFC Client Privileges for proper functioning of Workflows."
	echo "Script completed on $(date). Total time taken: $SECONDS Seconds"
	
else

	echo "Distro is Centos. Checking status of Firewalld."
	
	firewalld_status=$(sudo systemctl status firewalld | grep -w "Active: inactive" > /dev/null 2>&1; echo $?)
	if [[ firewalld_status -gt 0 ]]
	then
		#Stop and disable firewalld
		sudo systemctl stop firewalld
		sudo systemctl disable firewalld
		echo "Disabled firewalld. Please enable with direct rules to allow all docker containers."
		#Restart Docker to refresh iptables
		sudo systemctl restart docker
		echo "Restarted Docker."
	else
		echo "Firewalld seems to be disabled. Continuing."
	fi
	#Create and start the xcp-cs-setup and lsd2cs container
	docker-compose -f $BPM_COMPOSE_FILE up -d
	#Wait a bit to let everything come up
	sleep 30
	
	#Fetch the IDs of containers
	db_container_id=$(docker ps -qf name=postgres)
	cs_container_id=$(docker ps -qf name=lsd2cs)
	xcp_container_id=$(docker ps -qf name=xcp)
	
	#Wait a min to let everything come up
	sleep 60
	#Copy CS Logs
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	echo -n "Waiting for Docbase config to complete.Check lsd2cs.log/ CS_install.log file in $HOME/logs for more details."
	#Wait for Docbase config to complete
	while [[ $(docker logs $xcp_container_id | tail -n 1 | grep "Waiting for docbase to be installed and ready" > /dev/null 2>&1; echo $?) == 0 ]]
	do
		sleep 60
		echo -n "."
		docker cp $cs_container_id:$DCTM_INSTALL_LOCATION/install/logs/install.log $SETUP_BASE_DIR/logs/CS_install.log
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "Docbase config completed. Proceeding with Process Engine configuration."
	
	#Wait for Process Engine set up to complete.
	echo -n "Waiting for Process Engine setup to complete. Check xCP.log file in $HOME/logs for more details."
	docker logs $xcp_container_id >& $SETUP_BASE_DIR/logs/xCP.log	
	while [[ $(cat $SETUP_BASE_DIR/logs/xCP.log | grep -w "PE configuration in CS is successful" > /dev/null 2>&1; echo $?) != 0 ]]
	do
		#overwrite "Waiting for Process Engine setup to complete. Check xCP.log file in $HOME/logs for more details."
		sleep 60
		echo -n "."
		docker logs $xcp_container_id >& $SETUP_BASE_DIR/logs/xCP.log
	done
	echo "."
	echo "Process Engine installation completed."
	
	#Save xCP set up logs
	docker logs $xcp_container_id>& $SETUP_BASE_DIR/logs/xCP.log
	
	# #Wait for few minutes for everything to complete. This could be adjusted/removed based on experience.
	sleep 120
	
	#Save CS logs as they would be overwritten later.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_bpm.log
	
	#Step complete.
	echo -e '\a'
	
	#Assuming everything is OK, stop the services
	echo "Bringing down services"
	docker-compose -f $BPM_COMPOSE_FILE down
	#Wait a bit to let everything shutdown
	sleep 30
	
	#Create and start all the containers in LS stack
	echo "Starting LS Stack services"
	docker-compose -f $D2LS_COMPOSE_FILE up -d
	#Wait a bit to let everything come up
	sleep 10
	
	#Fetch the IDs of containers
	db_container_id=$(docker ps -qf name=postgres)	
	lsd2config_container_id=$(docker ps -qf name=lsd2config)
	lsd2client_container_id=$(docker ps -qf name=lsd2client)
	lswebapps_container_id=$(docker ps -qf name=lswebapps)
	da_container_id=$(docker ps -qf name=da)
	cs_container_id=$(docker ps -qf name=lsd2cs)

	if [[ $DCTM_VERSION == "166" || $DCTM_VERSION == "1661" ]]
	then
		#Copy D2-install to D2CS-install used in the install script. Probable workaround for mistake in LS Docker image
		#docker cp -r $cs_container_id:/opt/D2-install $cs_container_id:/opt/D2CS-install
		docker exec -it $cs_container_id bash -c "cp -r /opt/D2-install/. /opt/D2CS-install"
		echo "Copied D2-install to D2CS-install in CS container" $cs_container_id
		D2InstallLocation="D2CS-install"
	fi
	
	#Create this directory to keep the log clean. Based on the repeated errors I saw in logs.
	docker exec -it $cs_container_id mkdir -p /opt/ls_install/LSSuite/working/logs
	
	#Wait for D2 specific Docbase config to complete
	echo -n "Waiting for D2 setup to complete. Check lsd2cs.log or D2_Install.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	sleep 60
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep -w "Installing LS now" > /dev/null 2>&1; echo $?) != 0 ]]
	do
		echo -n "."
		sleep 60
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
		docker cp $cs_container_id:/opt/$D2InstallLocation/D2Install.log $SETUP_BASE_DIR/logs/D2_Install.log
	done
	echo "."
	echo "D2 setup complete."
	
	#Wait for LifeSciences specific Docbase config to complete
	echo -n "Waiting for $LIFESCIENCES_SOLUTION binaries installation step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep -w "installed. Please find the log files in" > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "$LIFESCIENCES_SOLUTION binaries installed."
	
	#Wait for LifeSciences specific config to complete
	
	#Configuration imported successfully.
	echo -n "Waiting for LS Config import step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "Configuration imported successfully." > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "LS Config import complete."
	
	#Post Installation completed.
	echo -n "Waiting for LS Post Installation step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "Post Installation completed." > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	echo "LS Post Installation step complete."
		
	#Wait for ApplyD2Configurations script execution to complete
	echo -n "Waiting for LS ApplyD2Configurations to complete. Check lsd2cs.log file in $HOME/logs for more details."
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "ApplyD2Configurations script execution completed." > /dev/null 2>&1; echo $?) != 0 ]]
	do
		sleep 60
		echo -n "."
		docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	done
	echo "."
	sleep 60.
	echo "LS Installation complete."
	
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log

	#Wait for 5 minutes to let everything complete.
	sleep 300


	#Change the default D2 client plugin preference
	#lsd2client_container_id=$(docker ps -qf name=lsd2client)
	#docker exec -it $lsd2client_container_id bash -c 'sed -i "s#browser.plugin.mode = wsctf,thin#browser.plugin.mode = thin,wsctf#g" /usr/local/tomcat/CustomConf/settings.properties'


	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	#Save the D2LS logs out before restart.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_ls.log
	docker cp $cs_container_id:/opt/$D2InstallLocation/D2Install.log $SETUP_BASE_DIR/logs/D2_Install.log
	docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/working/logs $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION

	#Sound two beeps
	echo -e '\a'
	echo -e '\a'
	
	#Bring LS Stack down.
	echo "Bringing down services"
	docker-compose -f $D2LS_COMPOSE_FILE down
	sleep 30
	
	#Start all the containers in LS stack including xPlore 
	echo "Starting LS Stack services"
	docker-compose -f $D2LS_XPLORE_COMPOSE_FILE up -d
	#Wait a bit to let everything come up
	sleep 10
	
	#Fetch the IDs of containers
	db_container_id=$(docker ps -qf name=postgres)
	lsd2config_container_id=$(docker ps -qf name=lsd2config)
	lsd2client_container_id=$(docker ps -qf name=lsd2client)
	lswebapps_container_id=$(docker ps -qf name=lswebapps)
	da_container_id=$(docker ps -qf name=da)
	cs_container_id=$(docker ps -qf name=lsd2cs)	
	xplore_container_id=$(docker ps -qf name=xplore)
	indexagent_container_id=$(docker ps -qf name=indexagent)
	
	#Wait for xPlore set up to complete
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/xPlore.log
	
	# IndexAgent log would say "waiting for starting xplore ..." till xPlore is up.
	echo -n "Waiting for xPlore setup to complete. Check xPlore.log file in $HOME/logs for more details."
	while [[ "$(docker logs $indexagent_container_id | tail -n 1)" == 'waiting for starting xplore ...' ]]
	do
		echo -n "."
		sleep 60
	done
	echo "."
	echo "xPlore setup complete. Proceeding with Index Agent setup."
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/xPlore.log
	
	#Wait for Index Agent set up to complete.
	echo -n "Waiting for Index Agent setup to complete. Check indexAgent.log file in $HOME/logs for more details."
	docker logs $indexagent_container_id >& $SETUP_BASE_DIR/logs/indexAgent.log
	while [[ $(cat $SETUP_BASE_DIR/logs/indexAgent.log | grep -w 'Deployed "IndexAgent.war"' > /dev/null 2>&1; echo $?) != 0 ]]
	do	
		sleep 60
		echo -n "."
		docker logs $indexagent_container_id >& $SETUP_BASE_DIR/logs/indexAgent.log
	done
	echo "."
	echo "IndexAgent setup complete."
	
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	docker logs $lsd2config_container_id >& $SETUP_BASE_DIR/logs/lsD2config.log
	docker logs $lsd2client_container_id >& $SETUP_BASE_DIR/logs/lsD2Client.log
	docker logs $lswebapps_container_id >& $SETUP_BASE_DIR/logs/lsD2Webapps.log
	docker logs $da_container_id >& $SETUP_BASE_DIR/logs/DA.log
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/DSearch/xPlore.log
	docker logs $indexagent_container_id >& $SETUP_BASE_DIR/logs/IndexAgent/indexAgent.log
	
	#Copy xPlore and IndexAgent Install logs out to Docker Host
	if [[ $DCTM_VERSION == "164" || $DCTM_VERSION == "166" || $DCTM_VERSION == "1661" ]]
	then
		#20.2 paths differ so only docker logs are extracted.
		docker cp $xplore_container_id:/root/xPlore/setup/dsearch/logs $SETUP_BASE_DIR/logs/DSearch
		docker cp $xplore_container_id:/root/xPlore/setup/dsearch/Logs $SETUP_BASE_DIR/logs/DSearch
		docker cp $indexagent_container_id:/root/xPlore/setup/indexagent/logs $SETUP_BASE_DIR/logs/IndexAgent
		docker cp $indexagent_container_id:/root/xPlore/setup/indexagent/Logs $SETUP_BASE_DIR/logs/IndexAgent
		echo "Install Logs copied out for xPlore and IndexAgent. "
	fi

	echo "Installed DOCUMENTUM $LIFESCIENCES_SOLUTION $DCTM_VERSION $DCTM_PATCH_VERSION"
	echo "DA URL: http://$DCTM_DOCKER_HOST:8080/da"
	echo "D2-Config URL: http://$DCTM_DOCKER_HOST:8181/D2-Config"
	echo "D2 URL: http://$DCTM_DOCKER_HOST:8282/D2"
	echo "Controlled Print URL: http://$DCTM_DOCKER_HOST:8383/controlledprint"
	echo "DSearch URL: http://$DCTM_DOCKER_HOST:9300/dsearchadmin (username: admin and password: password)" 
	echo "IndexAgent URL: http://$DCTM_DOCKER_HOST:9200/IndexAgent (username: $INSTALL_OWNER and password: $INSTALL_OWNER_PASSWORD)" 
	echo "------------------------- Important ------------------"
	echo "Login to DA and approve DFC Client Privileges for proper functioning of Workflows."

	echo "Script completed on $(date). Total time taken: $SECONDS Seconds"
fi

#Create Start and Stop Scripts
cat << EOF > $SETUP_BASE_DIR/start_LS.sh
#!/bin/bash 
docker start postgres lsd2cs da lsd2config lsd2client lswebapps xplore indexagent dfshost
#In case one does not want to save credentials in below command, we could edit /etc/fstab as well for permanent mounting of SSV filestore
#docker start $db_container_id $cs_container_id $da_container_id $lsd2config_container_id $lsd2client_container_id $lswebapps_container_id $xplore_container_id $indexagent_container_id
EOF

cat << EOF > $SETUP_BASE_DIR/stop_LS.sh
#!/bin/bash 
docker stop dfshost indexagent xplore lswebapps lsd2client lsd2config da lsd2cs postgres
#docker stop $indexagent_container_id $xplore_container_id $lswebapps_container_id $lsd2client_container_id $lsd2config_container_id $da_container_id $cs_container_id  $db_container_id
EOF

#Remove files no longer needed.
cd $SETUP_BASE_DIR
rm $BPM_COMPOSE_FILE $D2LS_COMPOSE_FILE $D2LS_XPLORE_COMPOSE_FILE
