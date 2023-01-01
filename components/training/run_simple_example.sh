#!/bin/bash -e
cd "$(dirname "$0")"
input_path=$(pwd)/../preprocessing/output/
output_path=$(pwd)/output/
mkdir -p ${output_path}

if [ ! -f "${input_path}data.RData" ]; then
    echo "Run preprocessing example first (to create a dataset for training)."
	exit 1
fi

docker run \
 -v ${input_path}:/project/input/ \
 -v ${output_path}:/project/output/ \
 kubeflow_with_r_example/training \
 "--input"  "/project/input/data.RData" \
 "--lambda" "0.1" \
 "--alpha" "0.1"  \
 "--threshold" "0.5" \
 "--output" "/project/output/model.RData"  \
 "--metric_pipeline" "/project/output/metric_pipeline.txt" \
 "--metric_katib"  "/project/output/metric_katib.txt" 

echo -e "\n\nSee outputs: ${output_path}"
