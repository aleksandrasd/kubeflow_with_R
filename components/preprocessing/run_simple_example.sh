#!/bin/bash -e
cd "$(dirname "$0")"
output_path=$(pwd)/output/
mkdir -p ${output_path}

docker run \
 -v ${output_path}:/project/output/ kubeflow_with_r_example/preprocessing \
 "--min_ngrams" 1 \
 "--max_ngrams" 2 \
 "--max_tokens" 300 \
 "--output" "/project/output/data.RData"

read -p "Would you like to see the output? [y/n]: " answer
answer=${answer:-n}

if [[ $answer = "y" ]]; then
  docker run \
   --entrypoint bash \
   -v ${output_path}:/project/output/ kubeflow_with_r_example/preprocessing \
   "-c" \
   "R -e 'str(readRDS(\"/project/output/data.RData\"))'"
fi

echo -e "\n\nSee outputs: ${output_path}"