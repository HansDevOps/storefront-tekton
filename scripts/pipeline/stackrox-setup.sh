#!/bin/bash -e

clear

source ~/config.bc-full

oc project pipelines

oc apply -f tekton-resources/tools-images/ubi-image.yaml


export HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
docker login -u $(oc whoami) -p $(oc whoami -t) $HOST

#oc create secret generic registrycreds \
#--from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json \
#--type kubernetes.io/dockerconfigjson

oc delete secret generic oir-registrycreds 2>/dev/null

oc create secret generic oir-registrycreds \
--from-file .dockerconfigjson=${XDG_RUNTIME_DIR}/containers/auth.json \
--type kubernetes.io/dockerconfigjson

#oc extract secret/oir-registrycreds --to=-


