#!/bin/bash -e
image_name=kubeflow_with_r_example/preprocessing
image_tag=latest
full_image_name=${image_name}:${image_tag}
 
cd "$(dirname "$0")" 
docker build --build-arg CODE_VER=$(date +%Y%m%d-%H%M%S) -t "${full_image_name}" -f Dockerfile src/ 

