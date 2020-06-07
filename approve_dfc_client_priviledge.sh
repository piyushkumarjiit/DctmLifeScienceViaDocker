#!/bin/bash

#This script needs to be run on CS after LS installation has completed to grant priviledged client access to JMS apps.
echo "Starting JMS DFC Client Priviledge Approval script."
#To extract necessary D2 lib files run below command on CS to extract from D2.war present in the container (/opt/OpenText/D2/webapps)
cd /opt/OpenText/D2/webapps
jar -xf D2.war WEB-INF/lib
jar -xf D2.war WEB-INF/classes
jar -xf D2.war utils/d2privilegedclient

WEBINF_LIB_PATH=/opt/OpenText/D2/webapps/WEB-INF/lib
WEBINF_CLASS_PATH=/opt/OpenText/D2/webapps/WEB-INF/classes
DFC_JAR_PATH=$DOCUMENTUM/dfc/dfc.jar
JMS_DEPLOYMENT_PATH=$DOCUMENTUM/$WILDFLY_VERSION/server/DctmServer_MethodServer/deployments
#Browse to d2privilegedclient directory and find the version
cd /opt/OpenText/D2/webapps/utils/d2privilegedclient
UTILITY=$(find D2PrivilegedClientUtil*.jar)
UTILITY_PATH=/opt/OpenText/D2/webapps/utils/d2privilegedclient/$UTILITY
#Browse to WEB-INF/lib directory and find the name+version of Sl4J jar
cd $WEBINF_LIB_PATH
Sl4J=$(find slf4j-api*.jar)
Sl4J_LIB_PATH=/opt/OpenText/D2/webapps/WEB-INF/lib/$Sl4J

cd /opt/OpenText/D2/webapps/utils/d2privilegedclient
#Check if BPM is installed and then update its dfc.properties
if [[ -f $JMS_DEPLOYMENT_PATH/bpm.ear/APP-INF/classes/dfc.properties ]]
then 
	echo "Trying to set Priviledged client status for BPM."	
	java -cp  "$DFC_JAR_PATH:$JMS_DEPLOYMENT_PATH/bpm.ear/APP-INF/classes:$Sl4J_LIB_PATH:$WEBINF_CLASS_PATH:$UTILITY_PATH" com.opentext.d2.util.D2PrivilegedClientUtil -d $1 -u $2 -p $3
	echo "================== BPM Done ===================="
fi

#Update for ACS
if [[ -f $JMS_DEPLOYMENT_PATH/acs.ear/lib/configs.jar/dfc.properties ]]
then 
	echo "Trying to set Priviledged client status for ACS."	
	java -cp  "$DFC_JAR_PATH:$JMS_DEPLOYMENT_PATH/acs.ear/lib/configs.jar/dfc.properties:$Sl4J_LIB_PATH:$WEBINF_CLASS_PATH:$UTILITY_PATH" com.opentext.d2.util.D2PrivilegedClientUtil -d $1 -u $2 -p $3
	echo "================== ACS Done ===================="
fi

#Update for ServerApps
if [[ -f $JMS_DEPLOYMENT_PATH/ServerApps.ear/APP-INF/classes/dfc.properties ]]
then 
	echo "Trying to set Priviledged client status for ServerApps."	
	java -cp  "$DFC_JAR_PATH:$JMS_DEPLOYMENT_PATH/ServerApps.ear/APP-INF/classes:$Sl4J_LIB_PATH:$WEBINF_CLASS_PATH:$UTILITY_PATH" com.opentext.d2.util.D2PrivilegedClientUtil -d $1 -u $2 -p $3
	echo "================== ServerApps Done ============="
fi


#ServerApps dfc.properties
#java -cp  "/opt/dctm/dfc/dfc.jar:/opt/dctm/wildfly17.0.1/server/DctmServer_MethodServer/deployments/acs.ear/lib/configs.jar/:/opt/OpenText/D2/webapps/WEB-INF/lib/slf4j-api-1.7.25.jar:/opt/OpenText/D2/webapps/WEB-INF/classes/:/opt/OpenText/D2/webapps/utils/d2privilegedclient/D2PrivilegedClientUtil-20.2.0.jar" com.opentext.d2.util.D2PrivilegedClientUtil -d $DOCBASE_NAME -u $INSTALL_OWNER -p $INSTALL_OWNER_PASSWORD

#java -cp  "/opt/dctm/dfc/dfc.jar:/opt/dctm/wildfly17.0.1/server/DctmServer_MethodServer/deployments/ServerApps.ear/APP-INF/classes:/opt/OpenText/D2/webapps/WEB-INF/lib/slf4j-api-1.7.25.jar:/opt/OpenText/D2/webapps/WEB-INF/classes/:/opt/OpenText/D2/webapps/utils/d2privilegedclient/D2PrivilegedClientUtil-20.2.0.jar" com.opentext.d2.util.D2PrivilegedClientUtil -d $DOCBASE_NAME -u $INSTALL_OWNER -p $INSTALL_OWNER_PASSWORD

echo "Cleaning up temp files."
cd /opt/OpenText/D2/webapps
rm -R -f WEB-INF
rm -R -f utils

echo "All done. Exiting."