#!/bin/bash

#Author: Piyush Kumar (piyushk@opentext.com)

#nohup ./LS_on_Docker_V02.sh>&1 &
#./LS_on_Docker_V02.sh > >(tee -a LS_Install.log) 2> >(tee -a LS_Install_Error.log >&2)
#./LS_on_Docker_V02.sh > >(tee -a LS_Install.log) 2> >(tee -a LS_Install.log >&2)
#./LS_on_Docker_V02.sh | tee LS_Install.log

#Abort installation if any of the commands fail
#set -e

#Set environment variables
export DCTM_DOCKER_HOST=$(echo $(hostname -I | cut -d" " -f 1))
export DCTM_DOCKER_PORT="5000"

#Update below value if you already have an existing Local Docker registry.
LOCAL_DOCKER_REGISTRY=localhost:5000

#To ease image loading, upload docker images into a predefined folder on the server where docker is running. I used /media/dctmimages as example
image_dir=/media/dctmimages
#Define the base directory where Logs, YAML and other Shell scripts would be downloaded. User account should ahve full access on this directory. This needs to be updated in YAML as well.
export SETUP_BASE_DIR="/home/$USER"

#To mount network location
#Top level Network location where system would create subfolder. Needs to ahve write access.
#NAS_DATA_LOCATION=
#Network user account +password used to access the location
#NAS_USER=
#NAS_PASSWORD=

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
export INSTALL_OWNER="ichigo"
export INSTALL_OWNER_PASSWORD="D3m04doc"
#This might need to be changed in case of network data storage/mapping
export INSTALL_OWNER_UID=1000
#CS/Docbroker Details
export DOCBROKER_HOST=$(echo $(hostname -I | cut -d" " -f 1))
export DOCBROKER_PORT="1689"
export DOCBASE_NAME="lsd2repo1"
export EXTERNAL_DOCBROKER_PORT="1689"
export CONTENTSERVER_PORT="50000"
#In normal installation DOCBASE_OWNER is account automatically created with same name as repository. I used installation owner.
export DOCBASE_OWNER="ichigo"
export DOCBASE_OWNER_PASSWORD="D3m04doc"
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
export METHOD_SVR_HOST=$(echo $(hostname -I | cut -d" " -f 1))
export METHOD_SVR_PORT="9080"
export JMS_REMOTE_PORT="9084"
export JMS_HOST=$(echo $(hostname -I | cut -d" " -f 1))
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
export DATABASE_HOST=$(echo $(hostname -I | cut -d" " -f 1))
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

export SUBMISSION_FILESTORE_LOCATION="//192.168.2.2/DctmData/eSubmissions"
export SUBMISSION_ALIAS_VALUE="/opt/eSubmissions"
export SUBMISSION_FILESTORE_USERNAME="Reader"
export SUBMISSION_FILESTORE_PASSWORD="Infy@123"


#Xplore/IndexAgent Details
export XPLORE_PRIMARY_ADDRESS="xplore"



#############################################################################################
#	Do Not Modify anything after this (unless you are sure and know what you are doing)		#
#############################################################################################
if [[ $DCTM_VERSION == "166" ]]
then
	echo "Setting Wildfly and OpenJDK options."
	#Extra 16.6 Variables
	export WILDFLY_VERSION="wildfly11.0.0"
	export JBOSS="wildfly11.0.0"
	export CONFIGURE_OPENJDK=true
	#Below spell check issue is in the base CS image so Dont try to fix this.
	export POSTGRES_MAJAR_VERSION=9
	export POSTGRES_MINAR_VERSION=6

	export D2InstallLocation="D2CS-install"
	export D2_INSTALL_FILE_DIR="/opt/$D2InstallLocation"

	#Local Config to crawl different folder for LS16.6P02 Docker Image files. Could come handy while testing a patch before rollout.
	if [[ $DCTM_PATCH_VERSION == "2" ]]
	then
		image_dir=/media/dctmimages2
	fi
fi

if [[ $DCTM_VERSION == "1661" ]]
then
	echo "Setting Wildfly and OpenJDK options."
	#Extra 16.6 Variables
	export WILDFLY_VERSION="wildfly11.0.0"
	export JBOSS="wildfly11.0.0"
	export CONFIGURE_OPENJDK=true
	#Below spell check issue is in the base CS image so Dont try to fix this.
	export POSTGRES_MAJAR_VERSION=10
	export POSTGRES_MINAR_VERSION=3
	export D2InstallLocation="D2CS-install"
	export D2_INSTALL_FILE_DIR="/opt/$D2InstallLocation"
	#Local Config to crawl different folder for LSS16.6.1 Docker Image files. Could come handy while testing a patch before rollout.
	export image_dir=/media/dctmimages3
fi

if [[ $DCTM_VERSION == "202" ]]
then
	echo "Setting Wildfly and OpenJDK options."
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


#Other flags being used by images but not specified in YAML. Could come handy in future.
#export DB_TYPE="postgres"
#DFS_DOWNLOAD_URL=""
#export DM_DOCKER_HOME="/opt/dctm_docker"
#export DM_HOME="/opt/dctm/product/16.4"
#export DOCUMENTUM="/opt/dctm"
#export HOME="/root"
#export HOSTNAME="6639dedfb633"
#export INSTALL_HOME="/opt"
#export IS_IJMS="false"
#export JMS_HOST="192.168.2.157"


cd $SETUP_BASE_DIR

echo "Execution started: "$(date)
echo "Installing DOCUMENTUM $LIFESCIENCES_SOLUTION $DCTM_VERSION $DCTM_PATCH_VERSION"

#Identify if it is Ubuntu or Centos/RHEL
distro=$(cat /etc/*-release | awk '/ID=/ { print }' | head -n 1 | awk -F "=" '{print $2}' | sed -e 's/^"//' -e 's/"$//')

#Confirm internet connectivity
internet_access=$(ping -q -c 1 -W 1 1.1.1.1 > /dev/null 2>&1; echo $?)

#Fetch necessary files from github if not already defined.

if [[ $internet_access == 0 ]]
then
	echo "Downloading NoadminXML and Install Owner Verification Script."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/install_owner_verification.sh"
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/nodmadmin.installparam_template.xml"
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/ssv_filestore_config.sh"
	echo "Done."
fi


if [[ (($distro == "Ubuntu") || ($distro == "centos")) && ($internet_access == 0) ]]
then
	echo "Checking for applicable YAML files."
	if [[ -f $BPM_COMPOSE_FILE ]]
	then
		echo "BPM_COMPOSE_FILE already defined. Skipping download."
	else
	#Get BPM_COMPOSE_FILE file from github
	echo " Download BPM_COMPOSE_FILE from github."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/bpm_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	BPM_COMPOSE_FILE="bpm_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	fi
	
	if [[ -f $D2LS_COMPOSE_FILE ]]
	then
		echo "D2LS_COMPOSE_FILE already defined. Skipping download."
	else
	#Get D2LS_COMPOSE_FILE file from github
	echo " Download D2LS_COMPOSE_FILE from github."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/lsd2_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	D2LS_COMPOSE_FILE="lsd2_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
	fi
	
	if [[ -f $D2LS_XPLORE_COMPOSE_FILE ]]
	then
		echo "D2LS_XPLORE_COMPOSE_FILE already defined. Skipping download."
	else
	#Get D2LS_XPLORE_COMPOSE_FILE file from github
	echo " Download D2LS_XPLORE_COMPOSE_FILE from github."
	wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/lsd2_compose_"$distro"_updated_xplore_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
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


#Check for cifs-utils
if [[ $distro == "Ubuntu" ]]
then
#If Ubuntu
	cifsutils_installed=$(dpkg -l | grep cifs-utils > /dev/null 2>&1; echo $?)
	if [[ $cifsutils_installed -gt 0 ]]
	then
		sudo apt-get install -y cifs-utils
		echo "CIFS Utils installed via apt-get."
	else
		echo "Cifs Utils present. Continuing with LS installation."
	fi
#If CentOS
elif [[ $distro == "centos" ]]
then
	cifsutils_installed=$(dnf list installed cifs-utils > /dev/null 2>&1; echo $?)
	if [[ $cifsutils_installed -gt 0 ]]
	then
		sudo dnf install -y cifs-utils
		echo "CIFS Utils installed via dnf."
	else
		echo "Cifs Utils present. Continuing with LS installation."
	fi
else
	echo "Unable to install Cifs Utils."
	exit 1
fi

#Check if Docker needs to be installed
docker_installed=$(docker -v > /dev/null 2>&1; echo $?)
if [[ $docker_installed -gt 0 ]]
then
	#Install Docker on server
	echo "Docker does not seem to be available. Trying to install Docker."
	curl -fsSL https://get.docker.com -o get-docker.sh
	sudo sh get-docker.sh
	sudo usermod -aG docker $USER
	#Enable Docker to start on start up
	sudo systemctl enable docker
	#Start Docker
	sudo systemctl start docker
	#Remove temp file.
	rm get-docker.sh
	#Check again
	docker_installed=$(docker -v > /dev/null 2>&1; echo $?)
	if [[ $docker_installed == 0 ]]
	then
		echo "Docker seems to be working but you need to disconnect and reconnect for usermod changes to reflect."
		echo "Reconnect and rerun the script. Exiting."
		sleep 10
		exit 1
	else
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
	fi		
else
	echo "Docker already installed. Proceeding with LS installation."
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
						#docker images | awk -v awkvar="$(echo $tag_id | awk -F ":" '{ print $1}')" ' $0 ~ awkvar {print $3}'
						
						tag_repo=$(echo $tag_id | awk -F ":" '{print $1}')
						tag_version=$(echo $tag_id | awk -F ":" '{print $2}')
						docker images | grep $tag_repo | grep $tag_version
						existing_tag_repo=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $1}')
						existing_tag_version=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $2}')
						existing_tag=$existing_tag_repo"/"$existing_tag_version
						#echo "TagID: $tag_id | TagRepo: $tag_repo | TagVersion: $tag_version"
						#echo "Existing tag: $existing_tag"
						#imageid=$(docker images | awk -v awkvar="$(echo $tag_id | awk -F ":" '{ print $1}')" ' $0 ~ awkvar {print $3}')
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
					#docker images | awk -v awkvar="$(echo $tag_id | awk -F ":" '{ print $1}')" ' $0 ~ awkvar {print $3}'
					
					tag_repo=$(echo $tag_id | awk -F ":" '{print $1}')
					tag_version=$(echo $tag_id | awk -F ":" '{print $2}')
					docker images | grep $tag_repo | grep $tag_version
					existing_tag_repo=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $1}')
					existing_tag_version=$(docker images | grep $tag_repo | grep $tag_version | awk -F " " '{print $2}')
					existing_tag=$existing_tag_repo"/"$existing_tag_version
					#echo "TagID: $tag_id | TagRepo: $tag_repo | TagVersion: $tag_version"
					#echo "Existing tag: $existing_tag"
					#imageid=$(docker images | awk -v awkvar="$(echo $tag_id | awk -F ":" '{ print $1}')" ' $0 ~ awkvar {print $3}')
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
		#Try to untar and process the file that contains YAML file along with actual docker image tar inside it. Not needed if we untar the downloads upfront.
		echo "Unable to find manifest.json in the tar file: $image. Trying to untar and recheck."
		#Untar the file in $SETUP_BASE_DIR/extracted directory
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
									#imageid=$(docker images | awk -v awkvar="$(echo $tag_id | awk -F ":" '{ print $1}')" ' $0 ~ awkvar {print $3}')
								
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
								#imageid=$(docker images | awk -v awkvar="$(echo $tag_id | awk -F ":" '{ print $1}')" ' $0 ~ awkvar {print $3}')
								
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

#Function to ovewrite the last line whiel waiting for setup to complete.
overwrite() { echo -e "\r\033[1A\033[0K$@"; }

#Add dmadmin account to docker host. Not needed.
#adduser dmadmin

#Add dmadmin to sudo. Not needed.
#sudo usermod -a -G sudo dmadmin

cd $SETUP_BASE_DIR
#Create shared folders for DB, Repositry and xPlore data storage. These are the external data folders that persist between restart.
mkdir lsd2repo1_data
mkdir lsd2repo1_xplore
#Mount Network Drive in folder for DCTM Data and xPlore Data
#sudo mount -t cifs -o username=$NAS_USER,password=$NAS_PASSWORD,uid=$(id -u),forceuid,gid=$(id -g),forcegid $NAS_DATA_LOCATION/$HOSTNAME/data  $SETUP_BASE_DIR/lsd2repo1_data
#sudo mount -t cifs -o username=$NAS_USER,password=$NAS_PASSWORD,uid=$(id -u),forceuid,gid=$(id -g),forcegid $NAS_DATA_LOCATION/$HOSTNAME/xplore  $SETUP_BASE_DIR/lsd2repo1_xplore

#Create/ Bind Volumes for use as DCTM Data, Shared and DB data folder
#docker volume create --driver local --opt type=none --opt device=/home/ichigo/postgres_db_data --opt o=bind postgres_db_data
#docker volume create --driver local --opt type=none --opt device=/home/ichigo/lsd2repo1_data --opt o=bind lsd2repo1_data
#docker volume create --driver local --opt type=none --opt device=/home/ichigo/lsd2repo1_share --opt o=bind lsd2repo1_share

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

	#Copy JDK-11 folder to Ubuntu CS for 16.6. Not needed in 16.4
	#echo "Copy JDK-11 to CS container" $cs_container_id
	#docker cp $SETUP_BASE_DIR/jdk-11 $cs_container_id:/opt/jdk-11
	
	#Copy the script to create installation owner account if it does not exist. Not needed in 16.4
	echo "Copy script to CS container" $cs_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $cs_container_id:/install_owner_verification.sh
	docker exec -it $cs_container_id chmod 755 install_owner_verification.sh
	docker exec -it $cs_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
		
	#Copy the script to create installation owner account if it does not exist.
	echo "Copy script to xCP container" $xcp_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $xcp_container_id:/install_owner_verification.sh
	docker exec -it $xcp_container_id chmod 755 install_owner_verification.sh
	docker exec -it $xcp_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	echo "Script copy completed."
	
	#Wait a min to let everything come up
	sleep 60
	#Copy CS Logs
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	#-n will not output the trailing newline while -e will allow me to interpret backslash escape symbols which means \r woudl bring us back to start of line
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
	
	#Wait for few minutes for everything to complete. This could be adjuested/removed based on experience.
	sleep 120
	
	#Save CS logs as they would be overwritten later.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_bpm.log
	
	#Step complete.
	echo -e '\a'
	#read -n 1 -p "Press any key to continue:"
	
	#Assuming everything is OK, stop the services
	echo "Bringing down services"
	docker-compose -f $BPM_COMPOSE_FILE down
	#Wait a bit to let everything come up
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
		#Testing flags specific to Ubuntu for 16.6
		#Copy D2-install to D2CS-install used in the install script. Probable workaround for mistake in LS Docker image
		#docker cp -r $cs_container_id:/opt/D2-install $cs_container_id:/opt/D2CS-install
		docker exec -it $cs_container_id bash -c "cp -r /opt/D2-install/. /opt/D2CS-install"
		echo "Copied C2-install to D2CS-install in CS container" $cs_container_id
		D2InstallLocation="D2CS-install"
	fi
	
	#Create nodmadmin parameter file from template. This should help with customer defined install owner accounts
	cp $SETUP_BASE_DIR/nodmadmin.installparam_template.xml $SETUP_BASE_DIR/nodmadmin.installparam.xml
	sed -i "s/###TargetInstallOwner###/$INSTALL_OWNER/g" $SETUP_BASE_DIR/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSSuite/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSSSV/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSTMF/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSRD/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSQM/nodmadmin.installparam.xml
	#docker cp $cs_container_id:/opt/dctm_docker/scripts/methodserver_restore_backup_changes.sh $SETUP_BASE_DIR/methodserver_restore_backup_changes.sh
	#docker cp $cs_container_id:/opt/dctm_docker/scripts/start_all_services.sh $SETUP_BASE_DIR/start_all_services.sh
	#docker cp $indexagent_container_id:/root/entrypoint.sh $SETUP_BASE_DIR/entrypoint.sh

	#Create this directory to keep the log clean. Based on the repeated errors I saw in logs.
	docker exec -it $cs_container_id mkdir -p /opt/ls_install/LSSuite/working/logs

	#Copy the script to create installation owner account if it does not exist.
	echo "Copy script to CS container" $cs_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $cs_container_id:/install_owner_verification.sh
	docker exec -it $cs_container_id chmod 755 install_owner_verification.sh
	docker exec -it $cs_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	# Not needed as parameter seems to be working properly. Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $lsd2config_container_id:/install_owner_verification.sh
	# docker exec -it $lsd2config_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $lsd2config_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Not needed as parameter seems to be working properly.Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $lsd2client_container_id:/install_owner_verification.sh
	# docker exec -it $lsd2client_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $lsd2client_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Not needed as parameter seems to be working properly.Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $lswebapps_container_id:/install_owner_verification.sh
	# docker exec -it $lswebapps_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $lswebapps_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#No clear idea if this is needed or not. Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $da_container_id:/install_owner_verification.sh
	# docker exec -it $da_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $da_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	echo "Copied script to all containers."
	rm $SETUP_BASE_DIR/nodmadmin.installparam.xml
	
	#Wait for D2 specific Docbase config to complete
	#D2Method Main END method com.emc.d2.api.methods.D2ImportMassCreateMethod
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
	#D2Method Main END method com.emc.d2.api.methods.D2ImportMassCreateMethod
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
	
	
	#Updating widget URL of external widgets successful.
	# echo -n "Waiting for LS External Widgets update step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	# docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	# while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "widget URL of external widgets successful" > /dev/null 2>&1; echo $?) != 0 ]]
	# do
	# 	sleep 60
	# 	echo -n "."
	# 	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	# done
	# echo "."
	# echo "LS External Widgets update complete."
	
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
	
	#"Update D2 options with D2/D2-Config URL"
	#"ApplyD2Configurations script execution completed. Please find the log files in logdir=$currentdir/working/logs/ as LSSuite*.log for more details"
	# while [[ $(cat $SETUP_BASE_DIR/logs/updateInstallInfo.log | grep -w "(1 row affected)" > /dev/null 2>&1; echo $?) != 0 ]]
	# do
		# sleep 60
		# echo -n "."
		# docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
		# docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/working/logs/LSSuite_ConfigImport.log $SETUP_BASE_DIR/logs/lsd2_config.log
	# done
	# echo "."
	
	#filepresent=docker exec -it $cs_container_id test -f "/opt/ls_install/$LIFESCIENCES_SOLUTION/updateInstallInfo.log"

	#Wait for 5 minutes to let everything complete.
	sleep 300
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	#Save the D2LS logs out before restart.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_ls.log
	docker cp $cs_container_id:/opt/$D2InstallLocation/D2Install.log $SETUP_BASE_DIR/logs/D2_Install.log
	docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/working/logs $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION
	#Dont need this as it does not add value and is missing in 16.6
	#docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/updateInstallInfo.log $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION/updateInstallInfo.log
	
	#See if you need to copy D2CS-install to D2-install before shutting things down. The problem is that this is not a volume and it would not persist.
	/usr/local/tomcat/CustomConf

	#Sound two beeps
	echo -e '\a'
	echo -e '\a'
	#read -n 1 -p "Press any key to continue:"
	
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
	
	#Copy the script to create installation owner account if it does not exist.
	echo "Copy script to CS container" $cs_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $cs_container_id:/install_owner_verification.sh
	docker exec -it $cs_container_id chmod 755 install_owner_verification.sh
	docker exec -it $cs_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Copy the script to create installation owner account if it does not exist.
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $xplore_container_id:/root/install_owner_verification.sh
	docker exec -it $xplore_container_id chmod 755 /root/install_owner_verification.sh
	docker exec -it $xplore_container_id /root/install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Copy the script to create installation owner account if it does not exist.
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $indexagent_container_id:/root/install_owner_verification.sh
	docker exec -it $indexagent_container_id chmod 755 /root/install_owner_verification.sh
	docker exec -it $indexagent_container_id /root/install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	echo "Copied script to CS, xPlore and IndexAgent containers."
	
	#Wait for xPlore set up to complete
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/xPlore.log
	#We can look into xPlore.log at last few lines where it points out that dsearch has been deployed.
	#while [[ $(cat $SETUP_BASE_DIR/logs/xPlore.log | grep -w 'Deployed "dsearch.war"' > /dev/null 2>&1; echo $?) != 0 ]]
	
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
	
	while true; 
	do
		read -p "Do you want to set up dummy users and roles? (Yes/No): " user_reply
		case $user_reply in
			#Dummy Users and role mapping
			[Yy]*) echo "Ensure that all relevant scripts (Shell,API,DQL) are placed in /home/$INSTALL_OWNER/UserCreation.";
			read -n 1 -p "Press any key when ready:"
			#Run script to create roles and dummy accounts
			docker cp $SETUP_BASE_DIR/UserCreation $cs_container_id:/home/$INSTALL_OWNER/
			#docker cp $SETUP_BASE_DIR/UserCreation 7cdc11b3ed3c:/home/ichigo
			docker exec $cs_container_id chmod -R 777 /home/$INSTALL_OWNER/UserCreation
			#docker exec 7cdc11b3ed3c chmod -R 777 /home/ichigo/UserCreation
			#docker exec -w /home/$INSTALL_OWNER/UserCreation $cs_container_id bash -c "su $INSTALL_OWNER; ./runscripts.sh;"
			#docker exec -w /home/ichigo/UserCreation 7cdc11b3ed3c bash -c "su ichigo; ./runscripts.sh"
			echo 'On the next prompt, execute "./runscripts.sh" . The script would take some time to complete. Once you see "Done", use "exit" command to come out of container.'
			docker exec -it -w /home/$INSTALL_OWNER/UserCreation $cs_container_id bash -c "su $INSTALL_OWNER"
			#echo '1. Use Docker exec and login to the machine: docker exec -w /home/'$INSTALL_OWNER'/UserCreation '$cs_container_id' bash '"su $INSTALL_OWNER"
			#echo '2. Change to INSTALL_OWNER session: su '$INSTALL_OWNER
			#echo '2. Run : ./runscripts.sh'
			echo "Back from container."
			sleep 2;
			break;;
			
			[Nn]*) echo "User chose not to setup Dummy Users and roles.";
			#Skipping setting up Dummy Users and Roles
			echo "Skipping setting up Dummy Users and Roles."
			sleep 2;
			break;;	
			
			* ) echo "Please answer Yes or No.";;
		esac
	done

	#read -p "Do you want this script to approve DFC Client Priviledges for proper functioning of Workflows? (Yes/No): " user_reply
	
	#echo "docker start $cs_container_id $da_container_id $lsd2config_container_id $lsd2client_container_id $lswebapps_container_id $xplore_container_id $indexagent_container_id" > start.txt
	#echo "docker stop $cs_container_id $da_container_id $lsd2config_container_id $lsd2client_container_id $lswebapps_container_id $xplore_container_id $indexagent_container_id" > stop.txt
	echo "Installed DOCUMENTUM $LIFESCIENCES_SOLUTION $DCTM_VERSION $DCTM_PATCH_VERSION"
	echo "DA URL: http://$DCTM_DOCKER_HOST:8080/da"
	echo "D2-Config URL: http://$DCTM_DOCKER_HOST:8181/D2-Config"
	echo "D2 URL: http://$DCTM_DOCKER_HOST:8282/D2"
	echo "Controlled Print URL: http://$DCTM_DOCKER_HOST:8383/controlledprint"
	echo "DSearch URL: http://$DCTM_DOCKER_HOST:9300/dsearchadmin (username: admin and password: password)" 
	echo "IndexAgent URL: http://$DCTM_DOCKER_HOST:9200/IndexAgent (username: $INSTALL_OWNER and password: $INSTALL_OWNER_PASSWORD)" 

	while true; 
	do
		read -p "Do you want to create image from current Content Server (lsd2cs container)? (Yes/No): " user_reply
		case $user_reply in
			#Dummy Users and role mapping
			[Yy]*) echo "Please ensure that you every installation step completed before proceeding.";
			read -p 'Enter the version number for the image (Final Tag for image would be <LocalDockerRegistry>/ubuntu_lsd2cs:$DCTM_VERSION.$DCTM_PATCH_VERSION.$IMAGE_VERSION): ' IMAGE_VERSION
			#Commit the current state of some containers (probably CS so that we dont have to reinstall PE + LS and can just boot directly)
			docker commit $cs_container_id $LOCAL_DOCKER_REGISTRY/ubuntu_lsd2cs:$DCTM_VERSION.$DCTM_PATCH_VERSION.$(date)
			sleep 2;
			break;;
			
			[Nn]*) echo "User chose not to create image from comtainer.";
			#Skipping creating image from comtainer
			echo "Skipping creating image."
			sleep 2;
			break;;	
			
			* ) echo "Please answer Yes or No.";;
		esac
	done

	


	echo "Script completed at $(date). Total time taken: $SECONDS Seconds"

	#docker-compose -f $BPM_COMPOSE_FILE down
	#docker-compose -f $D2LS_COMPOSE_FILE down
	#docker-compose -f $D2LS_XPLORE_COMPOSE_FILE down
	#sudo rm -r lsd2repo1_data lsd2repo1_xplore postgres postgres_db_data xcp-extra-dars logs
	#docker volume rm ichigo_lsd2repo1_data ichigo_postgres_db_data ichigo_xcp-extra-dars ichigo_xplore
	#docker volume prune
	#docker rmi -f 70d360bc8d7c 55b3025a1307 fe5a6caa7cd8 aad0149c2303 81d17b332e36 1c15c7933c43 6b8c7ef27448 5e497111358e a2dcda4c3f4d 0846eef15a7c b993fca07adc
	
	#Check everything is working as expected
	#docker logs lsd2cs
else

	echo "Distro is Centos. Checking status of Firewalld."
	
	firewalld_status=$(sudo systemctl status firewalld | grep -w "Active: inactive" > /dev/null 2>&1; echo $?)
	if [[ firewalld_status -gt 0 ]]
	then
		#Stop and disable firewalld
		sudo systemctl stop firewalld
		sudo systemctl disable firewalld
		echo "Disabled firewalld. Please enable with direct rules to allow all docker containers."
		#Restart Docker to regenerate the iptables
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
	
	#Copy the script to create installation owner account if it does not exist. Not needed in 16.4
	echo "Copy script to CS container" $cs_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $cs_container_id:/install_owner_verification.sh
	docker exec -it $cs_container_id chmod 755 install_owner_verification.sh
	docker exec -it $cs_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
		
	#Copy the script to create installation owner account if it does not exist.
	echo "Copy script to xCP container" $xcp_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $xcp_container_id:/install_owner_verification.sh
	docker exec -it $xcp_container_id chmod 755 install_owner_verification.sh
	docker exec -it $xcp_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	echo "Script copy completed."
	
	#Wait a min to let everything come up
	sleep 60
	#Copy CS Logs
	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	#-n will not output the trailing newline while -e will allow me to interpret backslash escape symbols which means \r woudl bring us back to start of line
	echo -n "Waiting for Docbase config to complete.Check lsd2cs.log/ CS_install.log file in $HOME/logs for more details."
	#Wait for Docbase config to complete
	while [[ $(docker logs $xcp_container_id | tail -n 1 | grep "Waiting for docbase to be installed and ready" > /dev/null 2>&1; echo $?) == 0 ]]
	do
		#echo "Waiting for Docbase config to complete.Check lsd2cs.log file in $HOME/logs for more details."
		#echo -ne "Waiting for Docbase config to complete.Check lsd2cs.log file in $HOME/logs for more details."\\r
		sleep 60
		echo -n "."
		#sleep 10
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
	
	# #Wait for few minutes for everything to complete. This could be adjuested/removed based on experience.
	sleep 120
	
	#Save CS logs as they would be overwritten later.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_bpm.log
	
	# #Check that JMS is up an available after CS set up
	# #./wait-for-it.sh -t 0 localhost:9084
	# #result=$(echo $?)
	
	#Step complete.
	echo -e '\a'
	#read -n 1 -p "Press any key to continue:"
	
	#Assuming everything is OK, stop the services
	echo "Bringing down services"
	docker-compose -f $BPM_COMPOSE_FILE down
	#Wait a bit to let everything come up
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

	#D2InstallLocation="D2-install"

	if [[ $DCTM_VERSION == "166" || $DCTM_VERSION == "1661" ]]
	then
		#Testing flags specific to Ubuntu for 16.6
		#Copy D2-install to D2CS-install used in the install script. Probable workaround for mistake in LS Docker image
		#docker cp -r $cs_container_id:/opt/D2-install $cs_container_id:/opt/D2CS-install
		docker exec -it $cs_container_id bash -c "cp -r /opt/D2-install/. /opt/D2CS-install"
		echo "Copied D2-install to D2CS-install in CS container" $cs_container_id
		D2InstallLocation="D2CS-install"
	fi
	
	#Create nodmadmin parameter file from template. This should help with customer defined install owner accounts
	cp $SETUP_BASE_DIR/nodmadmin.installparam_template.xml $SETUP_BASE_DIR/nodmadmin.installparam.xml
	sed -i "s/###TargetInstallOwner###/$INSTALL_OWNER/g" $SETUP_BASE_DIR/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSSuite/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSSSV/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSTMF/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSRD/nodmadmin.installparam.xml
	docker cp $SETUP_BASE_DIR/nodmadmin.installparam.xml $cs_container_id:/opt/ls_install/LSQM/nodmadmin.installparam.xml
	#docker cp $cs_container_id:/opt/dctm_docker/scripts/methodserver_restore_backup_changes.sh $SETUP_BASE_DIR/methodserver_restore_backup_changes.sh
	#docker cp $cs_container_id:/opt/dctm_docker/scripts/start_all_services.sh $SETUP_BASE_DIR/start_all_services.sh
	#docker cp $indexagent_container_id:/root/entrypoint.sh $SETUP_BASE_DIR/entrypoint.sh
	
	#Create this directory to keep the log clean. Based on the repeated errors I saw in logs.
	docker exec -it $cs_container_id mkdir -p /opt/ls_install/LSSuite/working/logs

	#Copy the script to create installation owner account if it does not exist.
	echo "Copy script to CS container" $cs_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $cs_container_id:/install_owner_verification.sh
	docker exec -it $cs_container_id chmod 755 install_owner_verification.sh
	docker exec -it $cs_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD


	
	# Not needed as parameter seems to be working properly. Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $lsd2config_container_id:/install_owner_verification.sh
	# docker exec -it $lsd2config_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $lsd2config_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Not needed as parameter seems to be working properly.Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $lsd2client_container_id:/install_owner_verification.sh
	# docker exec -it $lsd2client_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $lsd2client_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Not needed as parameter seems to be working properly.Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $lswebapps_container_id:/install_owner_verification.sh
	# docker exec -it $lswebapps_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $lswebapps_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#No clear idea if this is needed or not. Copy the script to create installation owner account if it does not exist.
	# docker cp $SETUP_BASE_DIR/install_owner_verification.sh $da_container_id:/install_owner_verification.sh
	# docker exec -it $da_container_id chmod 755 install_owner_verification.sh
	# docker exec -it $da_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	echo "Copied script to all containers."
	rm $SETUP_BASE_DIR/nodmadmin.installparam.xml
	
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
	
	# #Updating widget URL of external widgets successful.
	# echo -n "Waiting for LS External Widgets update step to complete. Check lsd2cs.log file in $HOME/logs for more details."
	# docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	# while [[ $(cat $SETUP_BASE_DIR/logs/lsd2cs.log | grep "widget URL of external widgets successful" > /dev/null 2>&1; echo $?) != 0 ]]
	# do
	# 	sleep 60
	# 	echo -n "."
	# 	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	# done
	# echo "."
	# echo "LS External Widgets update complete."
	
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
	lsd2client_container_id=$(docker ps -qf name=lsd2client)
	docker exec -it $lsd2client_container_id bash -c 'sed -i "s#browser.plugin.mode = wsctf,thin#browser.plugin.mode = thin,wsctf#g" /usr/local/tomcat/CustomConf/settings.properties'


	docker logs $cs_container_id >& $SETUP_BASE_DIR/logs/lsd2cs.log
	#Save the D2LS logs out before restart.
	cp $SETUP_BASE_DIR/logs/lsd2cs.log $SETUP_BASE_DIR/logs/lsd2cs_ls.log
	docker cp $cs_container_id:/opt/$D2InstallLocation/D2Install.log $SETUP_BASE_DIR/logs/D2_Install.log
	docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/working/logs $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION
	#Dont need this as it does not add value and is missing in 16.6
	#docker cp $cs_container_id:/opt/ls_install/$LIFESCIENCES_SOLUTION/updateInstallInfo.log $SETUP_BASE_DIR/logs/$LIFESCIENCES_SOLUTION/updateInstallInfo.log
	


	#Sound two beeps
	echo -e '\a'
	echo -e '\a'
	#read -n 1 -p "Press any key to continue:"
	
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
	
	#Copy the script to create installation owner account if it does not exist.
	echo "Copy script to CS container" $cs_container_id
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $cs_container_id:/install_owner_verification.sh
	docker exec -it $cs_container_id chmod 755 install_owner_verification.sh
	docker exec -it $cs_container_id /install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Copy the script to create installation owner account if it does not exist.
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $xplore_container_id:/root/install_owner_verification.sh
	docker exec -it $xplore_container_id chmod 755 /root/install_owner_verification.sh
	docker exec -it $xplore_container_id /root/install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	
	#Copy the script to create installation owner account if it does not exist.
	docker cp $SETUP_BASE_DIR/install_owner_verification.sh $indexagent_container_id:/root/install_owner_verification.sh
	docker exec -it $indexagent_container_id chmod 755 /root/install_owner_verification.sh
	docker exec -it $indexagent_container_id /root/install_owner_verification.sh $INSTALL_OWNER $INSTALL_OWNER_PASSWORD
	echo "Copied script to CS, xPlore and IndexAgent containers."
	
	#Wait for xPlore set up to complete
	docker logs $xplore_container_id >& $SETUP_BASE_DIR/logs/xPlore.log
	#We can look into xPlore.log at last few lines where it points out that dsearch has been deployed.
	#while [[ $(cat $SETUP_BASE_DIR/logs/xPlore.log | grep -w 'Deployed "dsearch.war"' > /dev/null 2>&1; echo $?) != 0 ]]
	
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
	if [[ $DCTM_VERSION == "164" || $DCTM_VERSION == "166" || $DCTM_VERSION == "1661" ]]
	then
		#20.2 paths differ so only docker logs are extracted.
		docker cp $xplore_container_id:/root/xPlore/setup/dsearch/logs $SETUP_BASE_DIR/logs/DSearch
		docker cp $xplore_container_id:/root/xPlore/setup/dsearch/Logs $SETUP_BASE_DIR/logs/DSearch
		docker cp $indexagent_container_id:/root/xPlore/setup/indexagent/logs $SETUP_BASE_DIR/logs/IndexAgent
		docker cp $indexagent_container_id:/root/xPlore/setup/indexagent/Logs $SETUP_BASE_DIR/logs/IndexAgent
		echo "Install Logs copied out for xPlore and IndexAgent. "
	fi
	
	#DFS Setup
	while true; 
	do
		read -p "Do you want to set up DFS Instance as well? (Yes/No): " user_reply
		case $user_reply in
			#Submission Filestore for SSV Mapping
			[Yy]*) echo "Downloading YAML file for DFS." ;
			#read -n 1 -p "Press any key when ready:"
			#wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/dfs_compose_centos_updated_202.yml"
			wget "https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/dfs_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
			DFS_COMPOSE_FILE="dfs_compose_"$distro"_updated_"$DCTM_VERSION$DCTM_PATCH_VERSION".yml"
			echo "Download complete. Creating DFS container and starting service."
			docker-compose -f $SETUP_BASE_DIR/$DFS_COMPOSE_FILE up -d
			echo "Done."
			sleep 2;
			break;;
			
			[Nn]*) echo "User chose not to set up DFS.";
			echo "Skipping setting up DFS."
			sleep 2;
			break;;			
			* ) echo "Please answer Yes or No.";;
		esac
	done

	#Dummy user account setup
	while true; 
	do
		read -p "Do you want to set up dummy users and roles? (Yes/No): " user_reply
		case $user_reply in
			#Dummy Users and role mapping
			[Yy]*) echo "Ensure that all relevant scripts (Shell,API,DQL) are placed in /home/$INSTALL_OWNER/UserCreation.";
			read -n 1 -p "Press any key when ready:"
			#Run script to create roles and dummy accounts
			docker cp $SETUP_BASE_DIR/UserCreation $cs_container_id:/home/$INSTALL_OWNER/
			#docker cp $SETUP_BASE_DIR/UserCreation 7cdc11b3ed3c:/home/ichigo
			docker exec $cs_container_id chmod -R 777 /home/$INSTALL_OWNER/UserCreation
			#docker exec 7cdc11b3ed3c chmod -R 777 /home/ichigo/UserCreation
			#docker exec -w /home/$INSTALL_OWNER/UserCreation $cs_container_id bash -c "su $INSTALL_OWNER; ./runscripts.sh;"
			#docker exec -w /home/ichigo/UserCreation 7cdc11b3ed3c bash -c "su ichigo; ./runscripts.sh"
			echo 'On the next prompt, execute "./runscripts.sh" . The script would take some time to complete. Once you see "Done", use "exit" command to come out of container.'
			docker exec -it -w /home/$INSTALL_OWNER/UserCreation $cs_container_id bash -c "su $INSTALL_OWNER"
			#echo '1. Use Docker exec and login to the machine: docker exec -w /home/'$INSTALL_OWNER'/UserCreation '$cs_container_id' bash '"su $INSTALL_OWNER"
			#echo '2. Change to INSTALL_OWNER session: su '$INSTALL_OWNER
			#echo '2. Run : ./runscripts.sh'
			echo "Back from container."
			sleep 2;
			break;;
			
			[Nn]*) echo "User chose not to setup Dummy Users and roles.";
			#Skipping setting up Dummy Users and Roles
			echo "Skipping setting up Dummy Users and Roles."
			sleep 2;
			break;;			
			* ) echo "Please answer Yes or No.";;
		esac
	done

	#SSV Filestore setup
	while true; 
	do
		read -p "Do you want to set up Submission Filestore for SSV? (Yes/No): " user_reply
		case $user_reply in
			#Submission Filestore for SSV Mapping
			[Yy]*) echo "Copy SSV Config script to CS container" $cs_container_id ;
			#read -n 1 -p "Press any key when ready:"
			docker cp $SETUP_BASE_DIR/ssv_filestore_config.sh $cs_container_id:/ssv_filestore_config.sh
			docker exec -it $cs_container_id chmod 755 ssv_filestore_config.sh
			docker exec -it $cs_container_id /ssv_filestore_config.sh $SUBMISSION_ALIAS_VALUE $SUBMISSION_FILESTORE_LOCATION $SUBMISSION_FILESTORE_USERNAME $SUBMISSION_FILESTORE_PASSWORD
			#docker exec $cs_container_id bash -c "mkdir $SUBMISSION_ALIAS_VALUE; "
			#docker exec $cs_container_id bash -c "mount -t cifs -o username=$SUBMISSION_FILESTORE_USERNAME,password=$SUBMISSION_FILESTORE_PASSWORD $SUBMISSION_FILESTORE_LOCATION  $SUBMISSION_ALIAS_VALUE"
			echo "Done."
			sleep 2;
			break;;
			
			[Nn]*) echo "User chose not to set up Submission Filestore for SSV.";
			echo "Skipping setting up Submission Filestore for SSV."
			sleep 2;
			break;;			
			* ) echo "Please answer Yes or No.";;
		esac
	done

	#read -p "Do you want this script to approve DFC Client Priviledges for proper functioning of Workflows? (Yes/No): " user_reply
	#echo "Updating lswebapps to be a privileged client"
    #java -cp $LS_CONFIG_CONF_DIR:$CATALINA_HOME/webapps/D2-Config/WEB-INF/lib/*:$CATALINA_HOME/webapps/D2-Config/utils/d2privilegedclient/* com.opentext.d2.util.D2PrivilegedClientUtil -d $DOCBASE_NAME -u $INSTALL_OWNER -p $INSTALL_OWNER_PASSWORD


	#echo "docker start $cs_container_id $da_container_id $lsd2config_container_id $lsd2client_container_id $lswebapps_container_id $xplore_container_id $indexagent_container_id" > start.txt
	#echo "docker stop $cs_container_id $da_container_id $lsd2config_container_id $lsd2client_container_id $lswebapps_container_id $xplore_container_id $indexagent_container_id" > stop.txt
	echo "Installed DOCUMENTUM $LIFESCIENCES_SOLUTION $DCTM_VERSION $DCTM_PATCH_VERSION"
	echo "DA URL: http://$DCTM_DOCKER_HOST:8080/da"
	echo "D2-Config URL: http://$DCTM_DOCKER_HOST:8181/D2-Config"
	echo "D2 URL: http://$DCTM_DOCKER_HOST:8282/D2"
	echo "Controlled Print URL: http://$DCTM_DOCKER_HOST:8383/controlledprint"
	echo "DFS URL: http://$DCTM_DOCKER_HOST:8484/dfs/services"
	echo "DSearch URL: http://$DCTM_DOCKER_HOST:9300/dsearchadmin (username: admin and password: password)" 
	echo "IndexAgent URL: http://$DCTM_DOCKER_HOST:9200/IndexAgent (username: $INSTALL_OWNER and password: $INSTALL_OWNER_PASSWORD)" 

	echo"Login to DA and approve DFC Client Priviledges for proper functioning of Workflows."


	while true; 
	do
		read -p "Do you want to create image from current Content Server (lsd2cs container)? (Yes/No): " user_reply
		case $user_reply in
			#Dummy Users and role mapping
			[Yy]*) echo "Please ensure that you every installation step completed before proceeding.";
			read -p 'Enter the version number for the image (Final Tag for image would be <LocalDockerRegistry>/centos_lsd2cs:$DCTM_VERSION.$DCTM_PATCH_VERSION.$IMAGE_VERSION): ' IMAGE_VERSION
			#Commit the current state of some containers (probably CS so that we dont have to reinstall PE + LS and can just boot directly)
			docker commit $cs_container_id $LOCAL_DOCKER_REGISTRY/ubuntu_lsd2cs:$DCTM_VERSION.$DCTM_PATCH_VERSION.$(date)
			sleep 2;
			break;;
			
			[Nn]*) echo "User chose not to create image from comtainer.";
			#Skipping creating image from comtainer
			echo "Skipping creating image."
			sleep 2;
			break;;	
			
			* ) echo "Please answer Yes or No.";;
		esac
	done

	echo "Script completed at $(date). Total time taken: $SECONDS Seconds"
fi


#Create Start and Stop Scripts
cat << EOF > $SETUP_BASE_DIR/start_LS.sh
#!/bin/bash 
docker start postgres lsd2cs da lsd2config lsd2client lswebapps xplore indexagent dfshost
#In case one does not want to save credentials in below command, we could edit /etc/fstab as well for permanent mounting of SSV filestore
docker exec -it lsd2cs /ssv_filestore_config.sh $SUBMISSION_ALIAS_VALUE $SUBMISSION_FILESTORE_LOCATION $SUBMISSION_FILESTORE_USERNAME $SUBMISSION_FILESTORE_PASSWORD
#docker start $db_container_id $cs_container_id $da_container_id $lsd2config_container_id $lsd2client_container_id $lswebapps_container_id $xplore_container_id $indexagent_container_id
EOF

cat << EOF > $SETUP_BASE_DIR/stop_LS.sh
#!/bin/bash 
docker stop dfshost indexagent xplore lswebapps lsd2client lsd2config da lsd2cs postgres
#docker stop $indexagent_container_id $xplore_container_id $lswebapps_container_id $lsd2client_container_id $lsd2config_container_id $da_container_id $cs_container_id  $db_container_id
EOF

#Remove files no longer needed.
cd $SETUP_BASE_DIR
rm install_owner_verification.sh ssv_filestore_config.sh nodmadmin.installparam_template.xml
#rm $BPM_COMPOSE_FILE $D2LS_COMPOSE_FILE $D2LS_XPLORE_COMPOSE_FILE
