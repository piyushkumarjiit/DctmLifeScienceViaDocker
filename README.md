# DctmLifeScienceViaDocker

This script is not for Prod rather a quick way to spin up a specific version of Documentum Life Sciences to either demo the product or reproduce an issue.
I use this as my Dev environment at times when I do not have access to the target environment.
I created and tested this on my bare metal and it worked really well so thought of sharing with the wider DCTM community.
The script can setup 16.4,16.6, 16.6P2, 16.6.1 and 20.2 DCTM LS environments.

If something is not clear on this ReadMe, I would recommend to downland the script and take a look as I have added comments to make it easy for other to understand and customize as needed.

## Getting Started

Connect/SSH to your server/node and create a directory (Ex: mkdir -p /media/dctmimages4 ).
Login to support.opentext.com and download all the LS Docker images for the version you want to install. 
If you downloaded the image to your local machine, upload to the server and place in the directory (/media/dctmimages4) created in step 1.

It would be quicker if you have updated your server before proceeding with installation.

### Prerequisites
The script is relatively self contained and fetches necessary files from github repo. To execute the script successfully we need:

<li>Access to Internet</li>
<li>Respective Documentum images</li>
<li>Running Linux environment with Docker.</li>
<li>SSH, SUDO access to your server</li>



### LS Images
To keep it as streamlined as possible, I have predefined images in YAML files being used by the script.
This means that the script would fail when it is unable to fetch the required Docker image.
thus it is important to download exact images used by the script and put them in the /media/dctmimages4 folder before executing the script.

Below is the list for latest 2 LS versions. 
For older LS versions, take a look at the respective YAML file present in the YAML folder on github.
#### 20.2
<li>xcp/centos/stateless/xcp-pe-setup:20.2.0000.0054</li>
<li>contentserver/centos/stateless/cs:20.2.0000.0110</li>
<li>artifactory.otxlab.net/bpdockerhub/lifescience/centos/stateless/lsd2cs:20.2.0000.0232</li>
<li>xplore/centos/stateless/indexserver:20.2.0000.0015</li>
<li>xplore/centos/stateless/indexagent:20.2.0000.0015</li>
<li>artifactory.otxlab.net/bpdockerhub/da/centos/stateless/dastateless:20.2.0000.0051</li>
<li>artifactory.otxlab.net/bpdockerhub/lifescience/centos/stateless/lsd2config:20.2.0000.0232</li>
<li>artifactory.otxlab.net/bpdockerhub/lifescience/centos/stateless/lsd2client:20.2.0000.0232</li>
<li>artifactory.otxlab.net/bpdockerhub/lifescience/centos/stateless/lswebapps:20.2.0000.0232</li>

#### 16.6.1
<li>xcp/centos/stateless/xcp-pe-setup:16.4.1040.0131</li>
<li>contentserver_centos:16.4.0170.0234</li>
<li>lsd2cs_docker_centos:16.6.1000.0126</li>
<li>xplore_ubuntu:16.4.0000.0197</li>
<li>indexagent_ubuntu:16.4.0000.0197</li>
<li>da_centos:16.4.0170.0027</li>
<li>lsd2config_docker_centos:16.6.1000.0126</li>
<li>lsd2client_docker_centos:16.6.1000.0126</li>
<li>lswebapps_docker_centos:16.6.1000.0126</li>


### Installation

After completing the prerequisite step defined above, connect to your server (terminal or SSH session), got your home directory and run below commands  :

<code>wget https://raw.githubusercontent.com/piyushkumarjiit/DctmLifeScienceViaDocker/master/LS_on_Docker.sh</code>

Update the permissions on the downloaded file using:

<code>chmod 755 LS_on_Docker.sh</code>

Now run below script and follow prompts:

<code>sudo ./LS_on_Docker.sh |& tee -a LS_Install.log</code>


## Post Installation Steps
If everything went well so far, we would have a working Documentum Life Sciences platform.
We would be able to login to D2 application (using dmadmin) but there are few more tasks to be completed before everything is ready.

### Setting up Privileged client for JMS
Login to DA and grant necessary permissions under Client rights management node to JMS. This is required for Workflows to work properly.

### Mounting remote location for SSV import
If using SSV, we need to mount remote folder from where SSV would import submissions.
We can exec into the lsd2cs container and use mount command to mount the remote directory.

### Setting up User accounts
For testing, we need to add users to the application. 
Login to DA, create/import users and set them in LS specific roles.


## Testing
LS validation is too big to put here.
For sanity testing, Import a PDF file as a Cat 2 document, send it to a workflow and complete the workflow.
If all the steps involved proceed as expected, the environment should be OK.

## Start and Stop
The script generates 2 scripts "start_LS.sh" and "stop_LS.sh" which can be used to start and stop the entire LS stack.
### To Start
<code>sudo ./start_LS.sh</code>
### To Stop
<code>sudo ./stop_LS.sh</code>

Do not delete the directories created by the script as it contains Documentum and DB data.

## Whats Next
This is just a start and all the steps outlined under Post Installation steps could be automated via shell scripts.

Other components CTS/Render services, iHub, Brava etc. need to be set up (if needed).


## Authors
**Piyush Kumar** - (https://github.com/piyushkumarjiit)

## License
This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
Thanks to below URLs for providing me the necessary understanding and material to come up with this script.
<li>https://support.opentext.com </li>
<li>https://www.docker.com</li>
<li>https://www.Stackoverflow.com</li>
<li>https://www.DuckDuckGo.com</li>

