#!/bin/bash

# Set the current working directory
CWD=$(pwd)
echo $CWD
# Find all Dockerfile files recursively
for dockerfile in $(find $CWD -type f -name Dockerfile); do
    echo "Scanning $dockerfile"
    # Extract the image names in FROM lines into an array
    image_names=$(grep -o 'FROM\s\+\([^[:space:]]\+\)' $dockerfile | cut -d' ' -f2 | sort -u)
    # Loop through the image names and scan each image for vulnerabilities
    mkdir ./scan-results/
   for image_name in $image_names; do
        echo "$image_name"
        output_file=$(echo "$dockerfile" | cut -d'/' -f7-)
        output_file=${output_file//tmp-repo\//}
        image_name_safe=$(echo "$image_name" | tr -cs '[:alnum:]' '_')
        output_file=${output_file//\//_}$image_name_safe
        echo "saving as $output_file"
       trivy image -q --format json --exit-code 0 --vuln-type  os,library --scanners vuln --severity CRITICAL,HIGH --ignore-unfixed "$image_name" --output ./scan-results/$output_file.json
   done
done

cd scan-results;
ls
for output in $(ls);do
    echo $output
    cat $output | jq .
done
