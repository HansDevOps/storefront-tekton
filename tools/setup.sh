#!/bin/bash
source ~/config.bc-full 

clear

HERE=$(pwd)
echo "working from ${HERE}"

oc new-project tools

# Allow project full-bc to pull the jmeter image
oc policy add-role-to-group system:image-puller system:serviceaccounts:${NAMESPACE}

# Speed optimisations
oc apply -f tools/httpd/httpd-pvc.yaml
oc apply -f tools/httpd/iam-pvc.yaml
oc apply -f tools/httpd/webdav-pvc.yaml 
oc apply -f tools/jmeter-performance-test/influxdb/influxdb-data.yaml
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge


# Setup Openshift pipelines
echo "###################################################################"
cd ${HERE}/tools/pipelines
./install_pipelines.sh
echo ""

# Setup sonarqube
echo "###################################################################"
cd ${HERE}/tools/sonarqube
./install_sonarqube.sh
echo ""

# Setup httpd
echo "###################################################################"
cd ${HERE}/tools/httpd
./silver-platter-webdav.sh  
echo ""


# Setup nexus
echo "###################################################################"
cd ${HERE}/tools/nexus
./install_nexus3-v2.sh
echo ""

# Setup stackrox
echo "###################################################################"
helm repo add rhacs https://mirror.openshift.com/pub/rhacs/charts/
helm search repo -l rhacs/
helm repo update

helm install -n stackrox \
--create-namespace stackrox-central-services rhacs/central-services \
--set imagePullSecrets.allowNone=true \
--set central.resources.requests.memory="2Gi" \
--set central.resources.requests.cpu="100m" \
--set scanner.resources.requests.memory="1000Mi" \
--set scanner.resources.requests.cpu="100m"

# Setup jmeter-performance-test
echo "###################################################################"
cd ${HERE}/tools/jmeter-performance-test
./build_jmeter_image.sh  
./install_jmeter_framework.sh
echo ""

# Setup stackrox
echo "###################################################################"
cd ${HERE}/tools/stackrox
./build_stackrox_image.sh  
echo ""

# Import the openshift cli into the Lab environment
oc import-image cli -n openshift 

# view cannot create pods/portforward
oc policy add-role-to-user admin ${OCP_USER}
oc policy add-role-to-user admin system:serviceaccount:pipelines:pipeline 

cd ${HERE}