#!/bin/bash -e

oc new-project pipelines

oc apply -f tekton-resources/customer-ms/customer-ms-spring-solo.yaml

oc apply -f tekton-pipelines/security-pipeline-prevail-2021.yaml 
oc apply -f tekton-pipelines/image-intake-pipeline-prevail-2021.yaml 

oc apply -f tekton-tasks/aot-mockup.yaml 
oc apply -f tekton-tasks/aot-maven-settings.yaml 
oc apply -f tekton-tasks/aot-maven-task.yaml 
oc apply -f tekton-tasks/aot-buildah-task.yaml
oc apply -f tekton-tasks/ibm-img-scan-trivy.yaml

oc apply -f pvc --recursive

oc secret link pipeline crc-creds-skopeo

oc policy add-role-to-user system:image-pusher system:serviceaccount:full-bc:pipeline

echo "Welcome to IBM Prevail 2021"

echo "___ ___ __  __   ___                  _ _   ___ __ ___ _ "
echo "|_ _| _ )  \/  | | _ \_ _ _____ ____ _(_) | |_  )  \_  ) |"
echo "| || _ \ |\/| | |  _/  _/ -_) V / _  | | |  / / () / /| |"
echo "|___|___/_|  |_| |_| |_| \___|\_/\__,_|_|_| /___\__/___|_|"

