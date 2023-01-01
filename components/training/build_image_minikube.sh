#!/bin/bash -e
image_name=kubeflow_with_r_example/training
image_tag=latest
full_image_name=registry.dev.svc.cluster.local:5000/${image_name}:${image_tag}
 
cd "$(dirname "$0")" 
docker build --build-arg CODE_VER=$(date +%Y%m%d-%H%M%S) -t "${full_image_name}"  -f Dockerfile src/ 
docker push ${full_image_name}
