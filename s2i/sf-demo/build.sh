#!/bin/bash

dir=$(pwd)

# Clear app folder
rm -rf $dir/public/*

# Clone app
git clone -b k8s --single-branch https://github.com/mmohamed/demo.git $dir/public

docker build . -t medinvention/sfdemo:arm
docker push medinvention/sfdemo:arm
docker rmi medinvention/sfdemo:arm